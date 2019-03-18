NUM=`iptables -L -nv --lin|grep 172.30.0.63|awk '{print $1}'`
iptables -D INPUT $NUM
iptables -I INPUT 6 -s 172.25.0.63 -p tcp -m tcp -m state --state NEW -m multiport --dports 10050:10053 -m comment --comment "zabbix_proxy" -j ACCEPT
sed -i 's/172.30.0.63/172.25.0.63/g' /etc/sysconfig/iptables
sed -i 's/172.30.0.62/172.25.0.62/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/172.30.5/172.25.10/g' /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent.service
