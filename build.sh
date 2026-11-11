#!/bin/bash
# Build (and optionally push) joelgg/php-cli-mysqli.
#
# The tag is derived from PHP_VERSION in the Dockerfile: PHP_VERSION=8.5.12 produces
#   joelgg/php-cli-mysqli:php8.5.12        (amd64)
#   joelgg/php-cli-mysqli:php8.5.12-arm64  (arm64)
# plus the moving alias php8.5 / php8.5-arm64 for local use. CI pins the versioned tag.
set -euo pipefail

REPO="joelgg/php-cli-mysqli"
PUSH=false
NO_CACHE=""
PLATFORM="both"
ALIAS=true

usage() {
    echo "Usage: $0 [--push|-p] [--no-cache] [--platform amd64|arm64|both] [--no-alias]"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --push|-p) PUSH=true ;;
        --no-cache) NO_CACHE="--no-cache" ;;
        --no-alias) ALIAS=false ;;
        --platform)
            shift
            [[ "${1:-}" =~ ^(amd64|arm64|both)$ ]] || { echo "Invalid platform. Use: amd64, arm64, or both"; exit 1; }
            PLATFORM="$1"
            ;;
        --help|-h) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

PHP_VERSION=$(sed -n 's/^ARG PHP_VERSION=\([0-9][0-9.]*\)$/\1/p' Dockerfile)
[[ "$PHP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Could not read ARG PHP_VERSION=x.y.z from Dockerfile"; exit 1; }
TAG="php${PHP_VERSION}"
ALIAS_TAG="php${PHP_VERSION%.*}"

build() {  # build <platform> <suffix>
    local platform=$1 suffix=$2
    local image="${REPO}:${TAG}${suffix}"

    docker build --platform "linux/${platform}" --pull $NO_CACHE -t "$image" .

    # Refuse to tag/push if the image does not run the PHP version its tag claims.
    local actual
    actual=$(docker run --rm --platform "linux/${platform}" "$image" php -r 'echo PHP_VERSION;')
    [[ "$actual" == "$PHP_VERSION" ]] || { echo "$image runs PHP $actual, expected $PHP_VERSION"; exit 1; }
    echo "$image: PHP $actual"

    if [[ "$PUSH" == true ]] && docker manifest inspect "$image" >/dev/null 2>&1; then
        echo "$image already exists on the registry; tags are immutable, bump PHP_VERSION instead."
        exit 1
    fi

    local tags=("$image")
    if [[ "$ALIAS" == true ]]; then
        docker tag "$image" "${REPO}:${ALIAS_TAG}${suffix}"
        tags+=("${REPO}:${ALIAS_TAG}${suffix}")
    fi

    if [[ "$PUSH" == true ]]; then
        for t in "${tags[@]}"; do docker push "$t"; done
    fi
}

[[ "$PLATFORM" == "amd64" || "$PLATFORM" == "both" ]] && build amd64 ""
[[ "$PLATFORM" == "arm64" || "$PLATFORM" == "both" ]] && build arm64 "-arm64"

echo "Done. Point PHP_DOCKER_IMAGE in laravel-api/Jenkinsfile at ${REPO}:${TAG}."
