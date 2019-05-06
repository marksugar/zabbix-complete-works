
echo "* hard nofile 65535" >> /etc/security/limits.conf 
echo "* soft nofile 65535" >> /etc/security/limits.conf 
echo "* soft nproc 65535" >> /etc/security/limits.conf 
echo "* hard nproc 65535" >> /etc/security/limits.conf 
ulimit -u 65535
ulimit -n 65534
ulimit -d unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -t unlimited
ulimit -v unlimited
sed -i "/net.ipv4.tcp_tw_reuse/d" /etc/sysctl.conf
sed -i "/net.ipv4.tcp_keepalive_time/d" /etc/sysctl.conf
sed -i "/net.ipv4.tcp_tw_recycle/d" /etc/sysctl.conf
sed -i "/net.ipv4.tcp_fin_timeout/d" /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout=30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 1800" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 15000 65000 > /proc/sys/net/ipv4/ip_local_port_range
sysctl -p 

