#!/bin/bash
# centos7.2
systemctl mask firewalld
systemctl stop firewalld
yum install epel* -y
yum -y install iptables-devel iptables-services iptables
systemctl enable iptables
systemctl start iptables
