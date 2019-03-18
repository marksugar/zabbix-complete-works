#!/bin/bash
#usage：curl -Lk4 https://raw.githubusercontent.com/xiaoyawl/centos_init/master/zabbix_install_scripts.sh|bash -x -s net ZABBIXSERVERIP
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
[ -z $3 ] && HOSTNAME_ZBX=${HOSTNAME_ZBX:-$pcip} || HOSTNAME_ZBX=${3}
[ -z $2 ] && SERVER_IP=${SERVER_IP:-$zzabbix} || SERVER_IP=${2}
[ -f /tmp/yum.conf ] && :>/tmp/yum.conf
echo -e "[zabbix]\nname = Zabbix\nbaseurl = http://repo.zabbix.com/zabbix/3.0/rhel/${VERSION}/x86_64\n" >> /tmp/yum.conf
yum -c /tmp/yum.conf install -y zabbix-agent zabbix-sender
sed -ri "s/^(Server(Active)?=).*/\1${SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sed -ri "s/^(Hostname=).*/\1${HOSTNAME_ZBX}/g" /etc/zabbix/zabbix_agentd.conf

mkdir $jkph -p
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/fdisk/disk.pl -o ${jkph}disk.pl
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/fdisk/disktcp.conf -o ${UserParameter1}disktcp.conf
chmod 755 /etc/zabbix/scripts/disk.pl
(crontab -l; echo -e "*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[\$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt\n*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt") | crontab -
echo "UserParameter=iptables_lins,/usr/bin/sudo iptables -S |md5sum|awk '{print \$1}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo 'zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables' >>/etc/sudoers &&\
echo 'UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables'  >>/etc/zabbix/zabbix_agentd.conf && \
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && cat /etc/sudoers|grep Defaults && \
[ "${VERSION}" = "7" ] && { systemctl enable zabbix-agent.service && systemctl start zabbix-agent.service; }
[ "${VERSION}" = "6" ] && { chkconfig zabbix-agent on && service zabbix-agent start; }
