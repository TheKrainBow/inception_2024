#!/bin/bash

cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_USER=$(awk -F: '/admin/ {print $1}' /run/secrets/credentials)
ADMIN_PASSWORD=$(awk -F: '/admin/ {print $2}' /run/secrets/credentials)
ADMIN_EMAIL=$(awk -F: '/admin/ {print $3}' /run/secrets/credentials)
USER_USER=$(awk -F: '/author/ {print $1}' /run/secrets/credentials)
USER_PASSWORD=$(awk -F: '/author/ {print $2}' /run/secrets/credentials)
USER_EMAIL=$(awk -F: '/author/ {print $3}' /run/secrets/credentials)

sed -i "s|define( 'DB_NAME', 'votre_nom_de_bdd' );|define( 'DB_NAME', '$DB_NAME' );|" /var/www/wordpress/wp-config.php
sed -i "s|define( 'DB_USER', 'votre_utilisateur_de_bdd' );|define( 'DB_USER', '$DB_USER' );|" /var/www/wordpress/wp-config.php
sed -i "s|define( 'DB_PASSWORD', 'votre_mdp_de_bdd' );|define( 'DB_PASSWORD', '$DB_PASSWORD' );|" /var/www/wordpress/wp-config.php
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'mariadb' );/" /var/www/wordpress/wp-config.php

until wp db check --allow-root --path=/var/www/wordpress; do
    sleep 5
    echo "Retrying..."
done

wp core install --allow-root --path=/var/www/wordpress --url=$DOMAIN --title=$TITLE --admin_user=$ADMIN_USER --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL
wp user create --allow-root --path=/var/www/wordpress $USER_USER $USER_EMAIL --user_pass=$USER_PASSWORD --display_name=$USER_USER


/usr/sbin/php-fpm7.4 -F