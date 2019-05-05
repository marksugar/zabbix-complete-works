### mysql
```
mkdir /data/zabbix -p && cd /data/zabbix
mkdir /data/elasticsearch/{data,logs} -p
chown -R 1000.1000 /data/elasticsearch/
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/graphfont.TTF -o /data/zabbix/graphfont.ttf
wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-mysql/docker-compose.yaml
docker-compose -f docker-compose.yaml up -d
```

### timescaledb
```
mkdir /data/zabbix -p && cd /data/zabbix
mkdir /data/zabbix/elasticsearch/{data,logs} -p
chown -R 1000.1000 /data/zabbix/elasticsearch/
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/graphfont.TTF -o /data/zabbix/graphfont.ttf
wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-timescaledb/docker-compose.yaml -O /data/zabbix/docker-compose.yml
docker-compose -f docker-compose.yaml up -d
```
***提示***
你或许需要修改连接数
```
sed -i 's/max_connections.*/max_connections = 120/g' /data/zabbix/postgresql/data/postgresql.conf
docker rm -f  timescaledb
docker-compose -f /data/zabbix/docker-compose.yaml up -d
```
或者下载配置文件挂载
```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-timescaledb/postgresql.conf -o /data/zabbix/postgresql.conf
```
这里会执行sql,参考[zabbix文档](https://www.zabbix.com/documentation/4.2/manual/appendix/install/db_scripts)
```
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
SELECT create_hypertable('history', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_uint', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_log', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_text', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_str', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('trends', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('trends_uint', 'clock', chunk_time_interval => 86400, migrate_data => true);
UPDATE config SET db_extension='timescaledb',hk_history_global=1,hk_trends_global=1;
```

###  *elasticsearch*

**你需要注意权限问题，如本示例docker-compose中需要授权: **
```
mkdir /data/elasticsearch/{data,logs} -p
chown -R 1000.1000 /data/elasticsearch/
```
我整理了[索引文件](https://github.com/marksugar/zabbix-complete-works/tree/master/elasticsearch/6.1.4)，**执行创建索引**即可,你也可以参考[官网文档]( https://www.zabbix.com/documentation/devel/manual/appendix/install/elastic_search_setup)

你也可以执行这里的命令快速使用
```
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch |bash
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-pipeline | bash
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-template | bash
curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch_template | bash
```

正常情况下你将看到如下信息：
```
$ curl http://127.0.0.1:9200/_cat/indices?v
health status index                       uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   str                         MQWM2bNNRzOvBywM7ne-lw   5   1          0            0      1.1kb          1.1kb
yellow open   .monitoring-es-6-2019.04.20 tIfs0MkNQUCI4YuEHRmQ6g   1   1       1926          208    901.6kb        901.6kb
yellow open   dbl                         Y0992hqaR8KTin9iXKsljQ   5   1          0            0      1.1kb          1.1kb
yellow open   text                        s2XMyJtdQQ27b9rS3nWVfg   5   1          0            0      1.1kb          1.1kb
yellow open   log                         MAysNczpSKGZbjfjJXBvTg   5   1          0            0      1.1kb          1.1kb
yellow open   uint                        JA_8kyXlSLqawyHzo28Ggw   5   1          0            0      1.1kb          1.1kb
```

如果手动导入sql参考如下页面：

https://www.zabbix.com/documentation/4.2/manual/appendix/install/db_scripts
https://www.zabbix.com/documentation/4.2/manual/appendix/install/elastic_search_setup