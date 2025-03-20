#!/bin/bash

cd /var/www/html

# Baixar o wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sleep 5

# Baixar o WordPress
./wp-cli.phar core download --allow-root

# Criar o wp-config.php
./wp-cli.phar config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --allow-root

# Desabilitar a solicitação de FTP
echo "define('FS_METHOD', 'direct');" >> wp-config.php

./wp-cli.phar core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_MAIL --allow-root

# Criar o usuário admin
./wp-cli.phar user create cr7 $WP_USER_MAIL --role=subscriber --user_pass=$WP_USER_PASSWORD --allow-root

chown -R www-data:www-data /var/www/html/wp-content
chmod -R 755 /var/www/html/wp-content

# Iniciar o PHP-FPM
php-fpm7.4 -F