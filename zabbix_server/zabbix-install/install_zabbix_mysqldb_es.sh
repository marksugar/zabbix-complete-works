#!/bin/bash
#########################################################################
# File Name: install_zabbix_mysql_es.sh
# Author: www.linuxea.com
# Version:
# Created Time: 2019年05月04日 星期六 17时46分39秒
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
		wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-mysql/docker-compose.yaml
		docker-compose pull
	}
	elasticsearch_install(){
		echo "vm.max_map_count=655355" >> /etc/sysctl.conf && sysctl -p
		mkdir /data/zabbix/elasticsearch/{data,logs} -p
		chown -R 1000.1000 /data/zabbix/elasticsearch/
		curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/conf/elasticsearch.yml -o /data/zabbix/elasticsearch/elasticsearch.yml
		docker-compose  up -d elasticsearch
		countdown 30 "In order to Elasticsearch startup"
		if [ `ss -lt|grep 9200|wc -l` = 1 ];then 
			echo -e "start configure elasticsearch index\n"
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch |bash
			countdown 3 "In order to Elasticsearch index pipeline"
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-pipeline | bash
			countdown 3 "In order to Elasticsearch index template"
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-template | bash
			countdown 3 "In order to Elasticsearch index template 2"
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch_template | bash
			sleep 1
			curl http://127.0.0.1:9200/_cat/indices?v
		else
			echo "elasticsearch is not runing"
		fi
	}
zabbix_base_init
elasticsearch_install
docker-compose -f docker-compose.yaml up -d
