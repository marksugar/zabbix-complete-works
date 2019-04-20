
![zabbix](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/zabbixx.png)

这是一个私人维护的zabbix安装脚本，它包括了zabbix-server,zabbix-agent的安装，初始化配置，在4.0之后加入了docker-compose，随后的server端都采用了docker安装。在最新的更新中，引入了elasticsearch:6.1.4。如果你喜欢这个项目，你可以在右上角点击 ♥

-版本信息-

| App         |   docker-compose    |    version                | User ID | port      |date      |
| ----------------|------------- | ---------------------- | ------- | --------- |--------- |
| mysql  | 3.5 | 8.0.15  | 999    | 3306/33060      |2019/0420  |
| docker.elastic.co/elasticsearch/elasticsearch  |3.5 | 6.1.4  | 1000    | 9200/9300     |2019/0420  |
| zabbix-server-mysql  |3.5 |alpine-4.2-latest  | 100/1000     | 10051    |2019/0420  |
| zabbix-web-nginx-mysql  |3.5 |alpine-4.2-latest  | 100/1000/101    | 80     |2019/0420  |

*note*

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

-- **Agent安装**

我在最新的agentd安装脚本中，使用的4.0版本，在这个脚本的包中包含如上的几种基础监控项目。

```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_agent/install-agentd.sh|bash -s local IPADDR |bash
```

> 你需要指定server ip，`base  -s local IPADDR`

-- **Server安装**

```
wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server/docker-compose.yaml
docker-compose -f docker-compose.yaml up -d
```
*docker和docker-compose安装参考[docker官网的安装方式](https://docs.docker.com/install/linux/docker-ce/centos/)[docker-compose安装](docker和docker-compose安装参考[官网的安装方式](https://docs.docker.com/install/linux/docker-ce/centos/)*
> *elasticsearch*

\*\*你需要注意权限问题，如本示例docker-compose中需要授权:  chown -R 1000.1000 /data/elasticsearch/\*\*

我整理了[索引文件](https://github.com/marksugar/zabbix-complete-works/tree/master/elasticsearch/6.1.4)，执行创建索引即可,你也可以参考[官网文档]( https://www.zabbix.com/documentation/devel/manual/appendix/install/elastic_search_setup)

正常情况下你将看到如下信息：
```
$ curl http://127.0.0.1:9200/_cat/indices?v
health status index                       uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   str                         MQWM2bNNRzOvBywM7ne-lw   5   1          0            0      1.1kb          1.1kb
yellow open   .monitoring-es-6-2019.04.20 tIfs0MkNQUCI4YuEHRmQ6g   1   1       1926          208    901.6kb        901.6kb
yellow open   dbl                         Y0992hqaR8KTin9iXKsljQ   5   1          0            0      1.1kb          1.1kb
yellow open   text                        s2XMyJtdQQ27b9rS3nWVfg   5   1          0            0      1.1kb          1.1kb
yellow open   log                         MAysNczpSKGZbjfjJXBvTg   5   1          0            0      1.1kb          1.1kb
yellow open   uint                        JA_8kyXlSLqawyHzo28Ggw   5   1          0            0      1.1kb          1.1kb
```

如果手动导入sql参考如下页面：

https://www.zabbix.com/documentation/4.2/manual/appendix/install/db_scripts
https://www.zabbix.com/documentation/4.2/manual/appendix/install/elastic_search_setup

-- **自动发现**

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