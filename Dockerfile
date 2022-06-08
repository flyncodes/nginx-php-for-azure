FROM nginx:stable

WORKDIR /var/www/html

ENV PHP_VERSION=8.1 \
    NGINX_PORT=8080 \
    NGINX_VIRTUAL_HOST=$DOCKER_HOST \
    HOME=/var/www/html \
    TZ=Europe/London

# Enable PHP repository
RUN curl -sSL https://packages.sury.org/php/README.txt | bash -x

RUN apt install -y php$PHP_VERSION-fpm php$PHP_VERSION-mysql \
    php$PHP_VERSION-common php$PHP_VERSION-soap \
	  php$PHP_VERSION-gd php$PHP_VERSION-xml php$PHP_VERSION-xmlrpc \ 
    php$PHP_VERSION-curl nano net-tools zip unzip openssh-server

COPY php.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-custom.ini
COPY php-cli.ini /etc/php/$PHP_VERSION/cli/conf.d/99-custom.ini

RUN phpenmod -v $PHP_VERSION -s ALL pdo_mysql gd curl xml zip pdo_sqlite

COPY php-pool.conf /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
RUN sed -i "s|@@PHP_VERSION@@|$PHP_VERSION|" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

COPY default.conf.template /etc/nginx/templates/
COPY docker-entrypoint.d/ /docker-entrypoint.d/
RUN chmod -v +x /docker-entrypoint.d/*.sh

RUN apt -y --purge autoremove && apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
