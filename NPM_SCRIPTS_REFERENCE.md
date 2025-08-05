# 📋 NPM Scripts Reference - OpenCollective API

## 🚀 **Quick Start Scripts**

### ⚡ **One-Command Setup**

```bash
npm run dev:start
```

**What it does:** Starts Docker services → Waits 5 seconds → Checks health → Starts API server with all environment variables configured.

Perfect for: First time setup, starting fresh each day.

---

## 🐳 **Docker Management Scripts**

| Script                          | Command             | Description                          |
| ------------------------------- | ------------------- | ------------------------------------ |
| `npm run docker:start`          | Starts dev services | PostgreSQL + Redis + Mailpit + MinIO |
| `npm run docker:start:full`     | Starts all services | + Memcached + OpenSearch             |
| `npm run docker:start:database` | Database only       | PostgreSQL only                      |
| `npm run docker:start:cache`    | Cache services      | Redis + Memcached                    |
| `npm run docker:stop`           | Stop all services   | Graceful shutdown                    |
| `npm run docker:restart`        | Restart services    | Stop + Start                         |
| `npm run docker:status`         | Show status         | List all containers                  |
| `npm run docker:logs`           | Live logs           | Stream logs from all services        |
| `npm run docker:clean`          | Nuclear option      | Stop + Remove volumes (resets data)  |

### 🔍 **Examples:**

```bash
# Start just what you need for development
npm run docker:start

# Need search functionality? Start everything
npm run docker:start:full

# Something broken? Reset everything
npm run docker:clean && npm run docker:start
```

---

## 💻 **Development Scripts**

| Script                 | Command           | Description                                       |
| ---------------------- | ----------------- | ------------------------------------------------- |
| `npm run dev:full`     | API with env vars | Development server with all environment variables |
| `npm run dev:start`    | Complete setup    | Docker + Health check + API server                |
| `npm run dev:setup`    | Services only     | Start services + health check (no API)            |
| `npm run health:check` | Service health    | Check status of all services                      |

### 🔍 **Examples:**

```bash
# Everything in one command (recommended for daily use)
npm run dev:start

# Just start the API (if services already running)
npm run dev:full

# Check if everything is working
npm run health:check
```

---

## 🗄️ **Database Scripts**

| Script                      | Command           | Description                  |
| --------------------------- | ----------------- | ---------------------------- |
| `npm run db:connect`        | Connect to DB     | Opens psql session           |
| `npm run db:migrate:docker` | Run migrations    | Uses Docker PostgreSQL       |
| `npm run db:reset:docker`   | Reset database    | Drop + Create fresh database |
| `npm run db:setup:docker`   | Complete DB setup | Reset + Run migrations       |

### 🔍 **Examples:**

```bash
# Quick database shell access
npm run db:connect

# Reset database to clean state
npm run db:setup:docker

# Just run new migrations
npm run db:migrate:docker
```

---

## 🔴 **Redis Scripts**

| Script                  | Command          | Description             |
| ----------------------- | ---------------- | ----------------------- |
| `npm run redis:connect` | Connect to Redis | Opens redis-cli session |
| `npm run redis:flush`   | Clear cache      | Flush all Redis data    |

### 🔍 **Examples:**

```bash
# Debug Redis issues
npm run redis:connect

# Clear cache after making changes
npm run redis:flush
```

---

## 📊 **Health Monitoring**

### `npm run health:check`

```bash
=== Service Health Check ===
PostgreSQL: UP
Redis: PONG
Memcached: UP
Mailpit: UP
MinIO: UP
API Server: UP
```

**Use cases:**

- Debug connection issues
- Verify services after restart
- Before starting development
- In CI/CD pipelines

---

## 🔄 **Daily Workflow Examples**

### 🌅 **Starting Your Day**

```bash
# Option 1: Everything at once
npm run dev:start

# Option 2: Step by step
npm run docker:start
npm run health:check
npm run dev:full
```

### 🔧 **During Development**

```bash
# Check if services are running
npm run health:check

# Restart API server only (Ctrl+C then:)
npm run dev:full

# Reset database for testing
npm run db:setup:docker

# Clear Redis cache
npm run redis:flush
```

### 🐛 **Debugging Issues**

```bash
# Check service status
npm run docker:status
npm run health:check

# View logs
npm run docker:logs

# Connect to services for debugging
npm run db:connect      # Database
npm run redis:connect   # Redis

# Nuclear option - reset everything
npm run docker:clean
npm run dev:start
```

### 🌙 **End of Day**

```bash
# Stop API server (Ctrl+C)

# Keep services running (recommended):
# - Faster startup tomorrow
# - Data persists

# OR stop everything:
npm run docker:stop
```

---

## ⚡ **Script Combinations**

### **Database Troubleshooting**

```bash
npm run docker:stop
npm run docker:start:database
npm run db:setup:docker
npm run docker:start
npm run dev:full
```

### **Cache Issues**

```bash
npm run redis:flush
npm run docker:restart
npm run health:check
```

### **Complete Reset**

```bash
npm run docker:clean
npm run dev:start
```

---

## 🎯 **Pro Tips**

1. **Use `npm run dev:start` for daily development** - It's the most comprehensive command

2. **Keep services running between sessions** - Faster startup, persistent data

3. **Use `npm run health:check` frequently** - Quick way to diagnose issues

4. **Database issues? Try `npm run db:setup:docker`** - Resets to clean state

5. **API not responding? Check logs** - `npm run docker:logs`

6. **Need to debug? Connect directly** - `npm run db:connect` or `npm run redis:connect`

---

## 🔧 **Environment Variables (Handled Automatically)**

The `npm run dev:full` script automatically sets:

```bash
SKIP_POSTINSTALL=1
REDIS_URL=redis://localhost:6379
REDIS_SESSION_URL=redis://localhost:6379
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=opencollective_dvl
PG_USERNAME=opencollective
PG_PASSWORD=password
```

**No need to set these manually!** ✨

---

## 📚 **Related Documentation**

- **[DEV_SETUP.md](./DEV_SETUP.md)** - Complete development setup guide
- **[SETUP_SUMMARY.md](./SETUP_SUMMARY.md)** - Overview of the entire development environment
- **[docker-compose.dev.yml](./docker-compose.dev.yml)** - Service configurations

---

**Happy coding! 🚀** These scripts should make your development workflow much smoother.
