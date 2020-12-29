#!/bin/bash
#nginx
#cp -rp /tmp/default /etc/nginx/sites-available/ 

#openssl
openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=bkwag/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
mv localhost.dev.crt etc/ssl/certs/
mv localhost.dev.key etc/ssl/private/
chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key


#mariaDB
service mysql start
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
echo "CREATE USER 'bkwag'@'localhost' IDENTIFIED BY 'bkwag';" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'bkwag'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password

#wordpress
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
mv wordpress/ var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
cp -rp /tmp/wp-config.php /var/www/html/wordpress/ 

#phpMyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz
tar -xvf phpMyAdmin-5.0.2-all-languages.tar.gz
mv phpMyAdmin-5.0.2-all-languages phpmyadmin
mv phpmyadmin /var/www/html/
cp -rp /tmp/config.inc.php /var/www/html/phpmyadmin/

#Autoindex

AUTO=`echo $AUTOINDEX`
if [ $AUTOINDEX -eq 1 ]; then
    cp /tmp/default /etc/nginx/sites-available/
else
	mv -f /tmp/default_none_auto /tmp/default
    cp /tmp/default /etc/nginx/sites-available/
fi

service nginx start
service mysql restart
service php7.3-fpm start

sleep infinity & wait
