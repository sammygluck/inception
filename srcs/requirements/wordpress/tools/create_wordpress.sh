#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if WordPress is installed
is_wordpress_installed() {
    wp core is-installed --allow-root
}

# Function to wait for MariaDB to be ready
wait_for_mariadb() {
    echo "Waiting for MariaDB to be ready..."
    until mysqladmin ping -h"${MARIADB_HOST}" -u"${MARIADB_USER}" -p"${MARIADB_PASS}" --silent; do
        echo "MariaDB is unavailable - sleeping"
        sleep 2
    done
    echo "MariaDB is up - proceeding"
}

# Check if wp-config.php exists
if [ -f wp-config.php ]; then
    echo "Found wp-config.php; checking if WordPress is installed..."

    # Check if WordPress is actually installed by verifying DB tables
    if is_wordpress_installed; then
        echo "WordPress is already installed."
    else
        echo "wp-config.php exists but WordPress is not installed. Installing WordPress..."
        
        # Ensure DB is ready
        wait_for_mariadb

        # Run WP-CLI install
        wp core install \
            --url="${WP_URL}" \
            --title="${WP_TITLE}" \
            --admin_user="${WP_ADMIN_USER}" \
            --admin_password="${WP_ADMIN_PASS}" \
            --admin_email="${WP_ADMIN_EMAIL}" \
            --skip-email \
            --allow-root

        # Create additional user if specified
        if [ -n "${WP_USER}" ] && [ -n "${WP_USER_PASS}" ] && [ -n "${WP_USER_EMAIL}" ]; then
            wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}" --role=editor --allow-root
        fi

        echo "WordPress installation complete."
    fi
else
    echo "wp-config.php not found. Proceeding with fresh WordPress installation..."

    echo "Downloading WordPress..."
    wget http://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf latest.tar.gz wordpress

    # Insert DB credentials into wp-config.php
    echo "Configuring wp-config.php with database credentials..."
    sed -i "s/database_name_here/${MARIADB_DATABASE}/" wp-config-sample.php
    sed -i "s/username_here/${MARIADB_USER}/"         wp-config-sample.php
    sed -i "s/password_here/${MARIADB_PASS}/"         wp-config-sample.php
    sed -i "s/localhost/${MARIADB_HOST}/"             wp-config-sample.php

    cp wp-config-sample.php wp-config.php

    # Wait until DB is up
    wait_for_mariadb

    # Run WP-CLI install
    echo "Running WP-CLI to install WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Create additional user if specified
    if [ -n "${WP_USER}" ] && [ -n "${WP_USER_PASS}" ] && [ -n "${WP_USER_EMAIL}" ]; then
        wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}" --role=editor --allow-root
    fi

    echo "WordPress installation complete."
fi

# Hand over to php-fpm (CMD)
exec "$@"
