FROM php:8.0-cli

RUN apt-get update && \
    apt-get install -y \
    libzip-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libmagickwand-dev --no-install-recommends

RUN pecl install imagick

RUN docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd

RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN docker-php-ext-install gd mysqli pdo pdo_mysql exif

RUN docker-php-ext-enable imagick
