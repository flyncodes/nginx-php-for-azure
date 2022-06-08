FROM nginx:stable

WORKDIR /var/www/html

ENV PHP_VERSION=8.1 \
    NGINX_PORT=8080 \
    NGINX_VIRTUAL_HOST=$DOCKER_HOST \
    HOME=/var/www/html \
    TZ=Europe/London

# Enable PHP repository
RUN curl -sSL https://packages.sury.org/php/README.txt | bash -x

# Install PHP packages and SSH server
RUN apt install -y php$PHP_VERSION-fpm php$PHP_VERSION-mysql \
    php$PHP_VERSION-common libgmp-dev php$PHP_VERSION-gmp php$PHP_VERSION-gd \
    php$PHP_VERSION-bcmath php$PHP_VERSION-xml php$PHP_VERSION-mbstring \ 
    php$PHP_VERSION-curl nano net-tools zip unzip openssh-server

# Copy custom PHP ini
COPY php.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-custom.ini
COPY php-cli.ini /etc/php/$PHP_VERSION/cli/conf.d/99-custom.ini

# Enable PHP packages
RUN phpenmod -v $PHP_VERSION -s ALL mbstring pdo_mysql gd gmp curl bcmath xml

# Copy custom PHP pool config
COPY php-fpm.conf /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
RUN sed -i "s|@@PHP_VERSION@@|$PHP_VERSION|" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
RUN ln -sf /dev/stdout /var/log/php$PHP_VERSION-fpm.log

# Setup SSH access
RUN echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# Copy nginx site and scripts to be ran on docker startup
COPY default.conf.template /etc/nginx/templates/
COPY docker-entrypoint.d/ /docker-entrypoint.d/
RUN chmod -v +x /docker-entrypoint.d/*.sh

# Cleanup
RUN apt -y --purge autoremove && apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
