echo 'UserParameter=iptables_lins,/usr/bin/sudo iptables -S|wc -l' >> /etc/zabbix/zabbix_agentd.conf && \
echo 'zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables' >>/etc/sudoers &&\
echo 'UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables'  >>/etc/zabbix/zabbix_agentd.conf && \
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && cat /etc/sudoers|grep Defaults && \
systemctl restart zabbix-agent
