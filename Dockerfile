FROM php:8.3-cli

RUN apt-get update && \
    apt-get install -y \
    libmagickwand-dev --no-install-recommends

RUN rm /etc/ImageMagick-6/policy.xml

RUN pecl install imagick

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd

RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN docker-php-ext-install mysqli pdo pdo_mysql exif

RUN docker-php-ext-enable imagick
