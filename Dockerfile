# Use official Node.js runtime as base image
FROM node:20-alpine

# Install dependencies for building native modules and runtime tools
# Add vips-dev and other dependencies for sharp module
RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    make \
    g++ \
    linux-headers \
    vips-dev \
    fftw-dev \
    build-base \
    libc6-compat \
    && apk add --no-cache --virtual .gyp \
    py3-setuptools

# Set working directory
WORKDIR /usr/src/app

# Create app user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S opencollective -u 1001

# Copy package files and scripts needed for install
COPY package*.json ./
COPY scripts/ ./scripts/

# Install dependencies with legacy peer deps to resolve conflicts, skip postinstall
ENV SKIP_POSTINSTALL=1
# Force sharp to rebuild from source with proper bindings
ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1
RUN npm install --legacy-peer-deps && npm rebuild sharp

# Copy rest of application source
COPY --chown=opencollective:nodejs . .

# Build the application
RUN npm run build

# Create necessary directories
RUN mkdir -p /usr/src/app/logs
RUN chown -R opencollective:nodejs /usr/src/app

# Switch to non-root user
USER opencollective

# Expose port
EXPOSE 3060

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3060/health || exit 1

# Start the application
CMD ["npm", "start"]