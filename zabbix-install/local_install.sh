#!/bin/bash
#########################################################################
# File Name: 1.sh
# Author: mark
# Email: www.linuxea.com
# Version:
# Created Time: 2017年04月13日 星期四 16时37分21秒
#########################################################################

Hzabbix=`ip a|grep eth1|awk -F / NR==2'{print $1}'|awk '{print $2}'`
#Hzabbix=`ip a|grep 172.25.6.*|awk -F / NR==2'{print $1}'|awk '{print $2}'`
Hserver=172.30.0.62
mkdir -p /etc/zabbix/scripts/
(crontab -l; echo -e "*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[\$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt\n*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt") | crontab -
cat > /etc/zabbix/scripts/disk.pl << EOF
#!/usr/bin/perl
## -------------------------------------------------------------------------------
## Filename:    disk i/o
## Revision:    1.1
## Date:        20160707
## Author:      mark
## Email:       usertzc@163.com
## Website:     www.linuxea.com
## -------------------------------------------------------------------------------
## Notice
## Apply zabbix version 2.4.x to 3.0.3 
## auto search disk i/o
##################################################################################
sub get_vmname_by_id
 {
 \$vmname=\`cat /etc/qemu-server/$_[0].conf | grep name | cut -d \: -f 2\`;
 \$vmname =~ s/^\s+//;
 \$vmname =~ s/\s+\$//;
return \$vmname
 }
\$first = 1;
print "{\n";
print "\t\"data\":[\n\n";
 
for (\`cat /proc/diskstats\`)
  {
  (\$major,\$minor,\$disk) = m/^\s*([0-9]+)\s+([0-9]+)\s+(\S+)\s.*\$/;
  \$dmnamefile = "/sys/dev/block/\$major:\$minor/dm/name";
  \$vmid= "";
  \$vmname = "";
  \$dmname = \$disk;
  \$diskdev = "/dev/\$disk";

 if (-e \$dmnamefile) {
    \$dmname = \`cat \$dmnamefile\`;
    \$dmname =~ s/\n\$//; #remove trailing \n
    \$diskdev = "/dev/mapper/\$dmname";

    if (\$dmname =~ m/^.*--([0-9]+)--.*\$/) {
    \$vmid = \$1;
                 }
     }

print "\t,\n" if not \$first;
  $first = 0;
 
  print "\t{\n";
  print "\t\t\"{#DISK}\":\"\$disk\",\n";
  print "\t\t\"{#DMNAME}\":\"\$dmname\",\n";
  print "\t\t\"{#VMNAME}\":\"\$vmname\",\n";
  print "\t\t\"{#VMID}\":\"\$vmid\"\n";
  print "\t}\n";
  }
 
print "\n\t]\n";
print "}\n";
EOF

#cat > /etc/zabbix/zabbix_agentd.d/distcp.conf << EOF
#UserParameter=discovery.disks.iostats,/etc/zabbix/scripts/disk.pl
#UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$6}' 
#UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$10}'
#UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 |awk '{print $$4}'
#UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$8}'
#UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$7}'
#UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$11}'
#UserParameter=tcp.status[*],awk '{if ($$1~/^$1/)print $$2}' /tmp/tcp-status.txt
#UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l
#UserParameter=iptables_lins,/usr/bin/sudo iptables -S |md5sum|awk '{print $1}'
#UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables
#EOF
chmod 755 /etc/zabbix/scripts/disk.pl  && \
echo "UserParameter=discovery.disks.iostats,/etc/zabbix/scripts/disk.pl" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$6}' " >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$10}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep \$1 | head -1 |awk '{print \$\$4}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$8}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$7}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$11}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=tcp.status[*],awk '{if (\$\$1~/^\$1/)print \$\$2}' /tmp/tcp-status.txt" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l" >> /etc/zabbix/zabbix_agentd.conf && \
echo "UserParameter=iptables_lins,/usr/bin/sudo iptables -S |md5sum|awk '{print \$1}'" >> /etc/zabbix/zabbix_agentd.conf && \
echo "zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables" >>/etc/sudoers &&\
echo "UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables"  >>/etc/zabbix/zabbix_agentd.conf && \
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers && cat /etc/sudoers|grep Defaults && \
sed -i "s/Hostname=Zabbix server/Hostname=${Hzabbix}/g" /etc/zabbix/zabbix_agentd.conf &&\
sed -i "s/ServerActive=127.0.0.1/ServerActive=${Hserver}/g"  /etc/zabbix/zabbix_agentd.conf && \
sed -i "s/Server=127.0.0.1/Server=${Hserver}/g" /etc/zabbix/zabbix_agentd.conf && \
iptables -I INPUT 5 -s 172.30.0.62/32 -p tcp -m tcp -m state --state NEW -m multiport --dports 10050:10053 -m comment --comment "Zabbix_proxy" -j ACCEPT &&\
sed -i '15a-A INPUT -s 172.30.0.62/32 -p tcp -m tcp -m state --state NEW -m multiport --dports 10050:10053 -m comment --comment "Zabbix_proxy" -j ACCEPT'  /etc/sysconfig/iptables &&\
systemctl restart zabbix-agent
