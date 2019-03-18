#!/bin/bash
#!/bin/bash
REDISPATH="/usr/local/bin/redis-cli"
HOST="127.0.0.1"
PORT="6379"
REDIS_PA="$REDISPATH -h $HOST -p $PORT info"
if [[ $# == 1 ]];then
    case $1 in
 cluster)
        result=`$REDIS_PA|/bin/grep cluster|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 uptime_in_seconds)
        result=`$REDIS_PA|/bin/grep uptime_in_seconds|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 connected_clients)
        result=`$REDIS_PA|/bin/grep connected_clients|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 client_longest_output_list)
        result=`$REDIS_PA|/bin/grep client_longest_output_list|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 client_biggest_input_buf)
        result=`$REDIS_PA|/bin/grep client_biggest_input_buf|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 blocked_clients)
        result=`$REDIS_PA|/bin/grep blocked_clients|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
#内存
 used_memory)
        result=`$REDIS_PA|/bin/grep used_memory|awk -F":" '{print $NF}'|awk 'NR==1'`
            echo $result 
            ;; 
 used_memory_human)
        result=`$REDIS_PA|/bin/grep used_memory_human|awk -F":" '{print $NF}'|awk -F'K' '{print $1}'` 
            echo $result 
            ;; 
 used_memory_rss)
        result=`$REDIS_PA|/bin/grep used_memory_rss|awk -F":" '{print $NF}'`
            echo $result 
            ;; 
 used_memory_peak)
        result=`$REDIS_PA|/bin/grep used_memory_peak|awk -F":" '{print $NF}'|awk 'NR==1'`
            echo $result 
            ;; 
 used_memory_peak_human)
        result=`$REDIS_PA|/bin/grep used_memory_peak_human|awk -F":" '{print $NF}'|awk -F'K' '{print $1}'`
            echo $result 
            ;; 
 used_memory_lua)
        result=`$REDIS_PA|/bin/grep used_memory_lua|awk -F":" '{print $NF}'`
            echo $result 
            ;;     
 mem_fragmentation_ratio)
        result=`$REDIS_PA|/bin/grep mem_fragmentation_ratio|awk -F":" '{print $NF}'`
            echo $result 
            ;;   
#rdb
 rdb_changes_since_last_save)
        result=`$REDIS_PA|/bin/grep rdb_changes_since_last_save|awk -F":" '{print $NF}'`
            echo $result 
            ;;   
 rdb_bgsave_in_progress)
        result=`$REDIS_PA|/bin/grep rdb_bgsave_in_progress|awk -F":" '{print $NF}'`
            echo $result 
            ;;   
 rdb_last_save_time)
        result=`$REDIS_PA|/bin/grep rdb_last_save_time|awk -F":" '{print $NF}'`
            echo $result 
            ;;   
 rdb_last_bgsave_status)
        result=`$REDIS_PA|/bin/grep -w "rdb_last_bgsave_status" | awk -F':' '{print $2}' | /bin/grep -c ok`
            echo $result 
            ;;   
 rdb_current_bgsave_time_sec)
        result=`$REDIS_PA|/bin/grep -w "rdb_current_bgsave_time_sec" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
#rdbinfo
 aof_enabled)
        result=`$REDIS_PA|/bin/grep -w "aof_enabled" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_rewrite_scheduled)
        result=`$REDIS_PA|/bin/grep -w "aof_rewrite_scheduled" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_last_rewrite_time_sec)
        result=`$REDIS_PA|/bin/grep -w "aof_last_rewrite_time_sec" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_current_rewrite_time_sec)
        result=`$REDIS_PA|/bin/grep -w "aof_current_rewrite_time_sec" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_last_bgrewrite_status)
        result=`$REDIS_PA|/bin/grep -w "aof_last_bgrewrite_status" | awk -F':' '{print $2}' | /bin/grep -c ok`
            echo $result 
            ;; 
#aofinfo
 aof_current_size)
        result=`$REDIS_PA|/bin/grep -w "aof_current_size" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_base_size)
        result=`$REDIS_PA|/bin/grep -w "aof_base_size" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_pending_rewrite)
        result=`$REDIS_PA|/bin/grep -w "aof_pending_rewrite" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_buffer_length)
        result=`$REDIS_PA|/bin/grep -w "aof_buffer_length" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 aof_rewrite_buffer_length)
        result=`$REDIS_PA|/bin/grep -w "aof_rewrite_buffer_length" | awk -F':' '{print $2}'`
            echo $result 
            ;;   
 aof_pending_bio_fsync)
        result=`$REDIS_PA|/bin/grep -w "aof_pending_bio_fsync" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 aof_delayed_fsync)
        result=`$REDIS_PA|/bin/grep -w "aof_delayed_fsync" | awk -F':' '{print $2}'`
            echo $result 
            ;;                     
