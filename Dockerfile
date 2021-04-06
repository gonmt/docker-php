FROM php:8-fpm-alpine

RUN apk update && apk add --no-cache $PHPIZE_DEPS --update git php8-pear composer freetds freetds-dev libzip-dev \
    && pecl install xdebug redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install pdo pdo_mysql pdo_dblib zip

WORKDIR /var/www/

RUN	echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini

ENV LIBRDKAFKA_VERSION v1.5.0
ENV BUILD_DEPS \
  autoconf \
        bash \
        build-base \
        git \
        pcre-dev

RUN apk --no-cache --virtual .build-deps add ${BUILD_DEPS} \
    && cd /tmp \
    && git clone \
        --branch ${LIBRDKAFKA_VERSION} \
        --depth 1 \
        https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install \
    && pecl install rdkafka \
    && docker-php-ext-enable rdkafka \
    && rm -rf /tmp/librdkafka \
    && apk del .build-deps

RUN deluser www-data \
    && adduser -D -s /bin/ash -u 1000 www-data