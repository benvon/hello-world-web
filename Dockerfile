# Build Go backend
FROM golang:1.24 AS builder
WORKDIR /app
COPY backend/ ./backend/
WORKDIR /app/backend
RUN go build -o /app/backend-api

# Final image
FROM ghcr.io/nginx/nginx-unprivileged:1.29-bookworm
COPY --from=builder /app/backend-api /usr/local/bin/backend-api
COPY content/ /usr/share/nginx/html/
COPY conf.d/ /etc/nginx/conf.d/

# Add entrypoint script
COPY --chmod=755 scripts/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

EXPOSE 8080 8081

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8081/api/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
