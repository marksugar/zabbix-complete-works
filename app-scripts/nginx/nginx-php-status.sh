#!/bin/bash
NGPATH=/etc/zabbix/scripts
NGFILE=/etc/zabbix/scripts/nginx_status.sh
NGSTATUS=/usr/local/nginx/conf/vhost/status.conf
[ -d ${NGPATH} ]||mkdir ${NGPATH} -p
[ -f ${NGFILE} ]||curl -Lks https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/nginx/nginx_status.sh -o ${NGFILE} && chmod +x ${NGFILE}
[ -f ${NGSTATUS} ] || curl  -Lks https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/nginx/status.conf -o ${NGSTATUS}

ZAPATH=/etc/zabbix/zabbix_agentd.conf
if [ `grep nginx ${ZAPATH}|wc -l` = 0 ];then
  echo "UserParameter=nginx.status[*],${NGFILE} \$1 \$2" >> ${ZAPATH}
fi
  
if [ `grep php-fpm ${ZAPATH}|wc -l` = 0 ];then
  echo "UserParameter=php-fpm.status[*],/usr/bin/curl -s \"http://127.0.0.1:40080/php-fpm_status?xml\" | grep \"<\$1>\" | awk -F '>|<' '{ print \$\$3}'" >> ${ZAPATH}
fi
systemctl restart zabbix-agent
echo "tail -10 /var/log/zabbix/zabbix_agentd.log"
tail -10 /var/log/zabbix/zabbix_agentd.log
echo "sleep 2 && ss -tlnp|grep 40080"
sleep 2 && ss -tlnp|grep 40080
