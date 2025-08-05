# Multi-stage build for optimized performance and size
FROM node:20-alpine AS base

# Install curl for health checks, dependencies, and build tools for native modules
RUN apk add --no-cache \
    curl \
    libc6-compat \
    bash \
    python3 \
    make \
    g++ \
    linux-headers \
    py3-setuptools

WORKDIR /usr/src/frontend

# Skip Cypress Install
ENV CYPRESS_INSTALL_BINARY=0

# Install dependencies only when needed
FROM base AS deps
# Copy package files
COPY package*.json ./
# Install dependencies with --legacy-peer-deps to resolve React 19 conflicts
RUN npm install --legacy-peer-deps --omit=dev --ignore-scripts && npm cache clean --force

# Build stage - install all deps including dev dependencies
FROM base AS build
# Copy all source files first so config files are available
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
# Install all dependencies including dev deps with --legacy-peer-deps  
RUN npm install --legacy-peer-deps
# Rebuild native modules for the current platform
RUN npm rebuild lightningcss @tailwindcss/node
RUN npm run build

# Production stage
FROM base AS runner
WORKDIR /usr/src/frontend

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application
COPY --from=build /usr/src/frontend/public ./public
COPY --from=build --chown=nextjs:nodejs /usr/src/frontend/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /usr/src/frontend/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]