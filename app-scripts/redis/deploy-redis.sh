#!/bin/bash
#########################################################################
# File Name: deploy-redis.sh
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# https://github.com/marksugar/zabbix-complete-works
#########################################################################

read -p "输入redis密码:" repassword
mkdir -p /etc/zabbix/scripts/
curl -LKs https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/app-scripts/redis/redis.sh -o /etc/zabbix/scripts/redis.sh
curl -LKs https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/app-scripts/redis/redis_discovery.py -o /etc/zabbix/scripts/redis_discovery.py
sed -i 's@#Include=/etc/zabbix/zabbix_agentd.d/*.conf@Include=/etc/zabbix/zabbix_agentd.d/*.conf@g' /etc/zabbix/zabbix_agentd.conf
curl -LKs https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/app-scripts/redis/redis.conf -o /etc/zabbix/zabbix_agentd.d/redis.conf
chmod +x /etc/zabbix/scripts/redis*
sed -i "s/mima/$repassword/g" /etc/zabbix/scripts/redis.sh /etc/zabbix/scripts/redis_discovery.py /etc/zabbix/zabbix_agentd.d/redis.conf
grep Timeout=30 /etc/zabbix/zabbix_agentd.conf || echo "Timeout=30" >> /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent.service