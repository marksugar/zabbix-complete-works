#!/bin/bash
#1,install zabbix-agent
#2,modify sshd port 22992,install iptables
#3,install docker
zabip=
disable_ipv6() {
        if [[ -n "$(ip a|awk '/inet6/')" ]]; then
                if [[ "7" == "$(awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/centos-release)" ]]; then
                        if ! awk '/GRUB_CMDLINE_LINUX/' /etc/default/grub|grep 'ipv6.disable=1'; then
                                sed -ri 's/^(GRUB_CMDLINE_LINUX.*)(")$/\1 ipv6.disable=1\2/' /etc/default/grub
                        fi
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                fi
        fi
}

ssh_iptables() {
        sed -ri 's/^#?(Port)\s{1,}.*/\1 22992/' /etc/ssh/sshd_config
        curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/downiptables.sh|bash
        curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/iptables > /etc/sysconfig/iptables
        systemctl restart sshd.service
        service iptables restart
}

install_zabbix() {
        curl -Lk4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/zabbix-install.sh|bash -x -s net $zabip
}

install_docker() {
        curl -Lks4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/zabbix-install/docker-install.sh|bash -s aufs
}

disable_ipv6
ssh_iptables
install_zabbix
iptables -nvxL --lin
ss -tnl
