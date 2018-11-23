我仍然使用了及其简单的方式来监控iptables变化，但是你需要注意，这个变化的报警的时间非常短

```
UserParameter=iptables_lins,/usr/bin/sudo iptables -S |md5sum|awk '{print $1}'
UserParameter=iptables_file,/usr/bin/sudo /usr/bin/cksum /etc/sysconfig/iptables|awk '{print $1}'
```

另外，需要sudo权限
```
zabbix ALL=(root)NOPASSWD:/usr/sbin/iptables,/usr/bin/cksum /etc/sysconfig/iptables
```