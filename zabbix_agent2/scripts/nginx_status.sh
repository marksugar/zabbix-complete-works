#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    nginx-status.sh
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# Apply zabbix version 2.4.x to 3.0.3 
# Nginx Need to open nginx status modules
#################################################################################
PORT="40080"
CLU="/usr/bin/curl http://127.0.0.1:$PORT/nginx_status"
#FILE=/tmp/nginx_status.txt
if [[ $# == 1 ]]; then
        case $1 in
        #当前处于打开状态的连接数
        Active)
                output=`$CLU 2>/dev/null |awk '/Active/{print $3}'` 2>/dev/null
                echo $output
        ;;
        #共处理的链接，已经接受的链接
        server)
                output=`$CLU 2>/dev/null |awk 'NR==3{print $1}'` 2>/dev/null
                echo $output
        ;;
        #成功创建握手，已经处理的链接
        accepts)
                output=`$CLU 2>/dev/null |awk 'NR==3{print $2}'` 2>/dev/null
                echo $output
        ;;
        #已经处理的链接，共处理的请求书
        handled)
                output=`$CLU 2>/dev/null |awk 'NR==3{print $3}'` 2>/dev/null
                echo $output
        ;;
        #读取客户端的连接数，正处于接受请求状态的连接数
        reading)
                output=`$CLU 2>/dev/null |awk 'NR==4{print $2}'` 2>/dev/null
                echo $output
        ;;
        #相应数据到客户端的数量，请求已经接受完成，正处于处理请求或发送响应的过程的连接数
        Writing)
                output=`$CLU 2>/dev/null |awk 'NR==4{print $4}'` 2>/dev/null
                echo $output
        ;;
        #开启keep-alive的情况下，这个值等于active-(reading+writing),意思就是nginx已经处理完正在等候下一个请求指令的驻留链接
        #保持链接模式，且处于活动状态的连接数
        Waiting)
                output=`$CLU 2>/dev/null |awk 'NR==4{print $6}'` 2>/dev/null
                echo $output
        ;;
        *)
        echo "Usage:$0{Active|server|accepts|handled|reading|Writing|Waiting}"
        ;;
esac
fi

