#!/bin/bash
chown -R mysql:mysql /var/lib/mysql
mysql_install_db --user=mysql --datadir=/var/lib/mysql >> /dev/null
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &


PASSWORD=$(cat /run/secrets/db_password)

while true; do
    if /usr/bin/mysqladmin ping --silent; then
        break
    fi
    echo "MySQL is not ready, retrying"
    sleep 1
done

echo -n "Creating database $NAME: "
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $NAME;" && echo "                    SUCCESS"
echo -n "Creating user $USER with password **********: "
mysql -u root -e "CREATE USER IF NOT EXISTS \`${USER}\`@'localhost' IDENTIFIED BY '${PASSWORD}';" && echo "SUCCESS"
echo -n "Granting privileges to $NAME: "
mysql -u root -e "GRANT ALL PRIVILEGES ON \`${NAME}\`.* TO '${USER}'@'%' IDENTIFIED BY '${PASSWORD}';" && echo "               SUCCESS"
mysql -u root -e "FLUSH PRIVILEGES;"

mysqladmin shutdown

/usr/bin/mysqld_safe --datadir=/var/lib/mysql

