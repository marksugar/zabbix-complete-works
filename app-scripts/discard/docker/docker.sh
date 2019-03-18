#!/bin/bash
jkph=/etc/zabbix/scripts/
jkpcig=/etc/zabbix/zabbix_agentd.d/docker.conf
mkdir $jkph -p
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/docker/docker_host_status.sh  -o ${jkph}docker_host_status.sh
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/docker/docker_name.py   -o ${jkph}docker_name.py
chmod +x /etc/zabbix/scripts/docker*
(crontab -l; echo -e "*/1 * * * * /usr/bin/sh /etc/zabbix/scripts/docker_host_status.sh") | crontab -
curl -Lks https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/docker/UserParameter >> $jkpcig
systemctl restart zabbix-agent.service
#pcip=`ip addr | awk '$1=="inet" && $NF!="lo"{print $2;exit}'|sed -r 's/\/[0-9]{1,}//'`
