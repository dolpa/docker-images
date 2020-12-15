#!/bin/bash -e

echo "==============================="
echo " User: "
id

echo "==============================="
echo " Environment:"
env

# Start Jenkins Master server

echo "==============================="
echo " Parameters: "
echo "user=${user}"
echo "group=${group}"
echo "uid=${uid}"
echo "gid=${gid}"
echo "port=${port}"

echo "==============================="
echo " Arguments:"
echo ${@}

echo "==============================="
echo " Check if folders exists and they permisions:"
# ls -la /var/
# ls -la ${MYSQL_HOME}

echo "==============================="
echo "Special Mysql Server params:"
echo "MYSQL_USER=${MYSQL_USER}"
echo "MYSQL_PASSWORD=${MYSQL_PASSWORD}"
echo ""

# create new database directory if necessary
if [ ! "$(ls -A /var/lib/mysql/)" ] ; then
    # Need to initialize the data directory
    echo "==============================="
    echo "Initializee New Database:"
    mysqld --defaults-file=/etc/mysql/my.cnf --initialize-insecure --user=${MYSQL_USER} --console

    # Start mysql server in background
    mysqld &

    # wait until server started
    echo "Waiting for MySQL server ... "
    # local i
    for i in {60..0}; do
        echo "Trying for ${i} time ... "
        if mysql -u root -e "SELECT 1" &> /dev/null ; then
            break
        fi
        sleep 1
    done

    # Change root pass
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER 'root'@'::1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    # Creates a custom database and user if specified
    if [ -n "$MYSQL_DATABASE" ]; then
        echo "Creating database ${MYSQL_DATABASE}"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;"
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "Creating user ${MYSQL_USER}"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;"

        if [ -n "$MYSQL_DATABASE" ]; then
            echo "Giving user ${MYSQL_USER} access to schema ${MYSQL_DATABASE}"
            mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON \`${MYSQL_DATABASE//_/\\_}\`.* TO '$MYSQL_USER'@'%' ;"
        fi
    fi
    mysqladmin shutdown -u root -p${MYSQL_ROOT_PASSWORD}
fi

exec mysqld


