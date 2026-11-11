# PHP 8.5 CLI with Imagick for TeamCity Testing

This Docker image is designed to facilitate testing PHP applications using TeamCity. It includes the required libraries and extensions, such as `libmagickwand-dev`, `libpng-dev`, `libjpeg-dev`, and `libwebp-dev`. Additionally, it installs and configures `pdo_mysql`, `mysqli`, `imagick`, and `pcov`.

## Dockerfile Summary

```Dockerfile
ARG PHP_VERSION=8.5.12
FROM php:${PHP_VERSION}-cli

# PHP config: verbose errors, 2G memory limit
# Packages: git, unzip, ImageMagick/GD deps, mysql client, ghostscript
# imagick 3.8.1 via pecl (3.7.x fails on PHP 8.5)
# Extensions: gd, mysqli, pdo, pdo_mysql, exif, pcov
# Non-root jenkins user (UID 1000), Composer installed
```

## Features

- **PHP Version**: 8.5 CLI (exact version in `ARG PHP_VERSION` in the `Dockerfile`)
- **Installed Libraries**:
  - `libmagickwand-dev`
  - `libpng-dev`
  - `libjpeg-dev`
  - `libwebp-dev`
  - `librsvg2-dev`
  - `libheif-dev`
- **PHP Extensions**:
  - `pdo_mysql` (configured with `mysqlnd`)
  - `mysqli` (configured with `mysqlnd`)
  - `exif`
  - `gd` (with JPEG and WebP support)
  - `imagick` (version 3.8.1)
  - `pcov`
- **Other**:
  - Composer
  - Non-root `jenkins` user (UID 1000)

## Usage

This image can be used in your TeamCity build configurations to test PHP applications that require the above-mentioned libraries and extensions. Use a full version tag (e.g. `php8.5.12`) rather than `latest` or `php8.5`.

```yaml
version: '2'

services:
  php:
    image: joelgg/php-cli-mysqli:php8.5.12
    volumes:
      - .:/app
    working_dir: /app
    command: ["php", "your-script.php"]
```

For arm64 hosts, use the `-arm64` suffix (e.g. `joelgg/php-cli-mysqli:php8.5.12-arm64`).

## Tags

Every PHP release gets its own immutable tag, derived from `ARG PHP_VERSION` in the `Dockerfile`:

| Tag | Arch | Use |
|---|---|---|
| `php8.5.12` | amd64 | CI (pinned in `laravel-api/Jenkinsfile`) |
| `php8.5.12-arm64` | arm64 | CI on arm64 agents |
| `php8.5` / `php8.5-arm64` | | moving alias to the newest 8.5 build, for local use only |

CI pins the full version on purpose: a new image never changes CI by itself, every agent pulls the
new tag on its first run (it is missing locally), and the PHP version CI uses is visible in the
Jenkinsfile history. The `laravel-api` Jenkinsfile therefore does not use `alwaysPull`.

## Releasing a new PHP version

1. Bump `ARG PHP_VERSION` in the `Dockerfile` (e.g. `8.5.12` → `8.5.13`; `php:<version>-cli` must
   exist on Docker Hub).
2. Build and push both platforms:

   ```sh
   ./build.sh --push
   ```

   `build.sh` derives the tag from the Dockerfile, checks that `php -v` inside the image reports that
   version, refuses to overwrite a tag that already exists on Docker Hub, and also moves the `php8.5`
   alias. Options: `--platform amd64|arm64|both`, `--no-cache`, `--no-alias`, `--help`.
3. In `laravel-api`, set `PHP_DOCKER_IMAGE` in the `Jenkinsfile` to the new tag
   (`docker-cache.gutsgusto.dev/joelgg/php-cli-mysqli:php8.5.13`) and open a PR. That PR's own build
   is the test of the new image.

## Contribution

If you'd like to contribute to improving or extending this image, feel free to open a pull request or issue on the GitHub repository. Contributions are always welcome.

## Upgrade notes

When upgrading PHP versions, imagick often needs a newer PECL release. On PHP 8.5, imagick 3.7.x fails because `php_smart_string.h` was removed — use 3.8.1 or later.

Build with `./build.sh`, not with a bare `docker build`: Docker defaults to the host architecture
(arm64 on Apple Silicon), and `build.sh` sets the platform and tag for you.
