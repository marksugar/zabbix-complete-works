#!/bin/bash
#########################################################################
# Created Time: 2017年11月28日 星期二 16时27分47秒
#########################################################################
echo -e '''
\033[32m Welcome to this script! \033[0m
\033[32m you need to enter the corresponding number according to the situation. \033[0m
\033[32m good luck ! \033[0m
'''
#echo -e "1, 查看内存占用前10进程\n2, 查看CPU占用前10进程"
while read  -p '
############################################
#		q, 退出
#		1, 查看内存占用前10进程
#		2, 查看CPU占用前10进程
#		3, 查看内存资源损耗(dstat)
#		4, 查看CPU资源损耗(dstat)
#		A, 查看程序io的读写
#		5, strace追踪
#		6, 查看tcp链接状态
#		7, 列出最多端口的端口号
#		B, 计算当前一小时内的访问量
#		C, 计算当前一分钟内的域名访问量
#		D, 计算每小时日志访问量
#		600, Pstree进程
#############################################
Enter A Number:' ENZ;do
	case $ENZ in
	q)
	exit 1;;
	1)
	ps aux|sort -k4nr|head -20;;
	2)
	ps aux|sort -k3nr|head -20;; #cpu占用前20的进程
	600)
	read -p 'Enter the name of the program you want to track:' PP
		pstree -a $PP;;
	3)
	dstat -g -l -m -s --top-mem 1 5;;
	4)
	dstat -c -y -l --proc-count --top-cpu 1 5;;
	5)
	read -p 'Enter the name:' PGG
		PPD=`pgrep -o ${PGG}`
		PSTINFO=`strace -o /tmp/output.txt -T -tt -e trace=all -p ${PPD}  >/dev/null`
		echo "check /tmp/output.txt"
		exit 1;;
	6)
	/usr/sbin/ss  -tan|awk 'NR>1{++S[$1]}END{for (a in S) print a,S[a]}';;
	7)
	ss -an | awk -F"[[:space:]]+|:" '{S[$5]++}END{for(i in S){print S[i]"\t"i}}' | sort -rn |head -n 10;;
	A)
	dstat -t -n --top-io 1 5;;
	B)
	read -p "请输入日志文件的绝对路径:" PAT
	awk -F":" '$2 == hour {S[$3]++}END{for(i in S){print i"\t"S[i]}}' hour=`date +%H` ${PAT} |sort -n;;
	C)
	read -p "请输入日志文件的绝对路径:" PATT
	awk -F'"|:' '$2 == hour && $3 == min && /GET/ {S[$8]++}END{for(i in S){print S[i]"\t"i}}' hour=`date +%H` min=`date +%M`  ${PATT} |sort -rn;;
	D)
	read -p "请输入日志文件的绝对路径:" PATTP
	awk -F'"|:' '{S[$2]++}END{for(i in S){print i"\t"S[i]}}' ${PATTP} |sort -n
	esac
done
