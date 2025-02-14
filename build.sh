#!/bin/bash

# Initialize variables
PUSH=false
NO_CACHE=""
PLATFORM="both"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --push|-p) PUSH=true ;;
        --no-cache) NO_CACHE="--no-cache" ;;
        --platform) 
            shift
            if [[ "$1" =~ ^(amd64|arm64|both)$ ]]; then
                PLATFORM="$1"
            else
                echo "Invalid platform. Use: amd64, arm64, or both"
                exit 1
            fi
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Build the image for linux/amd64
if [[ "$PLATFORM" == "amd64" || "$PLATFORM" == "both" ]]; then
    if docker build -t joelgg/php-cli-mysqli:jenkins . --platform linux/amd64 $NO_CACHE; then
        # Push if flag is set and build was successful
        if [ "$PUSH" = true ]; then
            docker push joelgg/php-cli-mysqli:jenkins
        fi
    else
        echo "amd64 build failed"
        exit 1
    fi
fi

# Build the image for linux/arm64
if [[ "$PLATFORM" == "arm64" || "$PLATFORM" == "both" ]]; then
    if docker build -t joelgg/php-cli-mysqli:jenkins-arm64 . --platform linux/arm64 $NO_CACHE; then
        # Push if flag is set and build was successful
        if [ "$PUSH" = true ]; then
            docker push joelgg/php-cli-mysqli:jenkins-arm64
        fi
    else
        echo "arm64 build failed"
        exit 1
    fi
fi