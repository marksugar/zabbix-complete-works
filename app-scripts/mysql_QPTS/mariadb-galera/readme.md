这是一个非常简单的mariadb-galera-clster监控项目，它并不适用于一般的主从结构

curl -Lk https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/mysql_QPTS/mariadb/install_db_status.sh|bash

* sql

`GRANT SELECT ON *.* TO 'zabbix'@'127.0.0.1'  IDENTIFIED BY 'password';`

* UserParameter

`echo "UserParameter=maria.db[*],/etc/zabbix/scripts/mariadb.sh \$1" >> /etc/zabbix/zabbix_agentd.conf`
