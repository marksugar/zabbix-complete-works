#/bin/bash
DEF="--defaults-file=/etc/zabbix/zabbixmy.conf"
MYSQL='/usr/local/mariadb/bin/mysqladmin'
ARGS=1 
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:" 
fi 
case $1 in 
        Com_update) 
                result=`${MYSQL} $DEF extended-status |awk '/Com_update\W/{print $4}'`
                echo $result 
                ;; 
        Slow_queries) 
                result=`${MYSQL} $DEF extended-status |awk '/Slow_queries/{print $4}'`
                echo $result 
        ;; 
        com_select) 
                result=`${MYSQL} $DEF extended-status |awk '/Com_select\W/{print $4}'`
                echo $result 
        ;;               
        Com_insert) 
                result=`${MYSQL} $DEF extended-status |awk '/Com_insert\W/{print $4}'`
        echo $result 
        ;; 
        Com_delete) 
                result=`${MYSQL} $DEF extended-status |awk '/Com_delete\W/{print $4}'`
        echo $result 
        ;; 
#查询的数量                      
        Questions) 
        result=`${MYSQL} $DEF status|awk '/Questions/{print $6}'`
        echo $result 
        ;;  
#已经建立的链接
        Threads_connected) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Threads_connected/{print $4}'`
        echo $result 
        ;;       
#正在运行的连接          
        Threads_running) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Threads_running/{print $4}'`
        echo $result 
        ;; 
#由于服务器内部本身导致的错误
        Connection_errors_internal) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Connection_errors_internal/{print $4}'`
        echo $result 
        ;;       
#尝试与服务器建立连接但是失败的次数
        Aborted_connects) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Aborted_connects/{print $4}'`
        echo $result 
        ;;       
#由于到达最大连接数导致的错误
        Connection_errors_max_connections) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Connection_errors_max_connections/{print $4}'`
        echo $result 
        ;;       
#Innodb_buffer读取缓存请求的数量         
        Innodb_buffer_pool_read_requests) 
        result=`${MYSQL} $DEF "extended-status"|awk '/Innodb_buffer_pool_read_requests/{print $4}'`
        echo $result 
        ;;  
#Innodb_buffer需要读取磁盘的请求数 
        Innodb_buffer_pool_reads) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_reads/{print $4}'`
        echo $result 
        ;;  
#Innodb_buffer BP中总页面数 
        Innodb_buffer_pool_pages_total) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_pages_total/{print $4}'`
        echo $result 
        ;;  
#Innodb_buffer空页数
        Innodb_buffer_pool_pages_free) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_pages_free/{print $4}'`
        echo $result 
        ;;                                                       
#wsrep_cluster_status集群状态
        wsrep_cluster_status) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/wsrep_cluster_status/{print $4}'`
        echo $result 
        ;; 
#wsrep_cluster_size集群成员
        wsrep_cluster_size) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/wsrep_cluster_size/{print $4}'`
        echo $result 
        ;;  
#wsrep_ready
        wsrep_ready) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/wsrep_ready/{print $4}'`
        echo $result 
        ;; 
#wsrep_local_recv_queue_avg平均请求队列长度
        wsrep_local_recv_queue_avg) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/wsrep_local_recv_queue_avg/{print $4}'`
        echo $result 
        ;;  
#wsrep_local_send_queue_avg上次查询之后的平均发送队列长度
        wsrep_local_send_queue_avg) 
        result=`${MYSQL} $DEF  "extended-status"|awk '/wsrep_local_send_queue_avg/{print $4}'`
        echo $result 
        ;;  
        mping) 
        result=`${MYSQL} $DEF ping|grep -c alive`
        echo $result 
        ;;       
        *) 
        echo "Usage:$0(Com_update|Slow_queries|Com_select|Com_insert|Com_delete|Questions|Threads_connected|Threads_running|Connection_errors_internal|Aborted_connects|Connection_errors_max_connections|Innodb_buffer_pool_read_requests|Innodb_buffer_pool_reads|Innodb_buffer|Innodb_buffer_pool_pages_free|wsrep_cluster_status|wsrep_cluster_size|wsrep_ready|wsrep_local_recv_queue_avg|wsrep_local_send_queue_avg|mping)" 
        ;; 
esac
