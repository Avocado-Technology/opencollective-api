# OpenCollective API - Development Environment

## 🚀 Quick Start

### Prerequisites

- Node.js 20.18+ (use `nvm install 20.18` if needed)
- Docker & Docker Compose
- Git

### First Time Setup

```bash
# 1. Install dependencies
SKIP_POSTINSTALL=1 npm install

# 2. Install ARM64 Sharp (for Apple Silicon Macs)
npm install --os=darwin --cpu=arm64 sharp

# 3. Start all services & setup database
npm run dev:start

# That's it! 🎉 Everything is now running and ready for development
```

### Alternative Manual Setup

```bash
# 1. Start services manually
npm run docker:start

# 2. Check service health
npm run health:check

# 3. Set up database (if needed)
npm run db:setup:docker

# 4. Start the API server
npm run dev:full
```

## 📋 Daily Usage Commands

### 🐳 Docker Services Management

```bash
# Start development services (PostgreSQL + Redis + Mailpit + MinIO)
npm run docker:start

# Start all services (+ Memcached + OpenSearch)
npm run docker:start:full

# Start only database
npm run docker:start:database

# Start only cache services (Redis + Memcached)
npm run docker:start:cache

# Stop all services
npm run docker:stop

# Restart services
npm run docker:restart

# View service status
npm run docker:status

# View live logs
npm run docker:logs

# Stop and remove volumes (resets database)
npm run docker:clean
```

### 🔍 Health Monitoring

```bash
# Check all services health
npm run health:check

# Example output:
# === Service Health Check ===
# PostgreSQL: UP
# Redis: PONG
# Memcached: UP
# Mailpit: UP
# MinIO: UP
# API Server: UP
```

### 🚀 API Server Management

```bash
# Start development server (with all environment variables configured)
npm run dev:full

# Complete setup: start services + database + API server in one command
npm run dev:start

# Just setup services and check health (without starting API)
npm run dev:setup

# Original dev command (requires manual env vars)
npm run dev

# Type checking
npm run type:check

# Linting
npm run lint

# Build for production
npm run build
```

### 🗄️ Database Operations

```bash
# Connect to database
npm run db:connect

# Run migrations with Docker database
npm run db:migrate:docker

# Reset database (drops and recreates)
npm run db:reset:docker

# Complete database setup (reset + migrate)
npm run db:setup:docker

# Connect to Redis
npm run redis:connect

# Flush Redis cache
npm run redis:flush

# Manual database operations (advanced)
# Connect to specific database
docker exec -it opencollective-postgres psql -U opencollective -d opencollective_dvl

# Backup database
docker exec opencollective-postgres pg_dump -U opencollective opencollective_dvl > backup.sql

# Restore database
docker exec -i opencollective-postgres psql -U opencollective -d opencollective_dvl < backup.sql

# Check Memcached stats
echo stats | nc localhost 11211
```

### 📊 Monitoring & Logs

```bash
# View API server logs (if running in background)
tail -f ~/.pm2/logs/*.log

# View Docker service logs
docker-compose -f docker-compose.dev.yml logs -f postgres
docker-compose -f docker-compose.dev.yml logs -f mailpit
docker-compose -f docker-compose.dev.yml logs -f minio

# View all services logs
docker-compose -f docker-compose.dev.yml logs -f

# Check service health
docker exec opencollective-postgres pg_isready -U opencollective -d opencollective_dvl
```

## 🌐 Service Access Points

| Service                     | URL                           | Credentials                   |
| --------------------------- | ----------------------------- | ----------------------------- |
| **API Server**              | http://localhost:3060         | -                             |
| **GraphQL Playground**      | http://localhost:3060/graphql | -                             |
| **PostgreSQL**              | localhost:5432                | `opencollective` / `password` |
| **Redis**                   | localhost:6379                | -                             |
| **Memcached**               | localhost:11211               | -                             |
| **Mailpit (Email Testing)** | http://localhost:1080         | -                             |
| **MinIO Console**           | http://localhost:9001         | `user` / `password`           |
| **MinIO API**               | http://localhost:9000         | -                             |
| **OpenSearch**              | http://localhost:9200         | -                             |

## 🛠️ Environment Configuration

### Database Connection

```bash
export PG_HOST=localhost
export PG_PORT=5432
export PG_DATABASE=opencollective_dvl
export PG_USERNAME=opencollective
export PG_PASSWORD=password
```

### Redis & Cache Configuration

```bash
export REDIS_URL=redis://localhost:6379
export REDIS_SESSION_URL=redis://localhost:6379
export REDIS_TIMELINE_URL=redis://localhost:6379
export MEMCACHE_SERVERS=localhost:11211
```

### Skip Postinstall Check

```bash
export SKIP_POSTINSTALL=1
```

### Create `.env.local` file (recommended)

