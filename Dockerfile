FROM php:7.4-apache

ENV LIBRDKAFKA_VERSION v1.5.0
ENV BUILD_DEPS autoconf freetds-dev git libzip-dev

RUN apt-get update && apt-get install -y $BUILD_DEPS

RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/

RUN cd /tmp \
    && git clone --branch ${LIBRDKAFKA_VERSION} --depth 1 https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install

RUN pecl install rdkafka redis \
    && docker-php-ext-enable rdkafka redis \
    && docker-php-ext-install pdo_mysql pdo_dblib bcmath zip

RUN apt remove -y $BUILD_DEPS && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/librdkafka

RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf \
    && a2enmod rewrite