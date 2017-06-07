DPAT2=/etc/zabbix/scripts/
mkdir -p $DPAT2
curl -LK https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/mysql_QPTS/mariadb/mariadb.sh -o $DPAT2 
curl -Lk https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/mysql_QPTS/mariadb/zabbixmy.conf -o /etc/zabbix/zabbixmy.conf
echo "UserParameter=maria.db[*],/etc/zabbix/scripts/mariadb.sh" >> /etc/zabbix/zabbix_agentd.conf
