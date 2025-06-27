FROM ghcr.io/nginx/nginx-unprivileged:1.29-bookworm

COPY content/ /usr/share/nginx/html/
COPY conf.d/ /etc/nginx/conf.d/
