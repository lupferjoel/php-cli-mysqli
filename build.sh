#!/bin/bash

# Build the image for linux/amd64
docker build -t joelgg/php-cli-mysqli:jenkins . --platform linux/amd64 

# Push the default as amd64
docker push joelgg/php-cli-mysqli:jenkins

# Build the image for linux/arm64
docker build -t joelgg/php-cli-mysqli:jenkins-arm64 . --platform linux/arm64

# Push the image as arm64
docker push joelgg/php-cli-mysqli:jenkins-arm64