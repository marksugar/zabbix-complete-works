#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    redis3.0.7
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# redis Take hits
# is scripts Take hits hits/(hits+misses)
hits=`awk -F ':' '/keyspace_hits/{print $2}' /tmp/redis-info.txt`
misses=`awk -F ':' '/keyspace_misses/{print $2}' /tmp/redis-info.txt`
a=$hits
#a=14414110
#b=3228654
b=$misses
c=`awk 'BEGIN{a=$a;b=$b;print '$a+$b'}'`
awk 'BEGIN{c=$c;a=$a;print '$a/$c'}'
#awk '{a[NR]=$2;b[NR]=$1;s+=$1}END{for (j=1;j<=NR;j++) printf "%s %.2f%\n",a[j],b[j]*100/s}'



UserParameter=redis_hits,/usr/local/zabbix/scripts/redis_hits.sh


*/1 * * * * 
*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt
*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt


UserParameter=nginx.status[*],/etc/zabbix/scripts/nginx_status.sh $1 $2
UserParameter=tcp.status[*],awk '{if ($$1~/^$1/)print $$2}' /tmp/tcp-status.txt
UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l
UserParameter=php-fpm.status[*],/usr/bin/curl -s "http://127.0.0.1:40080/php-fpm_status?xml" | grep "<$1>" | awk -F'>|<' '{ print $$3}'

UserParameter=discovery.disks.iostats,/etc/zabbix/scripts/disk.pl
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$10}'
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 |awk '{print $$4}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$8}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$7}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$11}'

UserParameter=redis_hits,/usr/local/zabbix/scripts/redis_hits.sh
UserParameter=redis_info[*],/usr/local/zabbix/scripts/redis_info.sh $1 $2

-A INPUT -s 47.90.33.131/32 -p tcp -m state --state NEW -m multiport --dports 10050:10051 -j ACCEPT 


iptables -D INPUT 58
iptables -I INPUT 51 -s 47.90.33.131 -p tcp -m state --state NEW -m multiport --dports 10050:10051 -j ACCEPT 
iptables -I INPUT 50 -s 47.90.33.131/32 -p tcp -m tcp --dport 10050:10051 -j ACCEPT 

47.90.33.131







#disk
UserParameter=discovery.disks.iostats,/usr/local/zabbix/scripts/disk.pl
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$10}'
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 |awk '{print $$4}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$8}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$7}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$11}'
#jvm auto 
UserParameter=jvm.name,/usr/local/zabbix/scripts/jvm_name.sh
UserParameter=jvm.thread.num[*],/usr/local/zabbix/scripts/jvm_thread_num.sh $1 $2
UserParameter=jvm.status[*],/usr/local/zabbix/scripts/jvm_status.sh $1 $2
#tcp 
UserParameter=tcp.status[*],awk '{if ($$1~/^$1/)print $$2}' /tmp/tcp-status.txt
UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l
