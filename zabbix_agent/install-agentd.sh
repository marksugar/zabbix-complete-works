#!/bin/bash
#########################################################################
# File Name: install-agentd.sh
# Author: www.linuxea.com
# Created Time: Mon 18 Mar 2019 04:50:57 PM CST
#########################################################################

zabbix_agentd_conf=/etc/zabbix/zabbix_agentd.conf
if [[ "$1" == "local" ]]; then
        # pcip=${pcip:-$(ip addr | awk '$1=="inet" && $NF!="lo"{print $2;exit}'|sed -r 's/\/[0-9]{1,}//')}
		a=$(awk -F'=' '/DEVICE/{print $2}' /etc/sysconfig/network-scripts/ifcfg-*|grep -v lo|sed 's/"//g'|uniq)
		pcip=${pcip:-$(ip addr show $(echo  $a| awk '{print $1}')|awk 'NR==3{print $2}'|cut -d/ -f1)}
elif [[ "$1" == "net" ]]; then
        pcip=${pcip:-$(curl -Lks4 curlip.me|awk 'NR==1{print $NF}')}
fi

zzabbix=${zzabbix:-$2}

jkph=/etc/zabbix/scripts/

VERSION=${VERSION:-$(awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/centos-release)}
[ -z $3 ] && HOSTNAME_ZBX=${HOSTNAME_ZBX:-$pcip} || HOSTNAME_ZBX=${3}
[ -z $2 ] && SERVER_IP=${SERVER_IP:-$zzabbix} || SERVER_IP=${2}
[ -f /tmp/yum.conf ] && :>/tmp/yum.conf
echo -e "[zabbix]\nname = Zabbix\nbaseurl = http://repo.zabbix.com/zabbix/4.0/rhel/${VERSION}/x86_64\n" >> /tmp/yum.conf     
  
if ! which zabbix_agentd >/dev/null 2>&1;then 
	yum -c /tmp/yum.conf install -y zabbix-agent zabbix-sender ;
else 
	mv ${zabbix_agentd_conf} ${zabbix_agentd_conf}.bak
fi	

curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_agent/Initial-package/zabbix_agent_status.tar.gz|tar xz -C /etc/zabbix/
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_agent/Initial-package/zabbix_agentd.conf -o ${zabbix_agentd_conf}

sed -i '/10050/d' /etc/sysconfig/iptables
iptables -I INPUT 7 -s "${SERVER_IP}" -p tcp -m tcp -m state --state NEW -m multiport --dports 10050:10053 -m comment --comment "Zabbix-Server" -j ACCEPT
sed -i "/-A INPUT -j REJECT/i -A INPUT -s ${SERVER_IP} -p tcp -m tcp -m state --state NEW -m multiport --dports 10050:10053 -m comment --comment "Zabbix-Server" -j ACCEPT" /etc/sysconfig/iptables

sed -ri "s/^(Server(Active)?=).*/\1${SERVER_IP}/" ${zabbix_agentd_conf}
sed -ri "s/^(Hostname=).*/\1${HOSTNAME_ZBX}/g" ${zabbix_agentd_conf}

mkdir $jkph -p
chmod 755 /etc/zabbix/scripts/disk.pl
chown -R zabbix.zabbix /var/log/zabbix/ /run/zabbix/

# tcp

if ! grep /usr/sbin/ss  /var/spool/cron/root >/dev/null 2>&1;then (crontab -l; echo -e "*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[\$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt\n*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt") | crontab -;fi

# iptables and authorized_keys
if ! grep /etc/sysconfig/iptables /etc/sudoers >/dev/null 2>&1 ;then echo 'zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables' >>/etc/sudoers;fi
if ! grep /root/.ssh/authorized_keys /etc/sudoers >/dev/null 2>&1 ;then echo 'zabbix ALL=(root)NOPASSWD:/usr/bin/cksum /root/.ssh/authorized_keys' >>/etc/sudoers;fi
if ! grep /opt/zookeeper/bin/zkServer.sh /etc/sudoers >/dev/null 2>&1 ;then echo "zabbix ALL=(root)NOPASSWD:/usr/bin/docker,/usr/bin/docker exec -it zookeeper bash /opt/zookeeper/bin/zkServer.sh status" >>  /etc/sudoers;fi

sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && cat /etc/sudoers|grep Defaults

[ "${VERSION}" = "7" ] && { systemctl enable zabbix-agent.service && systemctl start zabbix-agent.service; }
[ "${VERSION}" = "6" ] && { chkconfig zabbix-agent on && service zabbix-agent start; }
