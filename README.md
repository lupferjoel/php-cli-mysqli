# PHP 8.5 CLI with Imagick for TeamCity Testing

This Docker image is designed to facilitate testing PHP applications using TeamCity. It includes the required libraries and extensions, such as `libmagickwand-dev`, `libpng-dev`, `libjpeg-dev`, and `libwebp-dev`. Additionally, it installs and configures `pdo_mysql`, `mysqli`, `imagick`, and `pcov`.

## Dockerfile Summary

```Dockerfile
FROM php:8.5-cli

# PHP config: verbose errors, 2G memory limit
# Packages: git, unzip, ImageMagick/GD deps, mysql client, ghostscript
# imagick 3.8.1 via pecl (3.7.x fails on PHP 8.5)
# Extensions: gd, mysqli, pdo, pdo_mysql, exif, pcov
# Non-root jenkins user (UID 1000), Composer installed
```

## Features

- **PHP Version**: 8.5 CLI
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

This image can be used in your TeamCity build configurations to test PHP applications that require the above-mentioned libraries and extensions. Use a version tag rather than `latest`.

```yaml
version: '2'

services:
  php:
    image: joelgg/php-cli-mysqli:php8.5
    volumes:
      - .:/app
    working_dir: /app
    command: ["php", "your-script.php"]
```

For arm64 hosts, use the `-arm64` suffix (e.g. `joelgg/php-cli-mysqli:php8.5-arm64`).

## Building the Image

Use `build.sh` with a required tag. By default it builds both `linux/amd64` and `linux/arm64`.

```sh
# Build both platforms
./build.sh --tag php8.5

# Build and push
./build.sh --tag php8.5 --push

# amd64 only
./build.sh --tag php8.5 --platform amd64 -p
```

This produces:

- `joelgg/php-cli-mysqli:<tag>` for amd64
- `joelgg/php-cli-mysqli:<tag>-arm64` for arm64

Run `./build.sh --help` for all options.

## Contribution

If you'd like to contribute to improving or extending this image, feel free to open a pull request or issue on the GitHub repository. Contributions are always welcome.

## Upgrade notes

When upgrading PHP versions, imagick often needs a newer PECL release. On PHP 8.5, imagick 3.7.x fails because `php_smart_string.h` was removed — use 3.8.1 or later.

Always set the target platform explicitly when building by hand; Docker defaults to the host architecture (often arm64 on Apple Silicon):

```sh
docker build -t joelgg/php-cli-mysqli:php8.5 . --platform linux/amd64
docker push joelgg/php-cli-mysqli:php8.5
```

Prefer `./build.sh --tag php8.5` for multi-platform builds.
