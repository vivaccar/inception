FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y \
  php7.4-fpm \
  php7.4-mysqli \
  curl \
  && apt clean

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/.
COPY ./tools/wp-install.sh .

RUN chmod +x ./wp-install.sh

RUN mkdir -p /var/www/html/wp-content/uploads \
  && chown -R www-data:www-data /var/www/html/wp-content \
  && find /var/www/html/wp-content/uploads -type d -exec chmod 755 {} \; \
  && find /var/www/html/wp-content/uploads -type f -exec chmod 644 {} \;

ENTRYPOINT ["sh", "./wp-install.sh"]