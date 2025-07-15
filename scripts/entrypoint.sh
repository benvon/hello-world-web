#!/bin/sh

# Start Go backend API
backend-api &

# Start Nginx (foreground)
exec nginx -g 'daemon off;' 