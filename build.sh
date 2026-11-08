#!/bin/bash

# Initialize variables
PUSH=false
NO_CACHE=""
PLATFORM="both"
TAG=""

usage() {
    echo "Usage: $0 --tag <tag> [--push|-p] [--no-cache] [--platform amd64|arm64|both]"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --push|-p) PUSH=true ;;
        --no-cache) NO_CACHE="--no-cache" ;;
        --tag|-t)
            shift
            TAG="$1"
            ;;
        --platform)
            shift
            if [[ "$1" =~ ^(amd64|arm64|both)$ ]]; then
                PLATFORM="$1"
            else
                echo "Invalid platform. Use: amd64, arm64, or both"
                exit 1
            fi
            ;;
        --help|-h) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

if [[ -z "$TAG" ]]; then
    echo "Error: --tag is required"
    usage
fi

# Build the image for linux/amd64
if [[ "$PLATFORM" == "amd64" || "$PLATFORM" == "both" ]]; then
    if docker build -t "joelgg/php-cli-mysqli:${TAG}" . --platform linux/amd64 $NO_CACHE; then
        # Push if flag is set and build was successful
        if [ "$PUSH" = true ]; then
            docker push "joelgg/php-cli-mysqli:${TAG}"
        fi
    else
        echo "amd64 build failed"
        exit 1
    fi
fi

# Build the image for linux/arm64
if [[ "$PLATFORM" == "arm64" || "$PLATFORM" == "both" ]]; then
    if docker build -t "joelgg/php-cli-mysqli:${TAG}-arm64" . --platform linux/arm64 $NO_CACHE; then
        # Push if flag is set and build was successful
        if [ "$PUSH" = true ]; then
            docker push "joelgg/php-cli-mysqli:${TAG}-arm64"
        fi
    else
        echo "arm64 build failed"
        exit 1
    fi
fi