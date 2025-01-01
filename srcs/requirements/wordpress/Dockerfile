FROM debian:bullseye

RUN apt-get update && apt-get -y install \
    wget \
    curl \
    php \
    php-cgi \
    php-mysql \
    php-fpm \
    php-pdo \
    php-gd \
    php-cli \
    php-mbstring \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

# Copy a config for php-fpm, if needed
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/

RUN mkdir /run/php

COPY tools/create_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create_wordpress.sh

WORKDIR /var/www/html/

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/create_wordpress.sh"]
CMD ["php-fpm7.4", "-F"]

