#!/usr/bin/env bash
source config/observium.conf

wget http://www.observium.org/observium-community-latest.tar.gz
tar zxvf observium-community-latest.tar.gz
rm -rf observium-community-latest.tar.gz

cat config/observium.config.php > /opt/observium/config.php

systemctl enable mariadb
systemctl start mariadb
mysqladmin -u root password '$MYSQL_ROOT_PASS'
mysql -u -p$MYSQL_ROOT_PASS -e \
"CREATE DATABASE ${OBSERVIUM_DB} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -u -p$MYSQL_ROOT_PASS -e \
"GRANT ALL PRIVILEGES ON ${OBSERVIUM_DB}.* TO '${OBSERVIUM_DB_USER}'@'localhost' IDENTIFIED BY '${OBSERVIUM_DB_PASS}';"

mkdir -p /etc/httpd/sites-enabled
echo 'include sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
mkdir -p /etc/httpd/sites-available
cat config/observium.httpd.conf > /etc/httpd/sites-available/default.conf
ln -s /etc/httpd/sites-available/default.conf /etc/httpd/sites-enabled/

mkdir -p /var/rrd
chown apache:apache /var/rrd
ln -s /var/rrd /opt/observium/rrd
chown -h apache:apache /opt/observium/rrd

mkdir -p /var/log/observium
chown apache:apache /var/log/observium
ln -s /var/log/observium /opt/observium/logs
chown -h apache:apache /opt/observium/logs

/opt/observium/discovery.php -u

/opt/observium/adduser.php admin $OBSERVIUM_ADMIN_PASS 10

cat config/observium.cron > /etc/cron.d/observium
systemctl reload crond

systemctl enable httpd
systemctl start httpd

setenforce 0
#make this permanent

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