```bash
cat > .env.local << 'EOF'
SKIP_POSTINSTALL=1

# Database
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=opencollective_dvl
PG_USERNAME=opencollective
PG_PASSWORD=password

# Redis & Cache
REDIS_URL=redis://localhost:6379
REDIS_SESSION_URL=redis://localhost:6379
REDIS_TIMELINE_URL=redis://localhost:6379
MEMCACHE_SERVERS=localhost:11211

# OpenSearch
OPENSEARCH_URL=http://localhost:9200

# MinIO (File Storage)
AWS_S3_BUCKET=opencollective-dev
AWS_S3_ENDPOINT=http://localhost:9000
AWS_ACCESS_KEY_ID=user
AWS_SECRET_ACCESS_KEY=password
EOF
```

## 🔧 Common Tasks

### Testing API Endpoints

```bash
# Test GraphQL endpoint
curl -X POST http://localhost:3060/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name } } }"}'

# Health check
curl http://localhost:3060/health

# Check API status
curl -s http://localhost:3060/graphql -o /dev/null -w "%{http_code}"
```

### Node.js Version Management

```bash
# Switch to required Node.js version
nvm use 20.18

# Install and use Node.js 20.18
nvm install 20.18
nvm use 20.18

# Verify versions
node --version  # Should be v20.18.x
npm --version   # Should be 10.x
```

## 🐛 Troubleshooting

### Common Issues & Solutions

#### "psql command doesn't exist"

```bash
# Use Docker PostgreSQL instead of local installation
SKIP_POSTINSTALL=1 npm install
```

#### "Sharp module error on Apple Silicon"

```bash
npm install --os=darwin --cpu=arm64 sharp
```

#### "Node.js version not compatible"

```bash
nvm install 20.18
nvm use 20.18
npm install
```

#### "Port already in use"

```bash
# Check what's using the port
lsof -i :3060
lsof -i :5432

# Kill process using port
kill -9 $(lsof -ti:3060)
```

#### "Database connection refused"

```bash
# Ensure PostgreSQL container is running
docker-compose -f docker-compose.dev.yml ps postgres

# Restart PostgreSQL
docker-compose -f docker-compose.dev.yml restart postgres

# Check PostgreSQL logs
docker-compose -f docker-compose.dev.yml logs postgres
```

#### "Migration errors"

```bash
# Reset and recreate database
docker exec -i opencollective-postgres psql -U opencollective -d postgres -c "DROP DATABASE IF EXISTS opencollective_dvl;"
docker exec -i opencollective-postgres psql -U opencollective -d postgres -c "CREATE DATABASE opencollective_dvl;"

# Run archived migrations first (if needed)
PG_HOST=localhost npm run db:migrate --migrations-path migrations/archives/
```

### Service Status Check

```bash
# Quick health check script
echo "=== Service Health Check ==="
echo "API Server: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3060/health || echo "DOWN")"
echo "PostgreSQL: $(docker exec opencollective-postgres pg_isready -U opencollective -d opencollective_dvl 2>/dev/null && echo "UP" || echo "DOWN")"
echo "Redis: $(docker exec opencollective-redis redis-cli ping 2>/dev/null || echo "DOWN")"
echo "Memcached: $(echo stats | nc localhost 11211 >/dev/null 2>&1 && echo "UP" || echo "DOWN")"
echo "Mailpit: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:1080 || echo "DOWN")"
echo "MinIO: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/minio/health/live || echo "DOWN")"
echo "OpenSearch: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/_cluster/health || echo "DOWN")"
```

## 📝 Development Workflow

### 🌅 **Start your day:**

```bash
# Option 1: Everything in one command (recommended)
npm run dev:start

# Option 2: Manual step-by-step
npm run docker:start    # Start services
npm run health:check    # Verify all services are up
npm run dev:full        # Start API server
```

### 🔄 **During development:**

- API automatically reloads on file changes (nodemon)
- Database persists between restarts
- Check service health: `npm run health:check`
- View logs: `npm run docker:logs`

### 🧪 **Test your changes:**

- **GraphQL Playground**: http://localhost:3060/graphql
- **Email Testing**: http://localhost:1080 (Mailpit)
- **File Storage**: http://localhost:9001 (MinIO Console)

### 🌙 **End of day:**

```bash
# Stop API server (Ctrl+C if running in foreground)

# Keep Docker services running for next day (recommended):
# Services persist and start faster next time

# OR stop everything:
npm run docker:stop
```

### 🔧 **Common Tasks:**

```bash
# Restart just the API server
# Ctrl+C to stop, then: npm run dev:full

# Restart Docker services
npm run docker:restart

# Reset database to clean state
npm run db:setup:docker

# Check what's running
npm run docker:status
npm run health:check

# View logs for debugging
npm run docker:logs
```

## 🎯 Pro Tips

- Use **GraphQL Playground** at http://localhost:3060/graphql for API testing
- Check **Mailpit** at http://localhost:1080 to see emails sent by the API
- Use `rs` in the nodemon console to manually restart the server
- Database data persists between container restarts
- Use `docker-compose logs -f [service]` to debug service issues

---

Happy coding! 🚀
