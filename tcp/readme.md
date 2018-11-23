我用了一种简单的方式来进行监控，在我看来越简单越好用。

需要提醒的是，我存放在计划任务中执行的统计信息，存放在/tmp/下，而后使用脚本去抓取。计划任务默认最小粒度1分钟一次

```
*/1 * * * * /usr/sbin/ss  -tan|awk 'NR>1{++S[$1]}END{for (a in S) print a,S[a]}' > /tmp/tcp-status.txt
*/1 * * * * /usr/sbin/ss -o state established '( dport = :http or sport = :http )' |grep -v Netid > /tmp/httpNUB.txt
```

```
UserParameter=tcp.status[*],awk '{if ($$1~/^$1/)print $$2}' /tmp/tcp-status.txt
UserParameter=tcp.httpd_established,awk 'NR>1' /tmp/httpNUB.txt|wc -l
```

