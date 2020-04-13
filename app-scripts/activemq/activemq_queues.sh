#!/bin/bash
#########################################################################
# Author: www.linuxea.com
# https://github.com/marksugar/zabbix-complete-works
#########################################################################
mkdir -p /etc/zabbix/scripts
sed -i 's@#Include=/etc/zabbix/zabbix_agentd.d/*.conf@Include=/etc/zabbix/zabbix_agentd.d/*.conf@g' /etc/zabbix/zabbix_agentd.conf
curl -LKs https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/app-scripts/activemq/activemq.conf -o /etc/zabbix/zabbix_agentd.d/activemq.conf
curl -LKs https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/app-scripts/activemq/Queues_Name.py -o /etc/zabbix/scripts/Queues_Name.py