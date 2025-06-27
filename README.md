# hello-world-web

Very basic web server with unique "hello world" content.

## Overview

This is a simple web application that serves a "Hello World" page using nginx. It's designed to be containerized and can be easily deployed anywhere Docker is supported.

## Features

- Lightweight nginx-based web server
- Docker containerization
- Multi-platform support (amd64, arm64)
- Automated releases with GitHub Actions
- GitHub Container Registry integration

## Quick Start

### Using Docker

```bash
# Pull the latest image
docker pull ghcr.io/YOUR_USERNAME/hello-world-web:latest

# Run the container
docker run -p 8080:8080 ghcr.io/YOUR_USERNAME/hello-world-web:latest

# Access the application
open http://localhost:8080
```

### Local Development

```bash
# Build the image locally
docker build -t hello-world-web .

# Run locally
docker run -p 8080:8080 hello-world-web

# Access the application
open http://localhost:8080
```

## Project Structure

```
hello-world-web/
├── content/           # Static web content
│   └── index.html    # Main HTML page
├── .github/          # GitHub Actions workflows
├── scripts/          # Release scripts
├── Dockerfile        # Docker configuration
└── README.md         # This file
```

## Release Process

This project uses GitHub Actions to automate releases and Docker image publishing to GitHub Container Registry.

### Creating a Release

1. **Prepare your changes:**
   ```bash
   git add .
   git commit -m "Your commit message"
   git push origin main
   ```

2. **Create a release:**
   ```bash
   # Using the release script (recommended)
   ./scripts/release.sh v1.0.0
   
   # Or manually
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

3. **Monitor the release:**
   - Check the GitHub Actions tab for build progress
   - The Docker image will be automatically published to `ghcr.io/YOUR_USERNAME/hello-world-web:v1.0.0`

### What Happens During a Release

1. **GitHub Actions Workflow** (`release.yml`) triggers on tag push
2. **Docker images** are built for multiple platforms (amd64, arm64)
3. **Docker images** are published to GitHub Container Registry
4. **GitHub Release** is created with usage instructions
5. **Multi-platform manifests** are created for easy deployment

## Configuration

### GitHub Actions

The `.github/workflows/release.yml` file configures:
- Docker image building for multiple platforms
- GitHub Container Registry publishing
- Automatic release creation
- Multi-platform manifest creation

### Docker

The `Dockerfile` uses:
- `nginx-unprivileged` base image for security
- Port 8080 for web traffic
- Static content from the `content/` directory

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
