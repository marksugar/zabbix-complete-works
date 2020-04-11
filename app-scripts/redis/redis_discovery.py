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