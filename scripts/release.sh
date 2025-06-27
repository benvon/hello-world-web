#!/bin/bash

# Release script for hello-world-web
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh v1.0.0

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

VERSION=$1

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$ ]]; then
    echo "Error: Version must be in format vX.Y.Z or vX.Y.Z-stuff (e.g., v1.0.0 or v1.0.0-beta.1)"
    exit 1
fi

echo "Creating release for version: $VERSION"

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Warning: You're not on the main branch. Current branch: $CURRENT_BRANCH"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working directory is not clean. Please commit or stash changes first."
    exit 1
fi

# Create and push tag
echo "Creating tag: $VERSION"
git tag -a "$VERSION" -m "Release $VERSION"

echo "Pushing tag to remote..."
git push origin "$VERSION"

echo "Release $VERSION has been created and pushed!"
echo "GitHub Actions will now build and publish the Docker image to GitHub Container Registry."
echo "You can monitor the progress at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/actions" 