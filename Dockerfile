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
    libmagickwand-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    librsvg2-dev \
    libheif-dev \
    default-mysql-client

# Install ImageMagick 7.1.1-43 from source
RUN cd /tmp && \
wget https://imagemagick.org/archive/ImageMagick-7.1.1-43.tar.gz && \
tar xvf ImageMagick-7.1.1-43.tar.gz && \
cd ImageMagick-* && \
./configure && \
make && \
make install && \
ldconfig /usr/local/lib && \
rm -rf /tmp/ImageMagick*

# Install Imagick 3.7.0 php extension
RUN curl -fL -o imagick.tgz 'https://pecl.php.net/get/imagick-3.7.0.tgz'; \
    echo '5a364354109029d224bcbb2e82e15b248be9b641227f45e63425c06531792d3e *imagick.tgz' | sha256sum -c -; \
    tar --extract --directory /tmp --file imagick.tgz imagick-3.7.0; \
    grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php; \
    test "$(grep -c '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php)" = '1'; \
    sed -i -e 's!^//#endif$!#endif!' /tmp/imagick-3.7.0/Imagick.stub.php; \
    grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php && exit 1 || :; \
    docker-php-ext-install /tmp/imagick-3.7.0; \
    rm -rf imagick.tgz /tmp/imagick-3.7.0;

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