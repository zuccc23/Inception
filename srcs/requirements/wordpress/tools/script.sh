#!/bin/bash

while ! nc -z mariadb 3306; do
    echo "MariaDB is unavailable - waiting 2 seconds..."
    sleep 2
done

echo "MariaDB is ready. Proceeding with WordPress setup."

if [ -f "wp-config.php" ]; then
    echo "WordPress is already configured. Starting PHP-FPM..."
   
else
    echo "Configuring WordPress..."
		
		#download wp core files
			#we must allow root bc wp usually refuses it
		wp core download --allow-root
		
		#create out config file (wp-config.php)
			#and connect to mariadb by giving db info
		wp config create --allow-root \
    --dbname=$DB_NAME \
    --dbuser=$DB_USER \
    --dbpass=$DB_PASSWORD \
    --dbhost=mariadb:3306
    
    #wordpress setup
	    #creates admin user etc
    wp core install --allow-root \
    --url=$DOMAIN_NAME \
    --title=$SITE_TITLE \
    --admin_user=$DB_ADMIN_USER \
    --admin_password=$DB_ADMIN_PASSWORD \
    --admin_email=$DB_ADMIN_EMAIL
    
    #create regular user
    wp user create $USER_LOGIN $USER_EMAIL --allow-root \
        --role=author \
        --user_pass=$USER_PASSWORD

    echo "WordPress installation successful."
fi

#webserver permissions
chown -R www-data:www-data /var/www/html

#start PHP-FPM in background
echo "Starting PHP-FPM 8.2..."
exec /usr/sbin/php-fpm8.2 -F