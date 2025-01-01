#!/bin/sh

if [ -f wp-config.php ]; then
    echo "WordPress already installed."
else
    echo "Downloading WordPress..."
    wget http://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf latest.tar.gz wordpress

    # Insert DB credentials in wp-config
    sed -i "s/database_name_here/${MARIADB_DATABASE}/" wp-config-sample.php
    sed -i "s/username_here/${MARIADB_USER}/"         wp-config-sample.php
    sed -i "s/password_here/${MARIADB_PASS}/"         wp-config-sample.php
    sed -i "s/localhost/${MARIADB_HOST}/"             wp-config-sample.php

    cp wp-config-sample.php wp-config.php

    # Wait until DB is up (simple check - might suffice for 42)
    echo "Waiting for MariaDB to be ready..."
    until mysqladmin ping -h"${MARIADB_HOST}" -u"${MARIADB_USER}" -p"${MARIADB_PASS}" --silent; do
      sleep 2
    done
    echo "MariaDB is up; proceeding."

    # Run WP-CLI to finalize the WP installation
    wp core install \
      --url="${WP_URL}" \
      --title="${WP_TITLE}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PASS}" \
      --admin_email="${WP_ADMIN_EMAIL}" \
      --skip-email

    # If you want a non-admin user too:
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}"
fi

# Hand over to php-fpm (CMD)
exec "$@"
