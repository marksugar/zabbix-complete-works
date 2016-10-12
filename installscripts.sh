#!/bin/bash

#read pcip
#zzabbix=10.10.231.61

if [[ "$1" == "local" ]]; then
        pcip=${pcip:-$(ip addr | awk '$1=="inet" && $NF!="lo"{print $2;exit}'|sed -r 's/\/[0-9]{1,}//')}
elif [[ "$1" == "net" ]]; then
        pcip=${pcip:-$(curl -Lks4 curlip.me|awk 'NR==1{print $NF}')}
fi

zzabbix=${zzabbix:-$2}

jkph=/etc/zabbix/scripts/
UserParameter1=/etc/zabbix/zabbix_agentd.d/

VERSION=${VERSION:-$(awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/centos-release)}
[ -z $1 ] && HOSTNAME=${HOSTNAME:-$(hostname)} || HOSTNAME=${1}
[ -z $2 ] && SERVER_IP=${SERVER_IP:-$zzabbix} || SERVER_IP=${2}
[ -f /tmp/yum.conf ] && :>/tmp/yum.conf
echo -e "[zabbix]\nname = Zabbix\nbaseurl = http://repo.zabbix.com/zabbix/3.0/rhel/${VERSION}/x86_64\n" >> /tmp/yum.conf
yum -c /tmp/yum.conf install -y zabbix-agent zabbix-sender
sed -ri "s/^(Server(Active)?=).*/\1${SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sed -ri "s/^(Hostname=).*/\1${HOSTNAME}/g" /etc/zabbix/zabbix_agentd.conf
#sed -i 's/Hostname=Zabbix server/Hostname='$pcip'/' /etc/zabbix/zabbix_agentd.conf
setenforce 0

mkdir $jkph -p
wget -P $jkph https://raw.githubusercontent.com/LinuxEA-Mark/zabbix/master/fdisk/disk.pl
chmod 755 /etc/zabbix/scripts/disk.pl
wget -P $UserParameter1 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix/master/fdisk/disktcp.conf
(crontab -l; echo -e "*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[\$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt\n*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt") | crontab -
iptables -I INPUT 4 -s $zzabbix -p tcp --dport 10050 -j ACCEPT
[ "${VERSION}" = "7" ] && { systemctl enable zabbix-agent.service && systemctl start zabbix-agent.service; }
[ "${VERSION}" = "6" ] && { chkconfig zabbix-agent on && service zabbix-agent start; }
tail /var/log/zabbix/zabbix_agentd.log 
