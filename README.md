
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
