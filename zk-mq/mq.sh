echo "UserParameter=zkstatus,sudo /usr/bin/docker exec -it zookeeper bash /opt/zookeeper/bin/zkServer.sh status|grep -E 'follower|leader'|wc -l" >> /etc/zabbix/zabbix_agentd.conf 
echo 'zabbix ALL=(root)NOPASSWD:/usr/bin/docker,/usr/bin/docker exec -it zookeeper bash /opt/zookeeper/bin/zkServer.sh status' >>/etc/sudoers 
systemctl restart zabbix-agent.service 
