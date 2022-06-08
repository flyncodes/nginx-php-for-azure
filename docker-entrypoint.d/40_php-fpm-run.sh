#!/bin/bash

mkdir -p /run/php && chown -R www-data:www-data /run/php
exec /usr/sbin/php-fpm${PHP_VERSION} -D --pid=/tmp/php-fpm.pid
