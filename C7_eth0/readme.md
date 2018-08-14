This is a less appropriate NIC monitoring, you can try

Coincidentally, I have several machines with different bandwidths and can't use zabbix's default discovery template.

In addition, I have to make different thresholds for these machines to make alarms.

So, there is this simple idea, he is roughly as follows

script:
```
ckip=`ip a|grep $(curl -s -l myip.ipip.net|grep -Eo "([1-2]{0,1}[0-9]{1,2}.){3}[1-2]{0,1}[0-9]{1,2}")|awk '{print $NF}'`
echo "UserParameter=net_input_5,awk '/${ckip}/{print \$2}' /proc/net/dev"  >> /etc/zabbix/zabbix_agentd.conf
echo "UserParameter=net_output_5,awk '/${ckip}/{print \$10}' /proc/net/dev" >> /etc/zabbix/zabbix_agentd.conf
echo "UserParameter=net_input_30,awk '/${ckip}/{print \$2}' /proc/net/dev"  >> /etc/zabbix/zabbix_agentd.conf
echo "UserParameter=net_output_30,awk '/${ckip}/{print \$10}' /proc/net/dev" >> /etc/zabbix/zabbix_agentd.conf
echo "UserParameter=net_input_60,awk '/${ckip}/{print \$2}' /proc/net/dev"  >> /etc/zabbix/zabbix_agentd.conf
echo "UserParameter=net_output_60,awk '/${ckip}/{print \$10}' /proc/net/dev" >> /etc/zabbix/zabbix_agentd.conf
tail -6 /etc/zabbix/zabbix_agentd.conf
unset ckip
systemctl restart zabbix-agent
ss -tlnp|grep 10050
```
I believe you have already understood this script.

Next, when you need to add itmes,

[io-0.png](https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/C7_eth0/io-0.png)

Next, modify the rate. This is very important

[io-1.png](https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/C7_eth0/io-1.png)

Finally it is probably like this

[](https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/C7_eth0/io-3.png)
