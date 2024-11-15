FROM php:8.3-cli

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends default-mysql-client git zip

# Create user and group jenkins with UID 1000
RUN groupadd -g 1000 jenkins && useradd -u 1000 -g jenkins -m jenkins