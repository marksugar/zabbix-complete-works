ETHNAME=$(awk -F'=' '/DEVICE/{print $2}' /etc/sysconfig/network-scripts/ifcfg-*|grep -v lo)
#ip addr show "$ETHNAME"|awk 'NR==3{print $2}'|sed -r 's/\/[0-9]{1,}//'
ip addr show "$ETHNAME"|awk 'NR==3{print $2}'|cut -d/ -f1
