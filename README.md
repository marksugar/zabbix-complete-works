
***
## zabbix Common items Monitoring：

* This is a common monitoring zabbix item contains php-fpm, nginx, redis, tomcat, tcp, fdisk, mysql-fpmmm, most of the auto-discovery to be monitored

## note:
* Suitable for zabbix 2.7 - 3.0.x

You can visit the blog author [Linuxea](http://www.linuxea.com)

![](http://www.zabbix.com/img/3.0/whatsnew/zabbix-whats-new-3.0-dashboard.png)


## installscripts.sh
**local network**

[root@LinuxEA ~]# bash bs.sh local 192.168.1.1


**internet**

[root@LinuxEA ~]# bash bs.sh net 10.10.123.123

**scripts**

curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix/master/installscripts.sh|bash -s net 10.10.123.123

**安装zabbix，初始化系统，安装docker**
*1,install zabbix*
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/zabbix-install.sh |bash -s net 10.10.123.123
*2,系统初始化，嵌套安装zabbix和其他*
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/main.sh |bash
*3,install docker*
curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/docker-install.sh | bash -s aufs
