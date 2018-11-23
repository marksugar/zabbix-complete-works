这里依旧提供了php和nginx一样的监控方式

不同的是php并不需要脚本，只需要模板和配置文件的定义即可进行获取

UserParameter=nginx.status[*],/etc/zabbix/scripts/nginx_status.sh $1 $2
UserParameter=php-fpm.status[*],/usr/bin/curl -s "http://127.0.0.1:40080/php-fpm_status?xml" | grep "<$1>" | awk -F'>|<' '{ print $$3}'
