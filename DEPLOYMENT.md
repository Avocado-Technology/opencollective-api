# OpenCollective API Deployment Pipeline

This document describes the new deployment pipeline for the OpenCollective API, which follows the Traefik deployment model for consistency across the infrastructure.

## Overview

The deployment pipeline has been completely redesigned to use Docker containers with Traefik reverse proxy for routing and SSL termination. This replaces the previous Heroku-based deployment system.

## Key Features

- **Environment-specific deployments**: dev, staging, and production
- **Automated CI/CD**: GitHub Actions for testing and deployment
- **Container-based**: Docker and Docker Compose for consistent environments
- **Traefik integration**: Automatic SSL certificates and routing
- **Semantic versioning**: Automated releases with conventional commits
- **Rollback capability**: Backup and rollback mechanisms
- **Health checks**: Automated validation of deployments

## Files Created/Modified

### Core Deployment Files

- `Dockerfile` - Production-ready container image
- `docker-compose.staging.yml` - Staging environment configuration
- `docker-compose.prod.yml` - Production environment configuration
- `deploy.sh` - Main deployment script
- `setup.sh` - Initial environment setup
- `migrate.sh` - Migration script for smooth transitions
- `rollback.sh` - Rollback script for failed deployments

### Configuration Files

- `.releaserc.json` - Semantic release configuration
- `.commitlintrc.js` - Commit message linting rules
- Environment templates in `setup.sh`

### GitHub Actions Workflows

- `.github/workflows/release.yml` - Main CI/CD pipeline
- `.github/workflows/deploy-api.yml` - Manual deployment workflow

### Package.json Updates

- Added new deployment scripts
- Added semantic release dependencies
- Added conventional commit tooling

## Usage

### Initial Setup

```bash
# Run the setup script to initialize the environment
npm run setup

# Update environment files with your actual configuration
# Edit .env.dev, .env.staging, .env.prod
```

### Development Deployment

```bash
npm run deploy:dev
```

### Staging Deployment

```bash
npm run deploy:staging
```

### Production Deployment

```bash
npm run deploy:prod
```

### Migration (for existing deployments)

```bash
npm run migrate:staging
npm run migrate:prod
```

### Rollback (if needed)

```bash
./rollback.sh backup-YYYYMMDD-HHMMSS
```

## Environment Variables

Each environment requires specific configuration. Templates are created by the setup script:

### Required for all environments:

- `NODE_ENV` - Environment mode
- `PORT` - Application port (default: 3060)
- `PG_*` - PostgreSQL configuration
- `REDIS_URL` - Redis connection string
- `API_URL`, `WEBSITE_URL` - Service URLs
- `API_DOMAIN` - Domain for Traefik routing

### Optional but recommended:

- Payment provider credentials (Stripe, PayPal)
- Email service credentials (Mailgun)
- Social auth credentials (GitHub, Twitter)
- AWS/S3 credentials

## GitHub Actions Secrets

For automated deployments, configure these secrets in your GitHub repository:

### Development Environment:

- `DEV_HOST` - Development server hostname/IP
- `DEV_USERNAME` - SSH username
- `DEV_SSH_KEY` - SSH private key
- `DEV_*` - Development-specific configuration

### Staging Environment:

- `STAGING_HOST` - Staging server hostname/IP
- `STAGING_USERNAME` - SSH username
- `STAGING_SSH_KEY` - SSH private key
- `STAGING_*` - Staging-specific configuration

### Production Environment:

- `PROD_HOST` - Production server hostname/IP
- `PROD_USERNAME` - SSH username
- `PROD_SSH_KEY` - SSH private key
- `PROD_*` - Production-specific configuration

## Deployment Flow

### Automated Deployments

1. **Develop branch** → triggers deployment to development environment
2. **Main branch** → triggers deployment to staging environment
3. **Manual workflow** → allows deployment to any environment

### Manual Deployments

Use the GitHub Actions "Manual Deploy OpenCollective API" workflow for:

- Emergency deployments
- Production deployments
- Testing specific branches

## Prerequisites

### Server Requirements

- Docker and Docker Compose installed
- Traefik reverse proxy running (for staging/production)
- SSH access configured
- Proper network setup

### Local Development

- Node.js 20.x
- Docker and Docker Compose
- npm 10.x

## Network Architecture

### Development

- Uses `opencollective-dev` network
- Direct port access (3060, 5432, 6379)

### Staging/Production

- Uses `traefik-staging`/`traefik-prod` networks
- Traefik handles routing and SSL
- Internal container communication

## Monitoring and Logs

### Health Checks

- `/health` endpoint for basic health
- `/graphql` endpoint for GraphQL availability
- Database connectivity checks
- Redis connectivity checks

### Log Access

```bash
# View application logs
docker logs opencollective-api

# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f postgres
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3060, 5432, 6379 are available
2. **Network issues**: Verify Traefik networks exist
3. **Permission issues**: Check file permissions on scripts
4. **Environment variables**: Verify all required variables are set

### Debug Commands

```bash
# Check container status
docker-compose ps

# Check networks
docker network ls

# Check environment file
cat .env.staging

# Test deployment script
bash -n deploy.sh
```

## Migration from Heroku

The new system replaces the Heroku-based deployment. Key differences:

### Old System (Heroku)

- Git-based deployments
- `pre-deploy.sh` script
- Heroku-specific configuration
- Manual scaling

### New System (Docker + Traefik)

- Container-based deployments
- Environment-specific configurations
- Automated SSL and routing
- Infrastructure as code

## Security Considerations

- All secrets managed through GitHub Secrets
- Non-root container user
- Proper file permissions on scripts
- Environment-specific configurations
- Backup mechanisms in place

## Support

For issues with the deployment pipeline:

1. Check GitHub Actions logs
2. Verify server requirements
3. Review environment configuration
4. Use rollback if necessary
5. Contact the development team

---

This deployment pipeline provides a robust, scalable, and maintainable solution for the OpenCollective API infrastructure.
