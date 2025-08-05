#!/bin/bash

# OpenCollective API Deployment Script
# Usage: ./deploy.sh [dev|staging|prod]

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

echo "🚀 Deploying OpenCollective API for environment: $ENVIRONMENT"

# Load environment variables
ENV_FILE=".env.$ENVIRONMENT"
if [ -f "$ENV_FILE" ]; then
    echo "📋 Loading environment variables from $ENV_FILE"
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
else
    echo "⚠️  Warning: Environment file $ENV_FILE not found"
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

# Create necessary directories
echo "📁 Setting up directories..."
mkdir -p logs
mkdir -p uploads
mkdir -p backups

# Stop existing containers
echo "📦 Stopping existing containers..."
if [ -f "$ENV_FILE" ]; then
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down || true
else
    docker-compose -f "$COMPOSE_FILE" down || true
fi

# Force remove any conflicting containers
echo "🧹 Cleaning up conflicting containers..."
docker rm -f opencollective-api opencollective-postgres opencollective-redis opencollective-memcached 2>/dev/null || true

# Build and start containers
echo "🏗️  Building and starting OpenCollective API..."
if [ -f "$ENV_FILE" ]; then
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build
else
    docker-compose -f "$COMPOSE_FILE" up -d --build
fi

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if running
if [ -f "$ENV_FILE" ]; then
    CHECK_CMD="docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE ps"
    LOG_CMD="docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE logs"
else
    CHECK_CMD="docker-compose -f $COMPOSE_FILE ps"
    LOG_CMD="docker-compose -f $COMPOSE_FILE logs"
fi

if $CHECK_CMD | grep -q "Up"; then
    echo "✅ OpenCollective API deployed successfully!"
    $CHECK_CMD
    
    # Run database migrations if needed
    echo "🗃️  Running database migrations..."
    docker exec opencollective-api npm run db:migrate || echo "⚠️  Migration failed or not needed"
    
    # Health check
    echo "🏥 Performing health check..."
    sleep 5
    if curl -f http://localhost:3060/health > /dev/null 2>&1 || curl -f http://localhost:3060/graphql > /dev/null 2>&1; then
        echo "✅ Health check passed!"
    else
        echo "⚠️  Health check failed, but deployment completed"
    fi
else
    echo "❌ Deployment failed!"
    $LOG_CMD
    exit 1
fi