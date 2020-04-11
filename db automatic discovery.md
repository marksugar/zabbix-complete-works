以redis为例，我已经对redis做了简单的监控。但是redis的db如果有多个，就需要自动的进行发现下

首先，需要明白要提取的主要键是什么，在这里redis主要拿的就是db几。那么，编写一个脚本发现有多少个db。如下：

```
#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#########################################################################
# File Name: dbname.py
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# https://github.com/marksugar/zabbix-complete-works
#########################################################################

import os
import json
t=os.popen(""" /usr/bin/redis-cli -a  mima info Keyspace|grep db|awk -F: '{print $1}' """)
redis_db_name = []
for dname in  t.readlines():
		r = os.path.basename(dname.strip())
		redis_db_name  += [{'{#REDIS_DB}':r}]
print json.dumps({'data':redis_db_name},sort_keys=True,indent=4,separators=(',',':'))
```

当运行之后的json格式如下

```
[root@DT_Node-172_30_199_2 /etc/zabbix/scripts]# python redis_discovery.py
{
    "data":[
        {
            "{#REDIS_DB}":"db1"
        }
    ]
}
```

这里只显示了一个db1。

- 这里较为关键的是key:value映射关系
-   `"{#REDIS_DB}":"db1"`,`{#REDIS_DB}`将会在模板中被引用

## 导入到zabbix配置

上面的发现脚本放在/etc/zabbix/scripts下。并且/etc/zabbix/zabbix_agentd.d/下创建redis.conf 。如下：

```
UserParameter=redis_db.discovery,/etc/zabbix/scripts/redis_discovery.py
```

redis_db.discovery是作为key。在模板中引用

## create discovery rule

而后在模板中的 Discovery中，如下图

![disl1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/redis/redisdb1.png)

而后点击create  discovery rule。在key中填写`redis_db.discovery`引入。如下
![disl1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/redis/redisdb2.png)

### 创建item

name : `redis:{#REDIS_DB}: avg_ttl`

key : `redis.discovery.db.avg_ttl[{#REDIS_DB}]`

如下图：

![disl1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/redis/redisdb3.png)

同时，我们在zabbix_agent的redis.conf中在添加三个item

```
#avg_ttl
UserParameter=redis.discovery.db.avg_ttl[*],redis-cli -a mima info Keyspace| awk -F= '/$1/{print $$4}'
```

什么意思呢？

上面的items中`redis.discovery.db.avg_ttl[{#REDIS_DB}]`，`[{#REDIS_DB}]`就是自动发现中的db1，而在redis.conf中`UserParameter=redis.discovery.db.avg_ttl[*]`变成了\*，\*此刻就是db1

顺序：

redis_db.discovery 发现到value，也就是db1 传递到zabbix-server，zabbix接收到后在将value传到`redis.discovery.db.avg_ttl[*]`完成获取

其他的在如法炮制

```
UserParameter=redis_db.discovery,/etc/zabbix/scripts/redis_discovery.py
#keys
UserParameter=redis.discovery.db.keys[*],redis-cli -a mima info Keyspace| awk -F= '/$1/{print $$2}'|awk -F, '{print $$1}'
#expires
UserParameter=redis.discovery.db.expires[*],redis-cli -a mima info Keyspace| awk -F= '/$1/{print $$3}'|awk -F, '{print $$1}'
#avg_ttl
UserParameter=redis.discovery.db.avg_ttl[*],redis-cli -a mima info Keyspace| awk -F= '/$1/{print $$4}'
```

