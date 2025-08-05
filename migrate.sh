#!/bin/bash

# OpenCollective API Migration Script
# Usage: ./migrate.sh [dev|staging|prod]

set -e

ENVIRONMENT=${1:-dev}

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        echo "Usage: $0 [dev|staging|prod]"
        exit 1
        ;;
esac

echo "🔄 Starting migration for OpenCollective API in environment: $ENVIRONMENT"

# Load environment variables
ENV_FILE=".env.$ENVIRONMENT"
if [ -f "$ENV_FILE" ]; then
    echo "📋 Loading environment variables from $ENV_FILE"
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
else
    echo "❌ Environment file $ENV_FILE not found"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Set compose file
COMPOSE_FILE="docker-compose.$ENVIRONMENT.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Compose file not found: $COMPOSE_FILE"
    exit 1
fi

# Create network if it doesn't exist
if [ "$ENVIRONMENT" = "dev" ]; then
    NETWORK_NAME="opencollective-dev"
else
    NETWORK_NAME="traefik-$ENVIRONMENT"
fi

docker network create "$NETWORK_NAME" 2>/dev/null || true

echo "🔗 Connecting to network: $NETWORK_NAME"

# Check if any existing OpenCollective API containers need to be migrated
echo "🔍 Checking for existing containers..."
EXISTING_CONTAINERS=$(docker ps --format "table {{.Names}}" | grep -E "(opencollective)" | grep -v NAMES || true)

if [ -n "$EXISTING_CONTAINERS" ]; then
    echo "📋 Found existing containers:"
    echo "$EXISTING_CONTAINERS"
    
    # Create backup before migration
    echo "💾 Creating backup before migration..."
    BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup current state
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' > "$BACKUP_DIR/containers-before.txt"
    docker network ls > "$BACKUP_DIR/networks-before.txt"
    
    if docker ps | grep -q opencollective-api; then
        docker inspect opencollective-api > "$BACKUP_DIR/api-config.json" 2>/dev/null || true
        docker logs opencollective-api > "$BACKUP_DIR/api-logs.txt" 2>/dev/null || true
    fi
    
    if docker ps | grep -q opencollective-postgres; then
        echo "🗄️  Creating database backup..."
        docker exec opencollective-postgres pg_dump -U "$PG_USERNAME" "$PG_DATABASE" > "$BACKUP_DIR/database-backup.sql" 2>/dev/null || true
    fi
    
    echo "✅ Backup created in: $BACKUP_DIR"
    
    # Connect existing containers to new network if needed
    echo "$EXISTING_CONTAINERS" | while read container; do
        if [ -n "$container" ]; then
            echo "🔗 Connecting $container to $NETWORK_NAME..."
            docker network connect "$NETWORK_NAME" "$container" 2>/dev/null || echo "ℹ️  $container already connected or not found"
        fi
    done
    
    # Graceful shutdown of old containers
    echo "🛑 Gracefully stopping existing containers..."
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down --timeout 30 || true
else
    echo "ℹ️  No existing containers found to migrate"
fi

# Start new deployment
echo "🚀 Starting new deployment..."
./deploy.sh "$ENVIRONMENT"

# Verify migration
echo "🔍 Verifying migration..."
if docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps | grep -q "Up"; then
    echo "✅ Migration completed successfully!"
    
    # Run database migrations
    echo "🗃️  Running database migrations..."
    docker exec opencollective-api npm run db:migrate || echo "⚠️  Migration failed or not needed"
    
    # Health check
    echo "🏥 Performing post-migration health check..."
    sleep 10
    
    if curl -f http://localhost:3060/health > /dev/null 2>&1 || curl -f http://localhost:3060/graphql > /dev/null 2>&1; then
        echo "✅ Post-migration health check passed!"
    else
        echo "⚠️  Health check failed, check logs"
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs --tail=20
    fi
    
    # Show final status
    echo "📊 Final deployment status:"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
else
    echo "❌ Migration failed!"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs
    exit 1
fi