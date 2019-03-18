#!/bin/bash
#########################################################################
# File Name: zabbix.sh
# Author: mark linuxea
# Email: www.linuxea.com
# Version:
# Created Time: Tue 10 Jan 2017 01:49:42 PM CST
#########################################################################
pat=/usr/local
wwwpat=/data/wwwroot
muser=root
mpass=abc123
myhost=127.0.0.1
zaxconf=/etc/zabbix
mkdir $zaxconf -p && useradd zabbix -s /sbin/nologin -M
yum install mbedtls-devel mariadb gnutls-devel fping sqlite-devel net-snmp-devel libssh2-devel OpenIPMI-devel libxml2-devel libcurl  curl-devel -y
wget -c https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.2/zabbix-3.2.2.tar.gz &&\
tar xf zabbix-3.2.2.tar.gz -C $pat 
cd $pat/zabbix-3.2.2 && ./configure --prefix=/usr/local/zabbix_proxy --enable-proxy --enable-agent --with-mysql --with-net-snmp --enable-ipv6 --with-libcurl --with-libxml2 && make && make install
cp -a /usr/local/zabbix-3.2.2/misc/init.d/fedora/core/* /etc/init.d/ && chmod +x /etc/init.d/zabbix_* &&\
cp -ra /usr/local/zabbix-3.2.2/frontends/php/* $wwwpat && \
ln -s /usr/local/zabbix_proxy/etc /etc/zabbix/ && \
mysql -u$muser -p$mpass -h$myhost -e "CREATE DATABASE zabbix_proxy charset='utf8';\
GRANT ALL  ON zabbix_proxy.* To 'zabbix_proxy'@'%' IDENTIFIED BY 'password';
flush privileges;"

mysql -u$muser -p$mpass -h$myhost zabbix_proxy < /usr/local/zabbix-3.2.2/database/mysql/schema.sql
#echo "########################编译安装完成！###############"
