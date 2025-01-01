FROM debian:bullseye

RUN apt update && apt install -y mariadb-server mariadb-client && rm -rf /var/lib/apt/lists/*

# Create the run directory for MySQL
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld && chmod 777 /var/run/mysqld

EXPOSE 3306

# Copy our DB initialization script
COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

# This script does all the initialization, then execs the final command
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
# Pass "mysqld --bind-address=0.0.0.0" via CMD
CMD ["mysqld", "--bind-address=0.0.0.0"]
