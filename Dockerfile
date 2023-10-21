FROM nginx:stable

WORKDIR /var/www/html

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION:-8.1}

ENV PORT=8080 \
    NGINX_VIRTUAL_HOST=_ \
    HOME=/var/www/html \
    TZ=Europe/London

# Enable PHP repository
RUN curl -sSL https://packages.sury.org/php/README.txt | bash -x

# Install PHP packages and SSH server
RUN apt install -y php$PHP_VERSION-fpm php$PHP_VERSION-mysql php$PHP_VERSION-sqlite3 \
    php$PHP_VERSION-common libgmp-dev php$PHP_VERSION-gmp php$PHP_VERSION-gd \
    php$PHP_VERSION-bcmath php$PHP_VERSION-xml php$PHP_VERSION-mbstring \ 
    php$PHP_vERSION-imap php$PHP_VERSION-curl nano net-tools zip unzip openssh-server

# Clean packagge metadata
RUN rm -rf /var/lib/apt/lists/* && apt clean

# Copy custom PHP ini
COPY php.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-custom.ini
COPY php-cli.ini /etc/php/$PHP_VERSION/cli/conf.d/99-custom.ini

# Enable PHP packages
RUN phpenmod -v $PHP_VERSION -s ALL mbstring sqlite3 pdo_mysql pdo_sqlite gd gmp curl bcmath xml imap

# Copy custom PHP pool config
COPY php-fpm.conf /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
RUN sed -i "s|@@PHP_VERSION@@|$PHP_VERSION|" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

# Setup SSH access
RUN echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# Copy nginx site and scripts to be ran on docker startup
COPY default.conf.template /etc/nginx/templates/
COPY docker-entrypoint.d/ /docker-entrypoint.d/
RUN chmod -v +x /docker-entrypoint.d/*.sh

# Cleanup
RUN apt -y --purge autoremove && apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
