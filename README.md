# PHP 8.3 CLI with Imagick for TeamCity Testing

This Docker image is designed to facilitate testing PHP applications using TeamCity. It includes the required libraries and extensions, such as `libmagickwand-dev`, `libpng-dev`, `libjpeg-dev`, and `libwebp-dev`. Additionally, it installs and configures `pdo_mysql`, `mysqli`, and the Imagick extension.

## Dockerfile Summary

```Dockerfile
FROM php:8.3-cli

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
    libmagickwand-dev libpng-dev libjpeg-dev libwebp-dev

RUN rm /etc/ImageMagick-6/policy.xml

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd

RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN docker-php-ext-install mysqli pdo pdo_mysql exif gd

RUN curl -fL -o imagick.tgz 'https://pecl.php.net/get/imagick-3.7.0.tgz'; \
echo '5a364354109029d224bcbb2e82e15b248be9b641227f45e63425c06531792d3e *imagick.tgz' | sha256sum -c -; \
tar --extract --directory /tmp --file imagick.tgz imagick-3.7.0; \
grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php; \
test "$(grep -c '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php)" = '1'; \
sed -i -e 's!^//#endif$!#endif!' /tmp/imagick-3.7.0/Imagick.stub.php; \
grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php && exit 1 || :; \
docker-php-ext-install /tmp/imagick-3.7.0; \
rm -rf imagick.tgz /tmp/imagick-3.7.0;
```

## Features

- **PHP Version**: 8.3 CLI
- **Installed Libraries**:
  - `libmagickwand-dev`
  - `libpng-dev`
  - `libjpeg-dev`
  - `libwebp-dev`
- **PHP Extensions**:
  - `pdo_mysql` (configured with `mysqlnd`)
  - `mysqli` (configured with `mysqlnd`)
  - `exif`
  - `gd`
  - `imagick` (version 3.7.0)

## Usage

This image can be used in your TeamCity build configurations to test PHP applications that require the above-mentioned libraries and extensions. Simply use this image in your build steps where PHP execution is needed.

```yaml
version: '2'

services:
  php:
    image: joelgg/php-cli-mysqli:latest
    volumes:
      - .:/app
    working_dir: /app
    command: ["php", "your-script.php"]
```

## Building the Image

To rebuild or customize the image, you can clone the repository and use the following commands:

```sh
docker build -t joelgg/php-cli-mysqli .
docker push joelgg/php-cli-mysqli
```

## Contribution

If you'd like to contribute to improving or extending this image, feel free to open a pull request or issue on the GitHub repository. Contributions are always welcome.


# This is just the note for the future if I need to update this
# at the moment of upgrading to php 8.3 the imagick pecl install is broken.
# So I used the wordpress method [github link](https://github.com/docker-library/wordpress/blob/c37f27433bb26ea3ec3154fcb1f546d855afcff6/latest/php8.3/apache/Dockerfile)
# Don't forget the set the correct platform because by default is arm not amd
docker build -t joelgg/php-cli-mysqli:php8.3 . --platform linux/amd64
# than push the build
docker push joelgg/php-cli-mysqli:php8.3