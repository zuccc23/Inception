#!/bin/bash

echo ">>> Starting MariaDB service..."

service mariadb start

sleep 5

mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -u root -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"

mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"

mysql -u root -e "FLUSH PRIVILEGES;"

echo ">>> Shutting down temporary MariaDB..."

mysqladmin -u root -p$DB_ROOT_PASSWORD shutdown

echo ">>> Final launch of MariaDB as PID 1..."

exec mysqld_safe