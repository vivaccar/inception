#!/bin/bash

cd /var/www/html

# Download CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sleep 5


./wp-cli.phar core download --allow-root

# create wp-config.php
./wp-cli.phar config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --allow-root

# unable ftp
echo "define('FS_METHOD', 'direct');" >> wp-config.php

# create wp
./wp-cli.phar core install --url="https://$WP_URL" --title=$WP_TITLE --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_MAIL --allow-root

# create user
./wp-cli.phar user $WP_USER $WP_USER_MAIL --role=subscriber --user_pass=$WP_USER_PASSWORD --allow-root

chown -R www-data:www-data /var/www/html/wp-content
chmod -R 755 /var/www/html/wp-content

php-fpm7.4 -F