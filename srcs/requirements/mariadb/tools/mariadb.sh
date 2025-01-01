#!/bin/sh

# Start MariaDB in the background (with no networking so we can init)
mysqld_safe --skip-networking &
sleep 5

# Enable external connections inside Docker (i.e., 0.0.0.0)
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB to apply config changes
killall mysqld
mysqld_safe --skip-networking &
sleep 5

if [ ! -d "/var/lib/mysql/${MARIADB_DATABASE}" ]; then
    echo "Initializing new MariaDB database: $MARIADB_DATABASE"

    # Secure the root user and clean defaults
    mysql -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASS}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        FLUSH PRIVILEGES;
    EOSQL
    
    # Create your WP user / DB
    mysql -uroot -p"${MARIADB_ROOT_PASS}" <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASS}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
    EOSQL

    echo "DB initialization complete."
else
    echo "Database already exists; skipping init."
fi

# Stop background MySQL
mysqladmin -uroot -p"${MARIADB_ROOT_PASS}" shutdown

# Finally run MySQL in the foreground
exec "$@"


