#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#########################################################################
# File Name: QPTS.py
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年06月08日 星期三 18时22分06秒
#########################################################################

import sys
import os
import commands

UserName = (sys.argv[1])
PassWord = (sys.argv[2])
HostName = (sys.argv[3])

class QpsTps(object):
    def __init__(self):
        self.QPS = ''
        self.TPS = ''
    def getQps(self):
        (Queries,QPS_result) = commands.getstatusoutput("/usr/local/mariadb/bin/mysql -u%s -p%s -h%s -e 'show status;'|awk '$1==\"Queries\"{print $2}'" %(UserName,PassWord,HostName))
        self.QPS = int(QPS_result)
        return self.QPS
    def getTps(self):
        (Com_commit,cm_result) = commands.getstatusoutput("/usr/local/mariadb/bin/mysql -u%s -p%s -h%s -e 'show status;' |awk '$1==\"Com_commit\"{print $2}'" %(UserName,PassWord,HostName))
        (Com_rollback,rb_result) = commands.getstatusoutput("/usr/local/mariadb/bin/mysql -u%s -p%s -h%s -e 'show status;' |awk '$1==\"Com_rollback\"{print $2}'" %(UserName,PassWord,HostName))
        self.TPS = int(cm_result) + int(rb_result)
        return self.TPS

class error_out(object):
    def error_print(self):
        '''代入值少输，输出错误'''
        print
        print 'Usage : ' + sys.argv[0] + ' MysqlUser MysqlPass MysqlStatusKey '
        print 'EXP   : ' + sys.argv[0] + ' root 123456 QPS '
        print
        sys.exit(1)

class Main(object):
    def main(self):
        if len(sys.argv) <= 4:
            error = error_out()
            error.error_print()
        elif sys.argv[4] == 'QPS':
            a = QpsTps()
            print a.getQps()
        elif sys.argv[4] == 'TPS':
            a = QpsTps()
            print a.getTps()

if __name__ == '__main__':
    main_obj = Main()
    main_obj.main()



zabbix_agentd.comf文件添加
UserParameter=mysql.QPS,/etc/zabbix/scripts/QPTS fpmmm password 127.0.0.1 QPS
UserParameter=mysql.TPS,/etc/zabbix/scripts/QPTS fpmmm password 127.0.0.1 TPS




shell监控：
[root@DS-VM-Node126 /etc/zabbix/scripts]# cat qpts.sh 
#！/bin/bash
MYSQL_USER='fpmmm'
MYSQL_PWD='password'
HOST='127.0.0.1'
MYSQL_PA="/usr/local/mariadb/bin/mysql -u$MYSQL_USER -p$MYSQL_PWD -h$HOST"
if [ $# -ne "1" ];then
        echo "error comm"
fi    
        case $1 in
        Queries)
            result=`$MYSQL_PA -e "show status;"|grep -w "Queries"|awk '{print $2}'`
            echo $result
        ;;
        Com_rollback_to_savepoint)
            result=`$MYSQL_PA -e "show status;"|grep -w "Com_rollback_to_savepoint"|awk '{print $2}'|awk 'NR==1'`
            echo $result
        ;;       
        Com_rollback)
            result=`$MYSQL_PA -e "show status;"|grep -w "Com_rollback"|awk '{print $2}'|awk 'NR==1'`
            echo $result
        ;;        
        Com_commit)
            result=`$MYSQL_PA -e "show status;"|grep -w "Com_commit"|awk '{print $2}'`
            echo $result
        ;;
                        *)    
                echo "Usage:$0{Queries|Com_rollback|Com_commit|Com_rollback_to_savepoint}"
           ;;
esac


zabbix_agentd.comf文件添加
UserParameter=mysql.QPTS[*],/etc/zabbix/scripts/qpts.sh $1
