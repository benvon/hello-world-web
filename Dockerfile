# Build Go backend
FROM golang:1.24 AS api-builder
WORKDIR /app
COPY backend/ ./backend/
WORKDIR /app/backend
RUN go build -o /app/backend-api

# Build EFS utils
FROM rust:1.90 AS efs-builder
WORKDIR /build
RUN apt-get update && \
    apt-get install -y \
      binutils \
      gettext \
      git \
      libssl-dev \
      pkg-config \
      && \
    git clone https://github.com/aws/efs-utils.git && \
    cd efs-utils && \
    ./build-deb.sh


# Final image
FROM ghcr.io/nginx/nginx-unprivileged:1.29-bookworm

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    nfs-common \
    python3-boto3 \
    python3-botocore \
    python3-pip \
    wget \
    && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /efs-utils

COPY --from=efs-builder /build/efs-utils/build/amazon-efs-utils*deb /efs-utils/
RUN apt-get update && \
    apt-get install -y /efs-utils/amazon-efs-utils*deb && \
    rm /efs-utils/amazon-efs-utils*deb 

USER 101

COPY --from=api-builder /app/backend-api /usr/local/bin/backend-api
COPY content/ /usr/share/nginx/html/
COPY conf.d/ /etc/nginx/conf.d/

# Add entrypoint script
COPY --chmod=755 scripts/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

EXPOSE 8080 8081

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8081/api/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
