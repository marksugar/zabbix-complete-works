#!/bin/bash
#########################################################################
# File Name: redis.sh
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# https://github.com/marksugar/zabbix-complete-works
#########################################################################

#REDIS_CLI="$(type redis-cli|awk -F\( '{print $2}'|awk -F\) '{print $1}')"
REDIS_CLI='redis-cli'
PASWD='mima'
REDIS_COMM="$REDIS_CLI -a $PASWD"
ARGS=1
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:"
fi
case $1 in
#慢查询条目
        SLOWLOG)
        result=`${REDIS_COMM}  --no-raw  slowlog get|grep "1) (integer)"|wc -l`
        echo $result
        ;;
# 延迟监控
# 开启：CONFIG SET latency-monitor-threshold 100
        #微秒microseconds
        latency_max)
        result=`${REDIS_COMM} --intrinsic-latency 20 > /tmp/redis-intrinsic-latency && tail -4 /tmp/redis-intrinsic-latency | awk 'NR==1{print $5}'`
        echo $result
        ;;
        #微秒microseconds
        latency_avg)
        result=`tail -4 /tmp/redis-intrinsic-latency | awk 'NR==3{print $6}'`
        echo $result
        ;;
        #纳秒nanoseconds
        latency_run_time)
        result=`tail -4 /tmp/redis-intrinsic-latency | awk 'NR==3{print $9}'`
        echo $result
        ;;
        latency_max_1)
        result=`tail -4 /tmp/redis-intrinsic-latency | awk 'NR==1{print $5}'`
        echo $result
        ;;
        #HitRate
        #keyspace_hits/(keyspace_hits+keyspace_misses)
        HitRate)
        keyspace_hits=`${REDIS_COMM}  --no-raw info stats | awk -F: '/keyspace_hits/{print $2}'`
        keyspace_misses=`${REDIS_COMM} --no-raw info stats |awk -F: '/keyspace_misses/{print $2}'`
        result=$(awk "BEGIN{print $keyspace_hits/($keyspace_hits-$keyspace_misses+0.1) }")
        echo $result
        ;;
        # 设置maxclients的值
        maxclients)
        result=`${REDIS_COMM} config get maxclients|awk -F\"  'END{print $0}'`
        echo $result
        ;;
        rdb_last_save_time)
        rdb_last_save_time=`${REDIS_COMM} info | awk -F: '/rdb_last_save_time/{print $2}'`
        result=`date -d @$rdb_last_save_time "+%Y%m%d%H%M%S"`
        echo $result
        ;;
        used_memory_rss_human)
        result=`${REDIS_COMM} info  |awk -F: '/used_memory_rss_human/{print $2}'|awk -F'M|K|G'  '{print $1}'`
        echo $result
        ;;
        used_memory_human)
        result=`${REDIS_COMM} info  |awk -F: '/used_memory_human/{print $2}'|awk -F'M|K|G' '{print $1}'`
        echo $result
        ;;
        total_system_memory_human)
        result=`${REDIS_COMM} info  |awk -F: '/total_system_memory_human/{print $2}'|awk -F'M|K|G' '{print $1}'`
        echo $result
        ;;
        ping)
        result=`${REDIS_COMM} ping`
        echo $result
        ;;
        *)
        echo "Usage:$0(SLOWLOG|latency_max|latency_avg|latency_run_time|HitRate|maxclients|used_memory_rss_human|used_memory_human|total_system_memory_human|latency_max_1|ping)"
        ;;
esac