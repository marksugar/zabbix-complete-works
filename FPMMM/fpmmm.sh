#!/bin/bash
dbhost='127.0.0.1'
dbuser='fpmmm'
dbpass='password'
download_dir='/usr/local'
fpm='https://support.fromdual.com/admin/download/fpmmm-0.10.5.tar.gz'
conf_dir='/etc/fpmmm'
#下载fpmmm
ping -c1 -w1 1.2.4.8 &> /dev/null
if [ $? -eq 0 ];then
    wget -P $download_dir $fpm
else
        echo "Network not Connected"
        exit 1
fi
yum install  numactl php-cli php-process php-mysqli -y
cd $download_dir
#wget $fpm
tar xf fpmmm-0.10.5.tar.gz
ln -s fpmmm-0.10.5 fpmmm
mkdir -p $conf_dir 
if [ -d $conf_dir ];then
    cp $download_dir/fpmmm/tpl/fpmmm.conf.template /etc/fpmmm/fpmmm.conf
fi
mkdir /tmp/fpmmm -p
chown -R zabbix: /etc/fpmmm
#授权fpmmm
#mysql -e "GRANT ALL  ON *.* TO '$dbuser'@'$dbhost' IDENTIFIED BY '$dbpass';flush privileges;"

#修改配置文件
mv /etc/fpmmm/fpmmm.conf{,.bak}
> /etc/fpmmm/fpmmm.conf
cat >/etc/fpmmm/fpmmm.conf << EOF
[default]
Type          = mysqld
LogLevel      = 2
LogFile       = /tmp/fpmmm/fpmmm.log
CacheFileBase = /tmp/fpmmm/fpmmmCache
AgentLockFile = /tmp/fpmmm/fpmmm.lock
Username      = fpmmm
Password      = password
MysqlHost     = 127.0.0.1
MysqlPort     = 3306
ZabbixServer  = 
Disabled      = false
Modules       = process mysql myisam innodb master security galera server aria
PidFile       = /data/mariadb/mysql.pid
[]          # This MUST match Hostname in Zabbix!
Type          = mysqld
Modules       = fpmmm server
[]          # This MUST match Hostname in Zabbix!
Type          = mysqld
MysqlPort     = 3306
Modules       = process mysql myisam innodb master security galera server aria
PidFile       = /data/mariadb/mysql.pid
EOF

#添加key
echo UserParameter=FromDual.MySQL.check,$download_dir/fpmmm/bin/fpmmm --config=$conf_dir/fpmmm.conf >>/etc/zabbix/zabbix_agentd.conf
#UserParameter=FromDual.MySQL.check,/usr/local/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf

cat << _EOF >/etc/php.d/fpmmm.ini
variables_order = "EGPCS"
date.timezone = 'Europe/Zurich'
_EOF
#echo "*/1 * * * * /usr/local/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf" >/dev/null >>/var/spool/cron/root
(crontab -l; echo -e "*/1 * * * * /usr/local/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf") | crontab -
usermod -G mysql zabbix
