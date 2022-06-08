FROM nginx:stable

WORKDIR /var/www/html

ENV PHP_VERSION=8.1 \
    NGINX_PORT=8080 \
    NGINX_VIRTUAL_HOST=$DOCKER_HOST \
    HOME=/var/www/html \
    TZ=Europe/London

RUN apt update -y && apt install -y apt-transport-https software-properties-common curl
RUN curl -sSL https://packages.sury.org/php/README.txt | bash -x
RUN apt update -y && apt upgrade -y

RUN apt install -y php$PHP_VERSION-fpm php$PHP_VERSION-mysql \
    php$PHP_VERSION-common php$PHP_VERSION-soap \
	  php$PHP_VERSION-gd php$PHP_VERSION-xml php$PHP_VERSION-xmlrpc \ 
    php$PHP_VERSION-curl nano net-tools zip unzip openssh-server

RUN mv "/etc/php/$PHP_VERSION/fpm/php.ini-production" "/etc/php/$PHP_VERSION/fpm/php.ini"
COPY    php.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-custom.ini
COPY    php-cli.ini /etc/php/$PHP_VERSION/cli/conf.d/99-custom.ini

RUN phpenmod -v $PHP_VERSION -s ALL pdo_mysql gd curl xml zip pdo_sqlite

COPY default.conf.template etc/nginx/templates/

RUN apt -y --purge autoremove && apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
