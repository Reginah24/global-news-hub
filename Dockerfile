# Use Nginx to serve static HTML files
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy the HTML file to Nginx's default directory
COPY index.html /usr/share/nginx/html/
COPY health.html /usr/share/nginx/html/
COPY js/ /usr/share/nginx/html/js/

# Create startup script to inject environment variables
RUN echo '#!/bin/sh' > /docker-entrypoint.d/30-inject-env.sh && \
    echo 'if [ -n "$NEWS_API_KEY" ]; then' >> /docker-entrypoint.d/30-inject-env.sh && \
    echo '  sed -i "s/YOUR_API_KEY_HERE/$NEWS_API_KEY/g" /usr/share/nginx/html/index.html' >> /docker-entrypoint.d/30-inject-env.sh && \
    echo 'fi' >> /docker-entrypoint.d/30-inject-env.sh && \
    chmod +x /docker-entrypoint.d/30-inject-env.sh

# Create a custom Nginx configuration that listens on port 8080
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Enable gzip compression \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript; \
    \
    # Add security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    \
    # Cache static assets \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Remove the default Nginx configuration
RUN rm -f /etc/nginx/conf.d/default.conf.dpkg-old 2>/dev/null || true

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]