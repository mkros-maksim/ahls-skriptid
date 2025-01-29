APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c 'ok installed')
if [ $APACHE2 -eq 0 ]; then
    echo "Paigaldame apache2"
    sudo apt install apache2 -y
    echo "Apache on paigaldatud"
    sudo systemctl start apache2
else
    echo "apache2 on juba paigaldatud"
    sudo systemctl start apache2
fi

MYSQL=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c 'ok installed')
if [ $MYSQL -eq 0 ]; then
    echo "Paigaldame mysql ja vajalikud lisad"
    sudo apt install mysql-server -y
    echo "mysql on paigaldatud"
else
    echo "mysql-server on juba paigaldatud"
fi

PHP=$(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c 'ok installed')
if [ $PHP -eq 0 ]; then
    echo "Paigladame php ja vajalikud lisad"
    sudo apt install php libapache2-mod-php php-mysql -y
    echo "php on paigaldatud"
else
    echo "php on juba paigaldatud"
fi

DB_NAME="wpdatabase"
DB_USER="wpuser"
DB_PASSWORD="qwerty"
echo "Seadistame andmebaasi ja kasutaja"
mysql --user="root" --password="qwerty" --execute="
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;"
echo "Andmebaas ja kasutaja on loodud."

WORD=$(dpkg-query -W -f='${Status}' wordpress 2>/dev/null | grep -c 'ok installed')
if [ $WORD -eq 0 ]; then
    echo "Paigaldame wordpress"
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz
    cp wordpress/wp-config-sample.php wordpress/wp-config.php
    echo "Wordpress on paigaldatud"
else
    echo "Wordpress on juba paigaldatud"
fi

sed -i "s/database_name_here/wordpress/g" /home/mkros/wordpress/wp-config.php
sed -i "s/username_here/wpuser/g" /home/mkros/wordpress/wp-config.php
sed -i "s/password_here/qwerty/g" /home/mkros/wordpress/wp-config.php

IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "WordPress on valmis. Külastage: http://$IP_ADDRESS"
