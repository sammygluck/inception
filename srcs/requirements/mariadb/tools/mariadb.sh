#!/bin/sh

# Start MariaDB in the background
mysqld_safe --skip-networking &
sleep 5

# Modify bind-address to allow external connections
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB to apply bind-address change
killall mysqld
mysqld_safe --skip-networking &
sleep 5


if [ ! -d "/var/lib/mysql/$MARIADB_DATABASE" ]; then
# Secure MariaDB by executing SQL commands
mysql -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASS';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
EOSQL

# Create database and user
mysql -uroot -p"$MARIADB_ROOT_PASS" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;
    CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASS';
    GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';
    FLUSH PRIVILEGES;
EOSQL

# Import the WordPress SQL dump
mysql -uroot -p"$MARIADB_ROOT_PASS" "$MARIADB_DATABASE" < /usr/local/bin/wordpress.sql

else
	echo "Database already initialized. Skipping SQL dump import."
fi

# Stop the background MariaDB process
mysqladmin -uroot -p"$MARIADB_ROOT_PASS" shutdown

# Start MariaDB in the foreground
exec "$@"

