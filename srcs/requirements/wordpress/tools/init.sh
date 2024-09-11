#!/bin/bash

cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

sed -i "s|define( 'DB_NAME', 'votre_nom_de_bdd' );|define( 'DB_NAME', '$DB_NAME' );|" /var/www/wordpress/wp-config.php
sed -i "s|define( 'DB_USER', 'votre_utilisateur_de_bdd' );|define( 'DB_USER', '$DB_USER' );|" /var/www/wordpress/wp-config.php
sed -i "s|define( 'DB_PASSWORD', 'votre_mdp_de_bdd' );|define( 'DB_PASSWORD', '$DB_PASSWORD' );|" /var/www/wordpress/wp-config.php
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'mariadb' );/" /var/www/wordpress/wp-config.php

until wp db check --allow-root --path=/var/www/wordpress; do
    sleep 5
    echo "Retrying..."
done

wp core install --allow-root --path=/var/www/wordpress --url=$DOMAIN --title=$TITLE --admin_user=$ADMINUSER --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL
wp user create --allow-root --path=/var/www/wordpress $USER_USER $USER_EMAIL --user_pass=$USER_PASSWORD --display_name=$USER_USER


/usr/sbin/php-fpm7.4 -F