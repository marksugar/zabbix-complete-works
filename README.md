
![zabbix](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/zabbixx.png)

这是一个私人维护的zabbix安装脚本，它包括了zabbix-server,zabbix-agent的安装，初始化配置，在4.0之后加入了docker-compose，随后的server端都采用了docker安装。在最新的更新中，引入了elasticsearch:6.1.4。在最近的更新中添加了[timescaledb](https://github.com/timescale/timescaledb)。如果你喜欢这个项目，你可以在右上角点击 ♥

-版本信息-

| App         |   docker-compose    |    version                | User ID | port      |date      |
| ----------------|------------- | ---------------------- | ------- | --------- |--------- |
| mysql  | 3.5 | 8.0.15  | 999    | 3306/33060      |2019/0420  |
| docker.elastic.co  |3.5 | elasticsearch:6.1.4  | 1000    | 9200/9300     |2019/0420  |
| zabbix-server-mysql  |3.5 |alpine-4.2-latest  | 100/1000     | 10051    |2019/04/20  |
| zabbix-web-nginx-mysql  |3.5 |alpine-4.2-latest  | 100/1000/101    | 80     |2019/0420  |
| timescaledb | 3.5| timescaledb:latest-pg11-oss | 70|5432 |2019/05/03 |

*note*

![#4CFF33](https://placehold.it/15/4CFF33/000000?text=+) `安装与配置`

* [zabbix-agent](#---Agent安装)
* [zabbix-server](#---server安装)
* [自动发现](#---自动发现)

如果你对docker-compose中的参数有疑问可以参考[linuxea:Zabbix-complete-works之Zabbix基础安装配置](https://www.linuxea.com/2367.html)这篇文章

你至少要使用3.0以上的版本才能够更好的兼容使用。其中保留了一些好的用法，在我看来。这些当中包括：

![#4CFF33](https://placehold.it/15/4CFF33/000000?text=+) `基础监控`

* [/root/.ssh/authorized_keys](#authorized_keys)
* [/etc/passwd](#passwd)
* [/etc/zabbix/zabbix_agentd.conf](#zabbix_agent.conf)
* [OOM](#oom)
* [iptables](#iptables)
* [磁盘io](#磁盘io)
* [tcp](#tcp)

![#4CFF33](https://placehold.it/15/4CFF33/000000?text=+) `应用监控`

* [mariadb-galera](#mariadb-galera)
* [nginx和php-fpm](#nginx和php-fpm)

***[templates](https://github.com/marksugar/zabbix-complete-works/tree/master/app-templates)下载***

## -- **Agent安装**

我在最新的agentd安装脚本中，使用的4.0版本，在这个脚本的包中包含如上的几种基础监控项目。

```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_agent/install-agentd.sh|bash -s local IPADDR |bash
```

> 你需要指定server ip，`base  -s local IPADDR`

*docker和docker-compose安装参考-[docker官网的安装方式](https://docs.docker.com/install/linux/docker-ce/centos/) And - docker-compose安装参考[docker-compose官网的安装方式](https://docs.docker.com/install/linux/docker-ce/centos/)*。或者使用docker部署脚本
```
curl -Lk https://raw.githubusercontent.com/marksugar/MySysOps/master/scripts/docker_init.sh|bash
```

## -- **Server安装**


关于zabbix server分为mysql和timescaledb，但是都启用了elasticsearch


快速部署脚本
- zabbix+timescaledb+elasticsearch (推荐)
```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/zabbix-install/install_zabbix_timescaledb_es.sh|bash
```
- zabbix+mysqldb+elasticsearch
```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/zabbix-install/install_zabbix_mysqldb_es.sh|bash
```
- zabbix+timescaledb (推荐)
```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/zabbix-install/install_zabbix_timescaledb.sh|bash
```
部署细节见[describe.md](https://github.com/marksugar/zabbix-complete-works/blob/master/describe.md)


## -- **自动发现**

自动发现参考[zabbix4.2的自动发现教程](https://github.com/marksugar/zabbix-complete-works/blob/master/discovery.md)

## authorized_keys

这需要sudo权限
```
zabbix ALL=(root)NOPASSWD:/usr/bin/cksum /root/.ssh/authorized_keys
zabbix ALL=(root)NOPASSWD:/usr/bin/awk
```
而后添加
- UserParameter
```
UserParameter=authorized_keys,sudo /usr/bin/cksum /root/.ssh/authorized_keys|awk '{print $1}'
```
如果你有好点子，你可以修改

- Items

![auth1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/auth1.png)

- Trigger

![auth2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/auth2.png)

## passwd

在最新的版本中已经存在
```
UserParameter=status_passwd,cksum /etc/passwd|cut -c 1-5
```

- Items
- Trigger

## zabbix_agent.conf

Not Items

key : `vfs.file.cksum[/etc/zabbix/zabbix_agentd.conf]`

## OOM

```
UserParameter=OOM_stats,sudo awk '/kill|OOM|killer/{print $0}' /var/log/messages|md5sum |cut -c 1-5
```

- Items
- Trigger

## iptables

我仍然使用了及其简单的方式来监控iptables变化，但是你需要注意，这个变化的报警的时间非常短
- UserParameter
```
UserParameter=iptables_lins,/usr/bin/sudo iptables -S |md5sum|cut -c 1-5
UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables|cut -c 1-5
```
另外，需要sudo权限
```
zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables
```

- Items

![iptables1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/iptables1.png)

- Trigger

![iptables2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/iptables2.png)
## 磁盘io

在这里下载perl脚本。并且要给755权限
- UserParameter
```
UserParameter=discovery.disks.iostats,/etc/zabbix/scripts/disk.pl
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$10}'
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 |awk '{print $$4}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$8}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$7}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$11}'
```

这个是一个自动发现做的

- Items

![disl1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/disk1.png)

- Trigger

![disk2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/disk2.png)

> 注意 

你需要创建正则表达式： 名称为`Linux disks for autodiscovery`(必须)

![20190423](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/20190423.png)

- Expression
```
^(s|x?v?)d[a-z][1-9]{0,}$
```

## nginx和php-fpm

准备

```
server {
        listen       40080;
        server_name  localhost;
        location /nginx_status
        {
                stub_status on;
                access_log off;
        }
        location /php-fpm_status
        {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
                include fastcgi_params;
        }
}
```

在这里下载[nginx脚本](https://github.com/marksugar/zabbix-complete-works/blob/master/nginx/nginx_status.sh)

- php

php就更简单了，直接访问抓取即可
- UserParameter
```
UserParameter=nginx.status[*],/etc/zabbix/scripts/nginx_status.sh $1 $2
UserParameter=php-fpm.status[*],/usr/bin/curl -s "http://127.0.0.1:40080/php-fpm_status?xml" | grep "<$1>" | awk -F'>|<' '{ print $$3}'
```

- nginx-Items

![nginx1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/nginx1.png)

- Trigger

![nginx2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/nginx2.png)

- php-fpm-Items

![php-fpm1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/php1.png)

- Trigger

![php2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/php2.png)
## tcp

我用了一种简单的方式来进行监控，在我看来越简单越好用。

需要提醒的是，我存放在计划任务中执行的统计信息，存放在/tmp/下，而后使用脚本去抓取。计划任务默认最小粒度1分钟一次

```
*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt
*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt
```
- UserParameter
```
UserParameter=tcp.status[*],awk '{if ($$1~/^$1/)print $$2}' /tmp/tcp-status.txt
UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l
```

- Items

![tcp1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/tcp1.png)

- Trigger

![tcp1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/tcp2.png)

## mariadb-galera

这是一个非常简单的mariadb-galera-clster监控项目，它并不适用于一般的主从结构

- 授权sql

```
GRANT SELECT ON *.* TO 'zabbix'@'127.0.0.1' IDENTIFIED BY 'password';
```

- UserParameter

```
echo "UserParameter=maria.db[*],/etc/zabbix/scripts/mariadb.sh \$1" >> /etc/zabbix/zabbix_agentd.conf
```

- Items

![mariadb-gra](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/mariadb-gra1.png)

- Trigger

![mariadb-gra2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/mariadb-gra2.png)