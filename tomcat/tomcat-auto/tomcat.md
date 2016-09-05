

使用jstat -gc TOMCAT ID将数据重新排序导入到$TOMCAT文件中，循环执行
但是jstat这条命令在被zabbix执行需要和tomcat启动用户一样的权限，你可以将zabbix-agent使用和tomcat启动用户一样的用户来启动zabbix-agent，也可以visudo

```
[root@iZ62bxn7uuzZ scripts]# cat jstat.sh 
#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    jstat.sh
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# Apply zabbix version 2.4.x to 3.0.3 
# auto search jmx pid
# You need to understand:
# jstat.sh search pid;jvm_name.sh search tomcat name;jvm_status.sh Obtain $1 transfer
# Automatic discovery jmx monitoring.It applies only to jstat -gc pid it
#################################################################################
check_mode() {
    tomcat_name=`ps -ef | grep tomcat | grep -v grep | grep -v "jvm_status.sh" | awk -F "=" '{print $NF}' | cut -d "/" -f 3`

for t in ${tomcat_name[@]};do
   t_id=`ps -ef | grep  "$t/" | grep -v "grep" | awk '{print $2}'`
   /usr/java/jdk1.7.0_79/bin/jstat -gc $t_id | \
   awk 'BEGIN{FS=" "}{for(i=1;i<=NF;i++) {array[i,NR]=$i}}END {for(i = 1;i <= NF;i++) {for(j = 1;j <= NR;j++) {printf "%s ",array[i,j]}printf "\n"}}' > /tmp/"$t".gc
        done
}

while :; do
        check_mode
        sleep 60
done
```

自动发现tomcat路径，以路径命名

```
[root@iZ62bxn7uuzZ scripts]# cat jvm_name.sh 
#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    jvm_name.sh
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# Apply zabbix version 2.4.x to 3.0.3 
# auto search jmx name.
# You need to understand:
# jstat.sh search pid;jvm_name.sh search tomcat name;jvm_status.sh Obtain $1 transfer
# Automatic discovery jmx monitoring.It applies only to jstat -gc pid it
#################################################################################
tomcat_name=`ps -ef | grep tomcat | grep -v grep | awk -F "=" '{print $NF}' | cut -d "/" -f 3`
falg=0
count=`ps -ef | grep tomcat | grep -v grep | wc -l` 
if [ $count == 0 ];then
exit
fi
echo '{"data":['
echo "$tomcat_name" |while read LINE;do
echo -n '{"{#JVMNAME}":"'$LINE'"}'
flag=`expr $flag + 1`
if [ $flag -lt $count ];then
echo ','
fi
done
echo ']}'
```

```
[root@iZ62bxn7uuzZ scripts]# cat jvm_status.sh 
#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    jvm_status.sh
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# Apply zabbix version 2.4.x to 3.0.3 
# auto search jmx name
# You need to understand:
# jstat.sh search pid;jvm_name.sh search tomcat name;jvm_status.sh Obtain $1 transfer
# Automatic discovery jmx monitoring.It applies only to jstat -gc pid it
#################################################################################
t=$1
jvm_key=$2
cat /tmp/"$t".gc | grep -w "$jvm_key" | awk '{print $2}'
```

顺便过来下http线程

```
[root@iZ62bxn7uuzZ ]# cat jvm_thread_num.sh
#!/bin/sh
jvmname=$1
pid=`ps -ef | grep "$jvmname" | grep -v grep | grep -v "$0"| awk '{print $2}' `
jvm_status=`sudo -u ody /usr/local/java/jdk1.7.0_80/bin/jstack "$pid" > /data/zabbix/shell/jstack.txt`
function all {
    cat /data/zabbix/shell/jstack.txt | grep http|wc -l
         }  
function runnable { 
    cat /data/zabbix/shell/jstack.txt | grep http|grep runnable|wc -l
          }
$2
```


```
UserParameter=jvm.name,/usr/local/zabbix/scripts/jvm_name.sh
UserParameter=jvm.thread.num[*],/usr/local/zabbix/scripts/jvm_thread_num.sh $1 $2
UserParameter=jvm.status[*],/usr/local/zabbix/scripts/jvm_status.sh $1 $2
```

计划任务中需要每分钟执行循环脚本追加文件，保持每分钟的最新状态

```
*/1 * * * * /bin/bash /usr/local/zabbix/scripts/jstat.sh 2>/dev/nul
```