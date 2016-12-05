#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${DIR}/observium.conf"

rm -rf /opt/observium
mkdir -p /opt/observium && cd /opt

yum -y update && yum -y upgrade
yum -y install epel-release
yum -y install gcc wget httpd php php-mysql php-gd php-posix \
    php-mcrypt php-pear cronie net-snmp net-snmp-utils fping \
    mariadb-server mariadb MySQL-python rrdtool subversion jwhois \
    ipmitool graphviz ImageMagick libvirt

mkdir -p /opt/observium && cd /opt

wget "${OBSERVIUM_DOWNLOAD}"
tar zxvf "${OBSERVIUM_DOWNLOAD##*/}"
rm -f "${OBSERVIUM_DOWNLOAD##*/}"

systemctl enable mariadb
systemctl start mariadb

mysqladmin -u root password "${MYSQL_ROOT_PASS}"

mysql -u root -p"${MYSQL_ROOT_PASS}" -e "create database ${OBSERVIUM_DB};"
mysql -u root -p"${MYSQL_ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON ${OBSERVIUM_DB}.* TO ${OBSERVIUM_DB_USER}@localhost IDENTIFIED BY '${OBSERVIUM_DB_PASS}'"

cat "${DIR}/config/observium.config.php" > "/opt/observium/config.php"

mkdir /var/rrd
ln -s /var/rrd /opt/observium/rrd
chown -h apache:apache /opt/observium/rrd
chown apache:apache /var/rrd
chmod 775 /var/rrd

mkdir -p /var/log/observium
ln -s /var/log/observium /opt/observium/logs
chown -h apache:apache /opt/observium/logs
chown apache:apache /var/log/observium
chmod 775 /var/log/observium

chown apache:apache -R /opt/observium/html/

# if sites-available does not exist
#mkdir -p /etc/httpd/sites-available
#mkdir -p /etc/httpd/sites-enabled
#echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
#cat "${DIR}/config/observium.httpd.conf" > "/etc/httpd/sites-available/default.conf"
#ln -s /etc/httpd/sites-available/default.conf /etc/httpd/sites-enabled
#cat "${DIR}/config/observium.httpd.conf" > "/etc/httpd/conf.d/observium.conf"
ln -s /opt/observium/html /var/www/html/observium


/opt/observium/discovery.php -u
/opt/observium/adduser.php "root" "${OBSERVIUM_ADMIN_PASS}" "10"

setenforce 0
sed -i 's/enforcing/permissive/g' /etc/selinux/config /etc/selinux/config
#chcon -R -u system_u -r object_r -t httpd_sys_content_t <DocumentRoot>

cat "${DIR}/config/observium.cron" > "/etc/cron.d/observium"
systemctl reload crond

# OPTIONAL
#	 hide all the notices of undefined indexes, variables and offsets 
#	 open /etc/php.ini
#	 edit error_reporting line
#	 change E_ALL & ~E_DEPRECATED to:
#	 error_reporting = E_ALL & ~E_NOTICE

systemctl enable httpd
systemctl start httpd

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

/opt/observium/add_device.php "${INIT_HOST}" "${INIT_HOST_COMMUNITY}" "v2c"

/opt/observium/discovery.php -h all
/opt/observium/poller.php -h all
