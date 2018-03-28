### 禁用IPV6
`echo -e 'net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf && sysctl -p`

### 替换Firewalld为iptables
```
systemctl mask firewalld
systemctl stop firewalld
yum -y install iptables-devel iptables-services iptables
systemctl enable iptables
systemctl start iptables
```
