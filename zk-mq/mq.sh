echo "zabbix ALL=(root)NOPASSWD:/usr/bin/docker,/usr/bin/docker exec -it zookeeper bash /opt/zookeeper/bin/zkServer.sh status"  >>  /etc/sudoers
echo "UserParameter=zkstatus,sudo /usr/bin/docker exec -i zookeeper /opt/zookeeper/bin/zkServer.sh status 2>&1 |awk 'END{print \$2}'" >> /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent.service 
