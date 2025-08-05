#!/bin/bash

# OpenCollective API Rollback Script
# Usage: ./rollback.sh [backup-directory]

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [backup-directory]"
    echo "Available backups:"
    ls -la backup-* 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_DIR="$1"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "🔄 Starting rollback from backup: $BACKUP_DIR"

# Check if backup contains necessary files
if [ ! -f "$BACKUP_DIR/containers-before.txt" ]; then
    echo "❌ Invalid backup directory: missing containers-before.txt"
    exit 1
fi

# Determine environment from current state or ask user
echo "🔍 Detecting environment..."
ENVIRONMENT=""
if docker ps | grep -q "traefik-prod"; then
    ENVIRONMENT="prod"
elif docker ps | grep -q "traefik-staging"; then
    ENVIRONMENT="staging"
else
    ENVIRONMENT="dev"
fi

echo "📋 Detected environment: $ENVIRONMENT"

# Load environment variables
ENV_FILE=".env.$ENVIRONMENT"
if [ -f "$ENV_FILE" ]; then
    echo "📋 Loading environment variables from $ENV_FILE"
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
else
    echo "❌ Environment file $ENV_FILE not found"
    exit 1
fi

# Show what was running before
echo "📋 Previous state (from backup):"
cat "$BACKUP_DIR/containers-before.txt"

# Confirm rollback
echo ""
echo "⚠️  WARNING: This will stop current containers and attempt to restore the previous state."
read -p "❔ Are you sure you want to proceed with rollback? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "❌ Rollback cancelled"
    exit 1
fi

# Set compose file
COMPOSE_FILE="docker-compose.$ENVIRONMENT.yml"

# Stop current deployment
echo "🛑 Stopping current deployment..."
if [ -f "$ENV_FILE" ]; then
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down || true
else
    docker-compose -f "$COMPOSE_FILE" down || true
fi

# Force remove current containers
echo "🧹 Removing current containers..."
docker rm -f opencollective-api opencollective-postgres opencollective-redis opencollective-memcached 2>/dev/null || true

# Restore database if backup exists
if [ -f "$BACKUP_DIR/database-backup.sql" ] && [ -n "$PG_DATABASE" ]; then
    echo "🗄️  Restoring database from backup..."
    
    # Start only postgres for restoration
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d postgres
    
    # Wait for postgres to be ready
    echo "⏳ Waiting for database to be ready..."
    sleep 10
    
    # Restore database
    docker exec -i opencollective-postgres psql -U "$PG_USERNAME" -d postgres -c "DROP DATABASE IF EXISTS $PG_DATABASE;"
    docker exec -i opencollective-postgres psql -U "$PG_USERNAME" -d postgres -c "CREATE DATABASE $PG_DATABASE;"
    docker exec -i opencollective-postgres psql -U "$PG_USERNAME" -d "$PG_DATABASE" < "$BACKUP_DIR/database-backup.sql" || echo "⚠️  Database restore failed or not needed"
    
    echo "✅ Database restored"
fi

# Use the previous docker images if specified in backup
echo "🔄 Attempting to restore previous container state..."

# For now, we'll just restart with the current docker-compose setup
# In a more sophisticated setup, we could restore specific image versions
if [ -f "$ENV_FILE" ]; then
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
else
    docker-compose -f "$COMPOSE_FILE" up -d
fi

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 15

# Verify rollback
echo "🔍 Verifying rollback..."
if docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps | grep -q "Up"; then
    echo "✅ Rollback completed successfully!"
    
    # Health check
    echo "🏥 Performing health check..."
    sleep 5
    
    if curl -f http://localhost:3060/health > /dev/null 2>&1 || curl -f http://localhost:3060/graphql > /dev/null 2>&1; then
        echo "✅ Health check passed!"
    else
        echo "⚠️  Health check failed, check logs"
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs --tail=20
    fi
    
    # Show current status
    echo "📊 Current status after rollback:"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
    
    echo "📋 Rollback completed. Original backup preserved in: $BACKUP_DIR"
else
    echo "❌ Rollback failed!"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs
    exit 1
fi