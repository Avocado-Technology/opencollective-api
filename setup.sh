#!/bin/bash

# OpenCollective API Setup Script
# Initializes the deployment environment

set -e

echo "🔧 Setting up OpenCollective API deployment environment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 20.x first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Install dependencies
echo "📦 Installing dependencies..."
SKIP_POSTINSTALL=1 npm install

# Create environment files if they don't exist
echo "📋 Setting up environment files..."

# Development environment
if [ ! -f ".env.dev" ]; then
    echo "📝 Creating .env.dev template..."
    cat > .env.dev << EOF
# Development Environment Configuration
NODE_ENV=development
PORT=3060

# Database
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=opencollective_dvl
PG_USERNAME=opencollective
PG_PASSWORD=password

# Redis
REDIS_URL=redis://localhost:6379
REDIS_SESSION_URL=redis://localhost:6379
REDIS_PORT=6379

# Memcached
MEMCACHED_PORT=11211

# URLs
API_URL=http://localhost:3060
WEBSITE_URL=http://localhost:3000
IMAGES_URL=http://localhost:3000
PDF_SERVICE_URL=http://localhost:3002

# Domain for Traefik routing
API_DOMAIN=api.localhost

# Email (Development)
MAILGUN_API_KEY=your_mailgun_api_key
MAILGUN_DOMAIN=your_mailgun_domain

# Social Auth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
TWITTER_CONSUMER_KEY=your_twitter_consumer_key
TWITTER_CONSUMER_SECRET=your_twitter_consumer_secret

# Payment Providers
STRIPE_KEY=pk_test_your_stripe_key
STRIPE_SECRET=sk_test_your_stripe_secret
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_CLIENT_ID=your_paypal_client_id
PAYPAL_CLIENT_SECRET=your_paypal_client_secret

# AWS/S3
AWS_KEY=user
AWS_SECRET=password
AWS_S3_BUCKET=opencollective-dev
AWS_S3_REGION=us-east-1
EOF
    echo "✅ Created .env.dev template. Please update with your actual values."
else
    echo "✅ .env.dev already exists"
fi

# Staging environment template
if [ ! -f ".env.staging" ]; then
    echo "📝 Creating .env.staging template..."
    cat > .env.staging << EOF
# Staging Environment Configuration
NODE_ENV=production
PORT=3060

# Database
PG_HOST=postgres
PG_PORT=5432
PG_DATABASE=opencollective_staging
PG_USERNAME=opencollective
PG_PASSWORD=staging_secure_password

# Redis
REDIS_URL=redis://redis:6379
REDIS_SESSION_URL=redis://redis:6379
REDIS_PORT=6379

# Memcached
MEMCACHED_PORT=11211

# URLs
API_URL=https://api-staging.your-domain.com
WEBSITE_URL=https://staging.your-domain.com
IMAGES_URL=https://staging.your-domain.com
PDF_SERVICE_URL=https://pdf-staging.your-domain.com

# Domain for Traefik routing
API_DOMAIN=api-staging.your-domain.com

# Email (Staging)
MAILGUN_API_KEY=your_mailgun_api_key
MAILGUN_DOMAIN=your_mailgun_domain

# Social Auth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
TWITTER_CONSUMER_KEY=your_twitter_consumer_key
TWITTER_CONSUMER_SECRET=your_twitter_consumer_secret

# Payment Providers (Sandbox)
STRIPE_KEY=pk_test_your_stripe_key
STRIPE_SECRET=sk_test_your_stripe_secret
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_CLIENT_ID=your_paypal_client_id
PAYPAL_CLIENT_SECRET=your_paypal_client_secret

# AWS/S3
AWS_KEY=your_aws_key
AWS_SECRET=your_aws_secret
AWS_S3_BUCKET=opencollective-staging
AWS_S3_REGION=us-east-1
EOF
    echo "✅ Created .env.staging template. Please update with your actual values."
else
    echo "✅ .env.staging already exists"
fi

# Production environment template
if [ ! -f ".env.prod" ]; then
    echo "📝 Creating .env.prod template..."
    cat > .env.prod << EOF
# Production Environment Configuration
NODE_ENV=production
PORT=3060

# Database
PG_HOST=postgres
PG_PORT=5432
PG_DATABASE=opencollective_prod
PG_USERNAME=opencollective
PG_PASSWORD=production_secure_password

# Redis
REDIS_URL=redis://redis:6379
REDIS_SESSION_URL=redis://redis:6379
REDIS_PORT=6379

# Memcached
MEMCACHED_PORT=11211

# URLs
API_URL=https://api.your-domain.com
WEBSITE_URL=https://your-domain.com
IMAGES_URL=https://your-domain.com
PDF_SERVICE_URL=https://pdf.your-domain.com

# Domain for Traefik routing
API_DOMAIN=api.your-domain.com

# Email (Production)
MAILGUN_API_KEY=your_mailgun_api_key
MAILGUN_DOMAIN=your_mailgun_domain

# Social Auth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
TWITTER_CONSUMER_KEY=your_twitter_consumer_key
TWITTER_CONSUMER_SECRET=your_twitter_consumer_secret

# Payment Providers (Live)
STRIPE_KEY=pk_live_your_stripe_key
STRIPE_SECRET=sk_live_your_stripe_secret
PAYPAL_ENVIRONMENT=live
PAYPAL_CLIENT_ID=your_paypal_client_id
PAYPAL_CLIENT_SECRET=your_paypal_client_secret

# AWS/S3
AWS_KEY=your_aws_key
AWS_SECRET=your_aws_secret
AWS_S3_BUCKET=opencollective-prod
AWS_S3_REGION=us-east-1
EOF
    echo "✅ Created .env.prod template. Please update with your actual values."
else
    echo "✅ .env.prod already exists"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p logs
mkdir -p uploads
mkdir -p backups
mkdir -p tmp

echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Update environment files (.env.dev, .env.staging, .env.prod) with your actual configuration"
echo "2. Ensure Traefik is deployed and running for staging/production environments"
echo "3. Run 'npm run deploy:dev' to start development deployment"
echo "4. Run 'npm run deploy:staging' to deploy to staging"
echo "5. Run 'npm run deploy:prod' to deploy to production"
echo ""
echo "🔧 Available commands:"
echo "- npm run deploy:dev      - Deploy to development"
echo "- npm run deploy:staging  - Deploy to staging"
echo "- npm run deploy:prod     - Deploy to production"
echo "- npm run migrate:dev     - Run migrations in development"
echo "- npm run migrate:staging - Run migrations in staging"
echo "- npm run migrate:prod    - Run migrations in production"