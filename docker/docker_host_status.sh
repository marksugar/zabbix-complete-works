#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    docker-status
# Revision:    1.1
# Date:        201608016
# Author:      mark
# Email:       usertzc@163.com
# Website:     www.linuxea.com
# -------------------------------------------------------------------------------
# Notice
# After this state will docker stats reorder append to a file
# Auto Discovery docker stats Container Name --no-stream Execution time
###############################################################################
docker_name=`/usr/bin/docker ps -a|grep -v "CONTAINER ID"|awk '{print $NF}'`
for e in ${docker_name};do
        /usr/bin/docker stats $e --no-stream |awk 'NR==2{a=$1;b=$2;c=$3$4;d=$6$7;e=$9$10;f=$12$13;g=$14$15;h=$17$18;j=$8}END{print "CONTAINER "a"\n""CPU "b"\n""MEMUSAGE "c"\n""LIMIT "d"\n""NETI-0 "e"\n""NETI-1 "f"\n""BLOCKI-0 "g"\n""BLOCKI-1 "h" \n""MEM "j}' |awk -F'%' '{print $1}' |awk '{a=/GiB/?$2*1024*1024*1024:(/M[i]?B/?$2*1024*1024:(/[Kk][Bb]/?$2*1024:(/B\>/?$2*1:$2)))}{print $1,a}' > /tmp/.$e.txt 
#        /usr/bin/docker stats $e --no-stream |awk 'NR==2{a=a$1;b=b$2;c=c$3;d=d$6;e=e$9;f=f$12;g=g$14;h=h$17;j=j$8}END{print "CONTAINER "a"\n""CPU "b"\n""MEMUSAGE "c"\n""LIMIT "d"\n""NETI-1 "e"\n""NETI-2 "f"\n""BLOCKI-1 "g"\n""BLOCKI-2 "h" \n""MEM "j}' |awk -F'%' '{print $1}' > /tmp/."$e".txt
done
#/usr/bin/docker top $dockername|grep -v root|grep -v UID|wc -l >>/tmp/.$dockername.txt
