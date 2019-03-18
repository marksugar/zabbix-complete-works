
axel -n 20 http://sgp1.mirrors.digitalocean.com/mariadb//mariadb-10.1.19/bintar-linux-x86_64/mariadb-10.1.19-linux-x86_64.tar.gz

修改grub，禁用Transparent Huge Pages
将GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never" 添加到/etc/default/grub
[root@DS-VM-Node61 /usr/local/zabbix/etc]# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never"
[root@DS-VM-Node61 /usr/local/zabbix/etc]# 
添加完成后使其生效
[root@DS-VM-Node61 /usr/local]#  grub2-mkconfig -o /boot/grub2/grub.cfg "$@"
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.18.2.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.18.2.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-327.10.1.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.10.1.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-327.3.1.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.3.1.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-cec933947fc646ac8f83e23f0b67693f
Found initrd image: /boot/initramfs-0-rescue-cec933947fc646ac8f83e23f0b67693f.img
done
临时禁用：
echo never > /sys/kernel/mm/transparent_hugepage/enabled
[root@DS-VM-Node61 /usr/local]# cat /etc/tuned/no-thp/tuned.conf
[main]
include=virtual-guest
[vm]
transparent_hugepages=never
[root@DS-VM-Node61 /usr/local]# tuned-adm profile no-thp

1，下载glibc的mariadb
axel -n 30 http://sgp1.mirrors.digitalocean.com/mariadb//mariadb-10.1.19/bintar-linux-glibc_214-x86_64/mariadb-10.1.19-linux-glibc_214-x86_64.tar.gz
2，编译安装
useradd mysql -s /sbin/nologin -M 
mkdir /data/mysql && chown msyql.mysql /data/mysql
tar xf mariadb-10.1.19-linux-glibc_214-x86_64.tar.gz
scripts/mysql_install_db --user=mysql --datadir=/data/mysql
chown -R mysql.mysql /data/mysql
cp support-files/my-large.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld  && chmod +x /etc/init.d/mysqld


3，配置文件添加到配置

#tokudb
plugin-load = ha_tokudb
tokudb_cache_size = 4G
tokudb_data_dir = /data/mysql/tokudb_data
tokudb_log_dir = /data/mysql/logs
tokudb_tmp_dir = /data/mysql/tmp
tokudb_pk_insert_mode = 2
创建相关的目录
mkdir /data/mysql{logs,tmp,tokudb_data}

重启或者INSTALL 生效即可
[root@DS-VM-Node61 /usr/local]# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5
Server version: 10.1.19-MariaDB MariaDB Server

Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> INSTALL SONAME 'ha_tokudb';
Query OK, 0 rows affected (0.37 sec)

MariaDB [(none)]> show engines;
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| TokuDB             | YES     | Percona TokuDB Storage Engine with Fractal Tree(tm) Technology                                   | YES          | YES  | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)

MariaDB [(none)]> 



各参数说明：

tokudb_cache_size
默认情况下，TokuDB分配50%的系统内存。
tokudb_data_dir
指定TokuDB数据的存储位置。默认为空，使用datadir定义的路径。
tokudb_log_dir
指定TokuDB日志的存储位置。默认为空，使用datadir定义的路径。
tokudb_tmp_dir
TokuDB批量导入数据时，临时文件的存储位置。TokuDB在使用LOAD DATA导入数据的时候会通过临时表(可能会很大)来完成。
默认为空，使用datadir定义的路径。
tokudb_pk_insert_mode
主键写入的模式，只有值为2时，才支持RBR。


my.cnf配置如下：
[client]
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
skip-external-locking
max_allowed_packet = 1M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size= 16M
open_files_limit = 8192
max_connect_errors = 100000
table_open_cache = 2048
table_definition_cache = 2048
max_heap_table_size = 96M
sort_buffer_size = 2M
join_buffer_size = 2M
tmp_table_size = 96M
key_buffer_size = 8M
read_buffer_size = 2M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 32M
thread_concurrency = 8
datadir = /data/mysql
basedir = /usr/local/mysql

