#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    redis3.0.7
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# redis Take hits
# is scripts Take hits hits/(hits+misses)
hits=`awk -F ':' '/keyspace_hits/{print $2}' /tmp/redis-info.txt`
misses=`awk -F ':' '/keyspace_misses/{print $2}' /tmp/redis-info.txt`
a=$hits
#a=14414110
#b=3228654
b=$misses
c=`awk 'BEGIN{a=$a;b=$b;print '$a+$b'}'`
awk 'BEGIN{c=$c;a=$a;print '$a/$c'}'
#awk '{a[NR]=$2;b[NR]=$1;s+=$1}END{for (j=1;j<=NR;j++) printf "%s %.2f%\n",a[j],b[j]*100/s}'
