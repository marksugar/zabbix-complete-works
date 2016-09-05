UserParameter=redis_info[*],/usr/local/zabbix/scripts/redis_info.sh $1 $2

203.88.165.32 16388
/usr/bin/redis-cli -h 203.88.165.32 -p 16388 info > /tmp/redis-info.txt 2>/dev/null
#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    redis3.0.7
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
#################################################################################
REDISPATH="/usr/local/bin/redis-cli"
HOST="127.0.0.1"
PORT="6379"
/usr/local/bin/redis-cli -h $HOST -p $PORT info > /tmp/redis-info.txt 2>/dev/null
chown zabbix.zabbix $FILE
FILE=/tmp/redis-info.txt
if [[ $# == 1 ]];then
    case $1 in
 cluster)
        result=`awk -F":" '/cluster/{print $NF}' $FILE`
            echo $result 
            ;; 
 uptime_in_seconds)
        result=`awk -F":" '/uptime_in_seconds/{print $NF}' $FILE`
            echo $result 
            ;; 
 connected_clients)
        result=`awk -F":" '/connected_clients/{print $NF}' $FILE`
            echo $result 
            ;; 
 client_longest_output_list)
        result=`awk -F":" '/client_longest_output_list/{print $NF}' $FILE`
            echo $result 
            ;; 
 client_biggest_input_buf)
        result=`awk -F":" '/client_biggest_input_buf/{print $NF}' $FILE`
            echo $result 
            ;; 
 blocked_clients)
        result=`awk -F":" '/blocked_clients/{print $NF}' $FILE`
            echo $result 
            ;; 
#内存
 used_memory)
        result=`awk -F ':' '/used_memory\>/{print $2}' $FILE`
            echo $result 
            ;; 
 used_memory_huMan)
        result=`awk -F'[:K]' '/used_memory_human/{print $2}'  $FILE` 
            echo $result 
            ;; 
 used_memory_rss)
        result=`awk -F ':' '/used_memory_rss/{print $2}' $FILE`
            echo $result 
            ;; 
 used_memory_peak)
        result=`awk -F ':' '/used_memory_peak\>/{print $2}' $FILE`
            echo $result 
            ;; 
 used_memory_peak_human)
        result=`awk -F '[K:]' '/used_memory_peak_human/{print $2}' $FILE`
            echo $result 
            ;; 
 used_memory_lua)
        result=`awk -F ':' '/used_memory_lua/{print $2}' $FILE`
            echo $result 
            ;;     
 mem_fragmentation_ratio)
        result=`awk -F ':' '/mem_fragmentation_ratio/{print $2}' $FILE`
            echo $result 
            ;;   
#rdb
 rdb_changes_since_last_save)
        result=`awk -F ':' '/rdb_changes_since_last_save/{print $2}' $FILE`
            echo $result 
            ;;   
 rdb_bgsave_in_progress)
        result=`awk -F ':' '/rdb_bgsave_in_progress/{print $2}' $FILE`
            echo $result 
            ;;   
 rdb_last_save_time)
        result=`awk -F ':' '/rdb_last_save_time/{print $2}' $FILE`
            echo $result 
            ;;   
 rdb_last_bgsave_status)
        result=`awk -F ':' '/rdb_last_bgsave_status/{print $2}' $FILE | /bin/grep -c ok`
            echo $result 
            ;;   
 rdb_current_bgsave_time_sec)
        result=`awk -F ':' '/rdb_current_bgsave_time_sec/{print $2}' $FILE`
            echo $result 
            ;; 
#rdbinfo
 aof_enabled)
        result=`awk -F ':' '/aof_enabled/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_rewrite_scheduled)
        result=`awk -F ':' '/aof_rewrite_scheduled/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_last_rewrite_time_sec)
        result=`awk -F ':' '/aof_last_rewrite_time_sec/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_current_rewrite_time_sec)
        result=`awk -F ':' '/aof_current_rewrite_time_sec/{print $2}'  $FILE`
            echo $result 
            ;; 
 aof_last_bgrewrite_status)
        result=`awk -F ':' '/aof_last_bgrewrite_status/{print $2}' $FILE | /bin/grep -c ok`
            echo $result 
            ;; 
#aofinfo
 aof_current_size)
        result=`awk -F ':' '/aof_current_size/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_base_size)
        result=`awk -F ':' '/aof_base_size/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_pending_rewrite)
        result=`awk -F ':' '/aof_pending_rewrite/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_buffer_length)
        result=`awk -F ':' '/aof_buffer_length/{print $2}' $FILE`
            echo $result 
            ;; 
 aof_rewrite_buffer_length)
        result=`awk -F ':' '/aof_rewrite_buffer_length/{print $2}' $FILE`
            echo $result 
            ;;   
 aof_pending_bio_fsync)
        result=`awk -F ':' '/aof_pending_bio_fsync/{print $2}' $FILE`
            echo $result 
            ;;
 aof_delayed_fsync)
        result=`awk -F ':' '/aof_delayed_fsync/{print $2}' $FILE`
            echo $result 
            ;;                     
