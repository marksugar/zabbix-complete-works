#/bin/bash
# https://github.com/marksugar/zabbix-complete-works
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
#线程处理created
        Threads_created)
        result=`${MYSQL} $DEF "e"|awk '/Threads_created\W/{print $4}'`
        echo $result
        ;;
#线程处理cached
        Threads_cached)
        result=`${MYSQL} $DEF "e"|awk '/Threads_cached\W/{print $4}'`
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
        result=`${MYSQL} $DEF ping|awk '{print $3}'`
        echo $result 
        ;;
        TPS)
        Com_update=`${MYSQL} $DEF extended-status |awk '/Com_update\W/{print $4}'`
        Com_insert=`${MYSQL} $DEF extended-status |awk '/Com_insert\W/{print $4}'`
        Com_delete=`${MYSQL} $DEF extended-status |awk '/Com_delete\W/{print $4}'`
        result=$(($Com_update+$Com_insert+$Com_delete))
        echo $result
        ;;
#缓存使用率
        UsageRate)
        Innodb_buffer_pool_pages_total=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_pages_total/{print $4}'`
        Innodb_buffer_pool_pages_free=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_pages_free/{print $4}'`
#        result=$(awk 'BEGIN{print ($Innodb_buffer_pool_pages_total-$Innodb_buffer_pool_pages_free)/$Innodb_buffer_pool_pages_total * 100}')
        result=$(awk "BEGIN{print ($Innodb_buffer_pool_pages_total-$Innodb_buffer_pool_pages_free)/$Innodb_buffer_pool_pages_total*100 }")
        echo $result
        ;;
#缓存命中率
        HitRate)
        Innodb_buffer_pool_read_requests=`${MYSQL} $DEF "extended-status"|awk '/Innodb_buffer_pool_read_requests/{print $4}'`
        Innodb_buffer_pool_reads=`${MYSQL} $DEF  "extended-status"|awk '/Innodb_buffer_pool_reads/{print $4}'`
        result=$(awk "BEGIN{print ($Innodb_buffer_pool_read_requests-$Innodb_buffer_pool_reads)/$Innodb_buffer_pool_read_requests*100 }")
        echo $result
        ;;
#网络字节数
        Bytes_received)
        result=`${MYSQL} $DEF "e"|awk '/Bytes_received\W/{print $4}'`
        echo $result
        ;;
        Bytes_sent)
        result=`${MYSQL} $DEF "e"|awk '/Bytes_sent\W/{print $4}'`
        echo $result
        ;;
#buffer pool页的状态
#已经使用缓存页数
        Innodb_buffer_pool_pages_data)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_buffer_pool_pages_data\W/{print $4}'`
        echo $result
        ;;
#空闲缓存页数
        Innodb_buffer_pool_pages_free)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_buffer_pool_pages_free\W/{print $4}'`
        echo $result
        ;;
#脏页数目
        Innodb_buffer_pool_pages_dirty)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_buffer_pool_pages_dirty\W/{print $4}'`
        echo $result
        ;;
#每秒刷新页数(diff)
        Innodb_buffer_pool_pages_flushed)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_buffer_pool_pages_flushed\W/{print $4}'`
        echo $result
        ;;
#innodb rows status
        Innodb_rows_inserted)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_rows_inserted\W/{print $4}'`
        echo $result
        ;;
        Innodb_rows_updated)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_rows_updated\W/{print $4}'`
        echo $result
        ;;
        Innodb_rows_deleted)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_rows_deleted\W/{print $4}'`
        echo $result
        ;;
        Innodb_rows_read)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_rows_read\W/{print $4}'`
        echo $result
        ;;
#buffer 数据读写请求数
#数据读总次数
        Innodb_data_reads)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_data_reads\W/{print $4}'`
        echo $result
        ;;
#数据写的总次数
        Innodb_data_writes)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_data_writes\W/{print $4}'`
        echo $result
        ;;
#至此已经读的数据量
        Innodb_data_read)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_data_read\W/{print $4}'`
        echo $result
        ;;
#至此已经写的数据量
        Innodb_data_written)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_data_written\W/{print $4}'`
        echo $result
        ;;
#日志写入磁盘请求
#向日志文件写的总次数
        Innodb_os_log_fsyncs)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_os_log_fsyncs\W/{print $4}'`
        echo $result
        ;;
#写入日志文件的字节数
        Innodb_os_log_written)
        result=`${MYSQL} $DEF "e"|awk '/Innodb_os_log_written\W/{print $4}'`
        echo $result
        ;;
        *) 
        echo "Usage:$0(Com_update|Slow_queries|Com_select|Com_insert|Com_delete|Questions|Threads_connected|Threads_running|Connection_errors_internal|Aborted_connects|Connection_errors_max_connections|Innodb_buffer_pool_read_requests|Innodb_buffer_pool_reads|Innodb_buffer|Innodb_buffer_pool_pages_free|wsrep_cluster_status|wsrep_cluster_size|wsrep_ready|wsrep_local_recv_queue_avg|wsrep_local_send_queue_avg|mping|TPS|UsageRate|HitRate|Threads_connected|Threads_cached|Bytes_received|Bytes_sent|Innodb_buffer_pool_pages_flushed|Innodb_buffer_pool_pages_dirty|Innodb_buffer_pool_pages_free|Innodb_buffer_pool_pages_data|Innodb_rows_inserted|Innodb_rows_updated|Innodb_rows_deleted|Innodb_rows_read|Innodb_data_reads|Innodb_data_writes|Innodb_data_read|Innodb_data_written|Innodb_os_log_fsyncs|Innodb_os_log_written|Threads_created)"
        ;; 
esac