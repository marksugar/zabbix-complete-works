#!/bin/bash
#########################################################################
# File Name: install_zabbix_timescaledb.sh
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# Version:
# Created Time: 2019年05月04日 星期六 17时37分47秒
#########################################################################
	countdown() {
		secs=$1
		shift
		msg=$@
		while [ $secs -gt 0 ]
		do
	    	printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
			sleep 1
		done
		echo
	}
	zabbix_base_init(){
		mkdir /data/zabbix -p && cd /data/zabbix
		curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/graphfont.TTF -o /data/zabbix/graphfont.ttf
		wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-timescaledb/docker-compose-timescaledb.yaml -O /data/zabbix/docker-compose.yaml
		docker-compose pull
	}
	timescaledb_install(){
		mkdir /data/zabbix/postgresql/data -p
		cd /data/zabbix
		chown -R 70 /data/zabbix/postgresql/data
		docker-compose  up -d timescaledb
		countdown 30 "In order to timescaledb startup"
		sed -i 's/max_connections.*/max_connections = 120/g' /data/zabbix/postgresql/data/postgresql.conf
		docker rm -f  timescaledb
		docker-compose  up -d timescaledb
	}
zabbix_base_init
timescaledb_install
docker-compose -f docker-compose.yaml up -d