##############tokudb
plugin-load = ha_tokudb
tokudb_cache_size = 4G
tokudb_data_dir = /data/mysql/tokudb_data
tokudb_log_dir = /data/mysql/logs
tokudb_tmp_dir = /data/mysql/tmp
tokudb_pk_insert_mode = 2
tokudb_commit_sync = 0
tokudb_directio = 1
tokudb_read_block_size = 128K
tokudb_read_buf_size = 128K
tokudb_row_format = tokudb_fast
###############innodb
innodb_buffer_pool_size = 1G
innodb_buffer_pool_instances = 1
#innodb_data_file_path = ibdata1:1G:autoextend
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 64M
innodb_log_file_size = 256M
innodb_log_files_in_group = 2
innodb_file_per_table = 1
innodb_status_file = 1
transaction_isolation = READ-COMMITTED
innodb_flush_method = O_DIRECT

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

4，授权zabbix
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db LIKE 'test%';
DROP DATABASE test;
UPDATE mysql.user SET password = password('abc123') WHERE user = 'root';
CREATE DATABASE zabbix charset='utf8';
GRANT ALL  ON zabbix.* To 'zabbix'@'%' IDENTIFIED BY 'password';
flush privileges;


5,下载zabbix
[root@DS-VM-Node61 /usr/local]# cd /usr/local && wget https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.2/zabbix-3.2.2.tar.gz 
[root@DS-VM-Node61 /usr/local]# tar xf zabbix-3.2.2.tar.gz  && cd zabbix-3.2.2
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# yum –y install mbedtls-devel gnutls-devel fping sqlite-devel net-snmp-devel libssh2-devel OpenIPMI-devel
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# ./configure --prefix=/usr/local/zabbix --with-iconv --with-libcurl --with-openssl --with-openipmi --with-ssh2 --with-net-snmp --with-libxml2  --with-mysql --enable-ipv6 --enable-agent --enable-server
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# make && make install
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# cp -a /usr/local/zabbix-3.2.2/misc/init.d/fedora/core/zabbix_
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# cp -a /usr/local/zabbix-3.2.2/misc/init.d/fedora/core/* /etc/init.d/
启动脚本需要指定到编译后的安装路径
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# chmod +x /etc/init.d/zabbix_*
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# cp -ra /usr/local/zabbix-3.2.2/frontends/php/* /data/wwwroot/zabbix.ds.com/
[root@DS-VM-Node61 /usr/local/zabbix-3.2.2]# cp /usr/local/zabbix/etc/zabbix_server.conf /etc/zabbix/
[root@DS-VM-Node61 /usr/local/zabbix/etc]# mysql zabbix -uroot -pU1NjdlNmEwZDU5 < /usr/local/zabbix-3.2.2/database/mysql/schema.sql 
[root@DS-VM-Node61 /usr/local/zabbix/etc]# mysql zabbix -uroot -pU1NjdlNmEwZDU5 < /usr/local/zabbix-3.2.2/database/mysql/images.sql 
[root@DS-VM-Node61 /usr/local/zabbix/etc]# mysql zabbix -uroot -pU1NjdlNmEwZDU5 < /usr/local/zabbix-3.2.2/database/mysql/data.sql

6，web安装



7，配置文件
[root@DS-VM-Node61 /usr/local/zabbix/etc]# egrep -v "^$|^#" /etc/zabbix/zabbix_server.conf 
LogFile=/tmp/zabbix_server.log
PidFile=/tmp/zabbix_server.pid
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=pU1NjdlNmEwZDU5
DBSocket=/tmp/mysql.sock
DBPort=3306
Timeout=5
LogSlowQueries=3000
[root@DS-VM-Node61 /usr/local/zabbix/etc]# egrep -v "^$|^#" /etc/zabbix/zabbix_agentd.conf
PidFile=/tmp/zabbix_agentd.pid
LogFile=/tmp/zabbix_agentd.log
Server=127.0.0.1
ListenPort=10050
ServerActive=127.0.0.1
Hostname=Zabbix Server
[root@DS-VM-Node61 /usr/local/zabbix/etc]# 


