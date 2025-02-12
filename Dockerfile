FROM php:8.3-cli

# Set memory limit to 2G
RUN echo "memory_limit = 2G" >> /usr/local/etc/php/conf.d/memory.ini

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    wget \
    build-essential \
    pkg-config \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    librsvg2-dev \
    libheif-dev \
    default-mysql-client

# Install ImageMagick 7 from source
RUN cd /tmp && \
wget https://imagemagick.org/archive/ImageMagick.tar.gz && \
tar xvf ImageMagick.tar.gz && \
cd ImageMagick-* && \
./configure && \
make && \
make install && \
ldconfig /usr/local/lib && \
rm -rf /tmp/ImageMagick*

# Install Imagick extension for PHP (compatible with ImageMagick 7)
RUN pecl install imagick && \
    docker-php-ext-enable imagick

# Configure and install PHP extensions
RUN docker-php-ext-configure gd \
--with-jpeg \
--with-webp \
&& docker-php-ext-install gd

# RUN pecl install pcov && docker-php-ext-enable pcov

# Configure PHP extensions
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd
RUN docker-php-ext-install mysqli pdo pdo_mysql exif

# Create user and group jenkins with UID 1000
RUN groupadd -g 1000 jenkins && useradd -u 1000 -g jenkins -m jenkins

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer