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
