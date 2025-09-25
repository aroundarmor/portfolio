# Multi-stage Docker build for Portfolio
# Stage 1: Build stage - Prepare static assets
FROM alpine:3.19 AS builder

# Install tools for optimization and update packages
RUN apk update && apk upgrade && apk add --no-cache findutils sed

# Set working directory
WORKDIR /app

# Copy source files
COPY docs/ ./docs/

# Create optimized build (minify, compress, etc.)
RUN find docs/ -name "*.html" -exec sed -i 's/  */ /g' {} \; && \
    find docs/ -name "*.css" -exec sed -i 's/  */ /g' {} \; && \
    find docs/ -name "*.js" -exec sed -i 's/  */ /g' {} \;

# Stage 2: Production stage - Nginx server
FROM nginx:1.25-alpine AS production

# Update packages and install curl for health checks
RUN apk update && apk upgrade && apk add --no-cache curl

# Copy custom nginx configuration
COPY docker-package/nginx.conf /etc/nginx/nginx.conf

# Copy static files from builder stage
COPY --from=builder /app/docs /usr/share/nginx/html

# Set proper permissions for nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
