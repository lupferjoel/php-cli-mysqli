FROM php:8.5-cli

# Add PHP configurations
RUN { \
    echo 'expose_php = On'; \
    echo 'display_errors = On'; \
    echo 'display_startup_errors = On'; \
    echo 'log_errors = On'; \
    echo 'error_reporting = E_ALL'; \
    echo 'memory_limit = 2G'; \
} > /usr/local/etc/php/conf.d/docker-php-config.ini

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    build-essential \
    pkg-config \
    libmagickwand-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    librsvg2-dev \
    libheif-dev \
    default-mysql-client \
    ghostscript-x \
    && rm -rf /var/lib/apt/lists/*

# Install Imagick 3.8.1 (3.7.x fails on PHP 8.5: removed php_smart_string.h)
RUN printf "\n" | pecl install imagick-3.8.1 \
    && docker-php-ext-enable imagick

# Configure and install all PHP extensions in one layer
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        exif \
    && pecl install pcov \
    && docker-php-ext-enable pcov

# Create user and group jenkins with UID 1000
RUN groupadd -g 1000 jenkins && \
    useradd -u 1000 -g jenkins -m jenkins

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Switch to non-root user
USER jenkins

# Set working directory
WORKDIR /var/www/html