#stats
 total_connections_received)
        result=`awk -F ':' '/total_connections_received/{print $2}' $FILE`
            echo $result 
            ;; 
 total_commands_processed)
        result=`awk -F ':' '/total_commands_processed/{print $2}' $FILE`
            echo $result 
            ;; 
 instantaneous_ops_per_sec)
        result=`awk -F ':' '/instantaneous_ops_per_sec/{print $2}' $FILE`
            echo $result 
            ;; 
 rejected_connections)
        result=`awk -F ':' '/rejected_connections/{print $2}' $FILE` 
            echo $result 
            ;; 
 expired_keys)
        result=`awk -F ':' '/expired_keys/{print $2}' $FILE`
            echo $result 
            ;; 
 evicted_keys)
        result=`awk -F ':' '/evicted_keys/{print $2}' $FILE` 
            echo $result 
            ;; 
 keyspace_hits)
        result=`awk -F ':' '/keyspace_hits/{print $2}' $FILE` 
            echo $result 
            ;; 
 keyspace_misses)
        result=`awk -F ':' '/keyspace_misses/{print $2}' $FILE`
            echo $result 
            ;;
 pubsub_channels)
        result=`awk -F ':' '/pubsub_channels/{print $2}' $FILE`
            echo $result 
            ;;
 pubsub_channels)
        result=`awk -F ':' '/pubsub_channels/{print $2}' $FILE`
            echo $result 
            ;;
 pubsub_patterns)
        result=`awk -F ':' '/pubsub_patterns/{print $2}'  $FILE`
            echo $result 
            ;;
 latest_fork_usec)
        result=`awk -F ':' '/latest_fork_usec/{print $2}' $FILE`
            echo $result 
            ;;           
 connected_slaves)
        result=`awk -F ':' '/connected_slaves/{print $2}' $FILE`
            echo $result 
            ;;
 master_link_status)
        result=`awk -F ':' '/master_link_status/{print $2}' $FILE |/bin/grep -c up`
            echo $result 
            ;;
 master_last_io_seconds_ago)
        result=`awk -F ':' '/master_last_io_seconds_ago/{print $2}' $FILE`
            echo $result 
            ;;
 master_sync_in_progress)
        result=`awk -F ':' '/master_sync_in_progress/{print $2}' $FILE`
            echo $result 
            ;;
 slave_priority)
        result=`awk -F ':' '/slave_priority/{print $2}' $FILE`
            echo $result 
            ;;
#cpu
 used_cpu_sys)
        result=`awk -F ':' '/used_cpu_sys\>/{print $2}' $FILE`
            echo $result 
            ;;
 used_cpu_user)
        result=`awk -F ':' '/used_cpu_user\>/{print $2}' $FILE`
            echo $result 
            ;;
 used_cpu_sys_children)
        result=`awk -F ':' '/used_cpu_sys_children\>/{print $2}' $FILE`
            echo $result 
            ;;
 used_cpu_user_children)
        result=`awk -F ':' '/used_cpu_user_children\>/{print $2}' $FILE`
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
        result=`cat $FILE | /bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "keys" | awk -F'=|,' '{print $2}'`
            echo $result 
            ;;
 expires)
        result=`cat $FILE | /bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "expires" | awk -F'=|,' '{print $4}'`
            echo $result 
            ;;
 avg_ttl)
        result=`cat $FILE |/bin/grep -w "db0"| /bin/grep -w "$1" | /bin/grep -w "avg_ttl" | awk -F'=|,' '{print $6}'`
            echo $result 
            ;;
          *)
     echo "Usage:$0{db0 keys|db0 expires|db0 avg_ttl}"
        ;;
esac
fi
