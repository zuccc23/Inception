#!/bin/bash

sleep 15
while ! nc -z mariadb 3306; do
    echo "MariaDB is unavailable - waiting 2 seconds..."
    sleep 2
done

echo "MariaDB is ready. Proceeding with WordPress setup."

cd var/www/html

if [ -f "wp-config.php" ]; then
    echo "WordPress is already configured. Starting PHP-FPM..."
   
else
    echo "Configuring WordPress..."
		
		#download wp core files
			#we must allow root bc wp usually refuses it
		wp core download --allow-root
		echo "WordPress core downloaded ---> starting config create."
		#create our config file (wp-config.php)
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

#--test-- change port 443
    # wp option update siteurl "https://localhost:8443" --allow-root
    # wp option update home "https://localhost:8443" --allow-root
    #--test--

#start PHP-FPM in background
echo "Starting PHP-FPM 8.2..."

################# WEBSITE CUSTOM

# Update the content of post ID 1 (the default Hello World post)
wp post update 1 --post_title='Orange Juice' --post_content='This is a fresh glass of orange juice.' --allow-root

# # Allow people to post comments on new articles
# wp option update default_comment_status "open" --allow-root

# # Optional: Disable the requirement that users must be registered to comment
# wp option update comment_registration 0 --allow-root

# # Optional: Disable the requirement that an admin must manually approve every comment
# wp option update comment_moderation 0 --allow-root

##################
exec /usr/sbin/php-fpm8.2 -F