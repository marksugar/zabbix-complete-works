echo 'zabbix ALL=(root)NOPASSWD:/usr/bin/cksum /root/.ssh/authorized_keys' >>/etc/sudoers
echo "UserParameter=authorized_keys,sudo /usr/bin/cksum /root/.ssh/authorized_keys|awk '{print \$1}'" >> /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent.service
