#/bin/bash
# https://github.com/marksugar/zabbix-complete-works
DEF="--defaults-file=/etc/zabbix/zabbixmy.conf"
MYSQL='/usr/local/mariadb/bin/mysql'
ARGS=1 
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:" 
fi
case $1 in
        Slave_IO_Running)
        result=`${MYSQL} $DEF -e "show slave status\G"|awk '/Slave_IO_Running/{print $2}'`
        echo $result
        ;;
        Slave_SQL_Running)
        result=`${MYSQL} $DEF -e "show slave status\G"|awk '/Slave_SQL_Running/{print $2}'`
        echo $result
        ;;
        *)
        echo "Usage:$0(Slave_SQL_Running|Slave_IO_Running)"
        ;;
esac