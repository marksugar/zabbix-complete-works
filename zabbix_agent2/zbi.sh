#!/bin/bash
#########################################################################
# File Name: zbi.sh
# Author: 
# Email: 
# Version: v1
# Created Time: Fri 27 Dec 2024
#########################################################################
ZABBIX_SERVER=${2:?请传入ZABBIX_SERVER地址}
TARGET=${1:-internet}

check_os() {
    if [ ! -f /etc/redhat-release ]; then
        echo "Error: /etc/redhat-release not found. Exiting..."
        return 1
    fi
    if ! grep -q "CentOS Linux release 7" /etc/redhat-release; then
        echo "Error: Not CentOS Linux release 7. Exiting..."
        return 1
    fi
    curl -Lks https://git.dwhd.org/lookback/CentOS_INIT/-/raw/master/Kickstart/repo-mirrorslist/CentOS-7-x86_64-Base.repo > /etc/yum.repos.d/CentOS-Base.repo
    echo "CentOS-Base.repo updated successfully."
}
check_internet() {
    ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1
    return $?
}
check_zabbix_agent_installed() {
    if command -v zabbix_agentd >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
# 安装 zabbix-agent
# https://www.zabbix.com/download?zabbix=6.4&os_distribution=ubuntu&os_version=24.04&components=agent&db=&ws=

install_zabbix_agent() {
    echo "正在安装 zabbix-agent..."
    if command -v yum >/dev/null 2>&1; then
        yum install http://buildlogs-seed.centos.org/c7.1708.00/pcre2/20170802214013/10.23-2.el7.x86_64/pcre2-10.23-2.el7.x86_64.rpm -y
        rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/7/x86_64/zabbix-release-latest-6.0.el7.noarch.rpm
        yum install zabbix-agent -y
        systemctl restart zabbix-agent
        systemctl enable zabbix-agent
    else
        echo "无法识别的软件包管理工具。安装失败！"
        exit 1
    fi
}

# 更新 zabbix-agent 配置
#egrep -v "^#|^$" /etc/zabbix/zabbix_agent2.conf-bak > /etc/zabbix/zabbix_agent2.conf
update_zabbix_config() {
    [ ! -d /etc/zabbix ] || mv /etc/zabbix /etc/zabbix-bak
    curl -Lks4 https://raw.githubusercontent.com/marksugar/zabbix-complete-works/refs/heads/master/zabbix_agent2/zabbix.tar.gz |tar xz -C /etc/
    config_file="/etc/zabbix/zabbix_agentd.conf"
    cat > /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
Hostname=Zabbix server
Include=/etc/zabbix/zabbix_agentd.d/
EOF
    echo "正在更新 Zabbix-Agent 配置文件..."
    # 如果参数是 "local"，获取当前网卡的IP地址
    if [ "$TARGET" = "local" ]; then
        # 获取本地网卡的 IP 地址（排除回环地址 127.0.0.1）
        local_ip=$(ip addr show | awk '/inet / && $2 !~ /127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n 1)
        echo "设置 Hostname 为: $local_ip"
        echo "设置 Server 为: $ZABBIX_SERVER"
        sudo sed -i "s/^Hostname=.*/Hostname=$local_ip/" "$config_file"
        sudo sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" "$config_file"
        sudo sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" "$config_file"

    # 如果参数是 "internet"，获取公网IP地址
    elif [ "$TARGET" = "internet" ]; then
        # 使用curl获取公网IP地址
        public_ip=$(curl -s ifconfig.me)
        echo "公网IP地址: $public_ip"
        echo "设置 Hostname 为: $public_ip"
        echo "设置 Server 为: $ZABBIX_SERVER"
        sudo sed -i "s/^Hostname=.*/Hostname=$public_ip/" "$config_file"
        sudo sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" "$config_file"
        sudo sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" "$config_file"
    # 如果参数无效，提示用户
    else
        echo "无效参数！请使用 'local' 或 'internet'"
    fi    
    echo "配置更新完成！"    
}

start_zabbix() {
    systemctl enable zabbix-agent >/dev/null 2>&1
    systemctl status zabbix-agent --no-pager
    systemctl restart zabbix-agent.service
    echo "查看 zabbix-agent 日志..."
    tail -n 10 /var/log/zabbix/zabbix_agentd.log
}
# 主逻辑
main() {
    #command -v zabbix_agent || (systemctl disable zabbix-agent;systemctl stop zabbix-agent)
    if check_internet; then
        echo "网络连接正常，检查 zabbix-agent..."
        if check_zabbix_agent_installed; then
            echo "zabbix-agent 已安装。开始配置"            
            update_zabbix_config
            start_zabbix
        else
            echo "zabbix-agent 未安装，开始安装..."
            check_os
            install_zabbix_agent
            update_zabbix_config
            start_zabbix
        fi
    else
        echo "无网络连接。"
        if check_zabbix_agent_installed; then
            echo "zabbix-agent 已安装。开始配置"
            update_zabbix_config
            start_zabbix
        else
            echo "zabbix-agent 未安装且无法联网，脚本退出。"
            exit 1
        fi
    fi
}
main "$@"
# sh script.sh internet ZABBIX_SERVER