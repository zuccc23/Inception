#!/bin/bash

#path for marias data
MARIADB_DATA_DIR="/var/lib/mysql"

#checks if mariadb has been init:
    #when properly init, it always creates the internal sys table 'mysql'
if [ -d "$MARIADB_DATA_DIR/mysql" ]; then
    echo "MariaDB data directory already exixst, skipping setup"
else
    echo "Initializing MariaDB data directory..."

    #INIT MARIADBj
        #creates internal table
    mysql_install_db --user=mysql --datadir="$MARIADB_DATA_DIR"
        #launches maria in safe mode:restarts if it crashes, etc
        #and runs in the background so the rest of the script can still execute
        #the server is ran temporarily bc well need to use mysql commands to add users, etc
    /usr/bin/mysqld_safe &
        #waits for maria to start, otherwise the next commands wont work
    sleep 5

    #CREATE SQL COMMANDS
        #run the following commands as root
        #we use heredocs to feed the commands to mysql

        #security commands-->
    mysql -u root <<EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
EOF
        #-->sets pw for maria root user
        #deletes users with no username
        #delete root accounts that can connect from anywhere but localhost, etc
        #deletes test db bc useless and insecure
        #removes permissions related to test db

        #create wordpress database-->
    mysql -u root -p"$DB_ROOT_PASSWORD" <<EOF
    CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF

        #create wordpress user/permissions-->
    mysql -u root -p"$DB_ROOT_PASSWORD" <<EOF
    CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
EOF
        #-->grants full access only to wordpress db

        #create admin user wordpress-->
    mysql -u root -p"$DB_ROOT_PASSWORD" <<EOF
    CREATE USER '$DB_ADMIN_USER'@'%' IDENTIFIED BY '$DB_ADMIN_PASSWORD';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_ADMIN_USER'@'%' WITH GRANT OPTION;
EOF

    #apply changes and shut down temporary server
    mysql -u root -p"$DB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
    mysqladmin -u root -p"$DB_ROOT_PASSWORD" shutdown

    echo "MariaDB setup complete!"
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

#restart mariadb in foreground
exec mariadbd --user=mysql --datadir="$MARIADB_DATA_DIR"