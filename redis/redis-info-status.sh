#!/bin/bash
REDISPATH=/usr/local/redis-cli
ZAPATH=/etc/zabbix/zabbix_agentd.conf
ZAPATHA=/etc/zabbix/scripts

if [ `type redis-cli|wc -l` = 0 ];then
	git clone http://github.com/antirez/redis.git "${REDISPATH}" \
	cd ${REDISPATH} && git checkout 3.0 && make redis-cli  && cp src/redis-cli /usr/local/bin \rm -rf ${REDISPATH}
else
    echo "redis-cli already exists!"
	echo "`redis-cli --version`"
	echo "start configure redis and zabbix"
fi

curl -Lk https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/redis/redis_hits.sh -o ${ZAPATHA}/redis_hits.sh
curl -Lk https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/redis/redis_info.sh -o ${ZAPATHA}/redis_info.sh
chmod +x ${ZAPATHA}/redis*

if [ `grep redis ${ZAPATH}|wc -l` = 0 ];then
	echo "UserParameter=redis_info[*],/usr/local/zabbix/scripts/redis_info.sh \$1 \$2" >> ${ZAPATH}
	echo "UserParameter=redis_hits,/usr/local/zabbix/scripts/redis_hits.sh" >> ${ZAPATH}
fi

(crontab -l; echo -e "*/1 * * * * /usr/bin/redis-cli -h 127.0.0.1 -p 6379 info > /tmp/redis-info.txt 2>/dev/null" ) | crontab -

systemctl restart zabbix-agent
echo "tail -10 /var/log/zabbix/zabbix_agentd.log"