#stats
 total_connections_received)
        result=`$REDIS_PA|/bin/grep -w "total_connections_received" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 total_commands_processed)
        result=`$REDIS_PA|/bin/grep -w "total_commands_processed" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 instantaneous_ops_per_sec)
        result=`$REDIS_PA|/bin/grep -w "instantaneous_ops_per_sec" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 rejected_connections)
        result=`$REDIS_PA|/bin/grep -w "rejected_connections" | awk -F':' '{print $2}'` 
            echo $result 
            ;; 
 expired_keys)
        result=`$REDIS_PA|/bin/grep -w "expired_keys" | awk -F':' '{print $2}'`
            echo $result 
            ;; 
 evicted_keys)
        result=`$REDIS_PA|/bin/grep -w "evicted_keys" | awk -F':' '{print $2}'` 
            echo $result 
            ;; 
 keyspace_hits)
        result=`$REDIS_PA|/bin/grep -w "keyspace_hits" | awk -F':' '{print $2}'` 
            echo $result 
            ;; 
 keyspace_misses)
        result=`$REDIS_PA|/bin/grep -w "keyspace_misses" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 pubsub_channels)
        result=`$REDIS_PA|/bin/grep -w "pubsub_channels" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 pubsub_channels)
        result=`$REDIS_PA|/bin/grep -w "pubsub_channels" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 pubsub_patterns)
        result=`$REDIS_PA|/bin/grep -w "pubsub_patterns" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 latest_fork_usec)
        result=`$REDIS_PA|/bin/grep -w "latest_fork_usec" | awk -F':' '{print $2}'`
            echo $result 
            ;;           
 connected_slaves)
        result=`$REDIS_PA|/bin/grep -w "connected_slaves" | awk -F':' '{print $2}'`
            echo $result 
            ;;
 master_link_status)
        result=`$REDIS_PA|/bin/grep -w "master_link_status"|awk -F':' '{print $2}'|/bin/grep -c up`
            echo $result 
            ;;
 master_last_io_seconds_ago)
        result=`$REDIS_PA|/bin/grep -w "master_last_io_seconds_ago"|awk -F':' '{print $2}'`
            echo $result 
            ;;
 master_sync_in_progress)
        result=`$REDIS_PA|/bin/grep -w "master_sync_in_progress"|awk -F':' '{print $2}'`
            echo $result 
            ;;
 slave_priority)
        result=`$REDIS_PA|/bin/grep -w "slave_priority"|awk -F':' '{print $2}'`
            echo $result 
            ;;
#cpu
 used_cpu_sys)
        result=`$REDIS_PA|/bin/grep -w "used_cpu_sys"|awk -F':' '{print $2}'`
            echo $result 
            ;;
 used_cpu_user)
        result=`$REDIS_PA|/bin/grep -w "used_cpu_user"|awk -F':' '{print $2}'`
            echo $result 
            ;;
 used_cpu_sys_children)
        result=`$REDIS_PA|/bin/grep -w "used_cpu_sys_children"|awk -F':' '{print $2}'`
            echo $result 
            ;;
 used_cpu_user_children)
        result=`$REDIS_PA|/bin/grep -w "used_cpu_user_children"|awk -F':' '{print $2}'`
            echo $result 
            ;;
        *)
        echo "Usage:$0{uptime_in_seconds|connected_clients|client_longest_output_list|client_biggest_input_buf|blocked_clients|used_memory|used_memory_human|used_memory_rss|used_memory_peak|used_memory_peak_human|used_memory_lua|mem_fragmentation_ratio|rdb_changes_since_last_save|rdb_bgsave_in_progress|rdb_last_save_time|rdb_last_bgsave_status|rdb_current_bgsave_time_sec|aof_enabled|aof_rewrite_scheduled|aof_last_rewrite_time_sec|aof_current_rewrite_time_sec|aof_last_bgrewrite_status|aof_current_size|aof_base_size|aof_pending_rewrite|aof_buffer_length|aof_rewrite_buffer_length|aof_pending_bio_fsync|aof_delayed_fsync|rejected_connections|instantaneous_ops_per_sec|total_connections_received|total_commands_processed|expired_keys|evicted_keys|keyspace_hits|keyspace_misses|pubsub_channels|pubsub_patterns|latest_fork_usec|connected_slaves|master_link_status|master_sync_in_progress|master_last_io_seconds_ago|connected_slaves|slave_priority|used_cpu_user|used_cpu_sys|used_cpu_sys_children|used_cpu_user_children}"
        ;;
esac
#db0:key
        elif [[ $# == 2 ]];then
case $2 in
  keys)
        result=`$REDIS_PA| /bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "keys" | awk -F'=|,' '{print $2}'`
            echo $result 
            ;;
 expires)
        result=`$REDIS_PA| /bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "expires" | awk -F'=|,' '{print $4}'`
            echo $result 
            ;;
 avg_ttl)
        result=`$REDIS_PA|/bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "avg_ttl" | awk -F'=|,' '{print $6}'`
            echo $result 
            ;;
          *)
     echo "Usage:$0{db0 keys|db0 expires|db0 avg_ttl}"
        ;;
esac
fi




UserParameter=redis_info[*],/etc/zabbix/scripts/redis_info.sh $1 $2



sed -i 's/# PidFile=/tmp/zabbix_server.pid/PidFile=/tmp/zabbix_server.pid/g' /etc/zabbix/zabbix_server.conf

sed -i 's/;date.timezone =/date.timezone = Asia/Shanghai/g' /etc/php.ini
Database type  选择mysql即可
Database host  选择localhost
Database port  mysql端口
Database name  库名
User           链接库用户名
Password       链接库密码

Server=127.0.0.1
Hostname=Zabbix server


systemctl enable mariadb
systemctl enable httpd
systemctl enable zabbix-server
systemctl enable zabbix-agent
systemctl enable zabbix-java-gateway
