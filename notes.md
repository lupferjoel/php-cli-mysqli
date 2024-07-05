# This is just the note for the future if I need to update this
# at the moment of upgrading to php 8.3 the imagick pecl install is broken.
# So I used the wordpress method [github link](https://github.com/docker-library/wordpress/blob/c37f27433bb26ea3ec3154fcb1f546d855afcff6/latest/php8.3/apache/Dockerfile)
# Don't forget the set the correct platform because by default is arm not amd
docker build -t joelgg/php-cli-mysqli:php8.3-amd64 . --platform linux/amd64
# than push the build
docker push joelgg/php-cli-mysqli:php8.3-amd64