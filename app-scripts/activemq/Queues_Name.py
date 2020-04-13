#!/usr/bin/env python
#-*- encoding: utf-8 -*-
#########################################################################
# File Name: Queues_Name.py
# Author: www.linuxea.com
# https://github.com/marksugar/zabbix-complete-works
#########################################################################

import os
import json
t=os.popen(""" curl -s -uadmin:admin http://127.0.0.1:8161/admin/queues.jsp | awk -F'<' '/<\/a><\/td>/{print $1}' """)
QUEUES_NAME = []
for dname in  t.readlines():
		r = os.path.basename(dname.strip())
		QUEUES_NAME  += [{'{#QUEUES_NAME}':r}]
print json.dumps({'data':QUEUES_NAME},sort_keys=True,indent=4,separators=(',',':'))