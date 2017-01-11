#!/bin/bash
#########################################################################
# File Name: .sh
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# Version:
# Created Time: 2017年01月11日 星期三 16时31分11秒
#########################################################################

sip=10.57.57.57
ipar=`ip addr | awk '$1=="inet" && $NF!="lo"{print $2;exit}'|sed -r 's/\/[0-9]{1,}//'`
zapa=/etc/zabbix/zabbix_agentd.conf
sed -i "s@Server=127.0.0.1@Server=$sip@" $zapa
sed -i "s@ServerActive=127.0.0.1@ServerActive=$sip@" $zapa
sed -i "s@Hostname=Zabbix server@Hostname=$ipar@" $zapa
