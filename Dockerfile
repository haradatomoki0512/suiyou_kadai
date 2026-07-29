FROM php:8.4-fpm-alpine AS php

RUN apk add -U --no-cache curl-dev
RUN docker-php-ext-install curl

RUN docker-php-ext-install exif

RUN apk add autoconf g++ make

RUN pecl install apcu
RUN docker-php-ext-enable apcu

RUN apk add -U --no-cache libpng-dev
RUN docker-php-ext-configure gd
RUN docker-php-ext-install gd

RUN docker-php-ext-install pdo_mysql

RUN install -o www-data -g www-data -d /var/www/upload/image/

RUN echo "upload_max_filesize = 5M" > /usr/local/etc/php/conf.d/uploads.ini
RUN echo "post_max_size = 5M" >> /usr/local/etc/php/conf.d/uploads.ini
