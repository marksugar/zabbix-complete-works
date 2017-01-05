#!/usr/bin/env python
# -*- coding: utf-8 -*-

##author:
##email: 
import os
import sys
import json
import urllib2
import logging

class zabbixtools(object):
    def __init__(self,url,username,password):
        self.url = url.rstrip('/') + '/api_jsonrpc.php'
        self.header = {
            "Content-Type": "application/json-rpc",
            'User-Agent': 'python/pyzabbix',
            'Cache-Control': 'no-cache'
        }
        self.username = username
        self.password = password
        self.authID = self.user_login()

    def user_login(self):
        aa = {
            "jsonrpc": "2.0",
            "method": "user.login",
            "params": {
                "user": self.username,
                "password": self.password
                },
            "id": 0
            }
        data = json.dumps(aa)
        request = urllib2.Request(self.url,data)
        for key in self.header:
            request.add_header(key,self.header[key])
        try:
            result = urllib2.urlopen(request)
        except:
            print "Auth Failed, Please Check Your Url"
            sys.exit()
        else:
            try:
                response = json.loads(result.read())
                result.close()
                #print response
                authID = response['result']
            except KeyError as e:
                print "Auth Failed, Please Check Your Name And Password:",e.code
                sys.exit()
            else:
                return authID

    def list_output(self,gglist,number):
        a = 0
        b = number
        num = len(gglist)/number
        for i in range(num):
            print '\t\t',"\033[1;32;40m%s\033[0m" % json.dumps(gglist[a:b], encoding="UTF-8", ensure_ascii=False)
            a += number
            b += number

    def get_data(self,data,hostip=""):
        request = urllib2.Request(self.url,data)
        for key in self.header:
            request.add_header(key,self.header[key])
        try:
            result = urllib2.urlopen(request)
        except URLError as e:
            if hasattr(e, 'reason'):
                print 'We failed to reach a server.'
                print 'Reason: ', e.reason
            elif hasattr(e, 'code'):
                print 'The server could not fulfill the request.'
                print 'Error code: ', e.code
            return 0
        else:
            response = json.loads(result.read())
            result.close()
            return response



    def host_interface_get(self,hostid):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "hostinterface.get",
            "params": {
                "output":["type","useip","ip","dns","port"],
                "hostids": hostid
                },
            "auth": self.authID,
            "id": 1
            })
        res = self.get_data(data)['result']
        interface = res[0]
        print interface
        if interface['type'] == '1':
            if interface['useip'] == '1':
                print "\t","\033[1;31;40m%s\033[0m" % "Listen_IP:","\033[1;31;40m%s\033[0m" % interface['ip'].ljust(15),'\t',"\033[1;31;40m%s\033[0m" % u"Listen_port:","\033[1;31;40m%s\033[0m" % interface['port']
            else:
                print "\t","\033[1;31;40m%s\033[0m" % "Listen_IP:","\033[1;31;40m%s\033[0m" % interface['dns'].ljust(15),'\t',"\033[1;31;40m%s\033[0m" % u"Listen_port:","\033[1;31;40m%s\033[0m" % interface['port']
        else:
            print "\t","\033[1;31;40m%s\033[0m" % "主机未采用agent模式收集数据"
            return 0


    def host_prototype(self,hostip):
        hostid = self.host_get(hostip)
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "hostprototype.get",
            "params": {
                "output":"extend",
                "selectGroupLinks": "extend",
                "selectGroupPrototypes": "extend",
                "hostids": [hostid]
                },
            "auth": self.authID,
            "id": 1
            })
        res = self.get_data(data)['result']
        print res
        if (res != 0) and (len(res) !=0 ):
            host = res[0]

    def sizeformat(self,bytesize):
        i=0
        while abs(bytesize) >= 1024:
            bytesize = bytesize/float(1024);
            i += 1
            if i == 4:
                break
        units = ["Bytes","KB","MB","GB","TB"]
        newsize = round(bytesize,2)
        res = str(newsize) + units[i]
        return res


    def item_get(self,hostip,keys):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "item.get",
            "params": {
                "output":["itemid","name","key_","lastvalue","status"],
                "search": {
                    "key_": keys
                },
                "sortfield": "name",
                "filter": {"host": [hostip]}
                },
            "auth": self.authID,
            "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            item = res
            #print item
            return item   

    def host_info(self,hostip):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output":["hostid","name","status","host"],
                "selectGroups": ["name"],
                "selectInterfaces": ["type","useip","ip","dns","port"],
                "selectParentTemplates":["name"],
                #"selectItems":"extend",
                "filter": {"host": [hostip]}
                },
            "auth": self.authID,
            "id": 1
            })

        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            for i in res[0]['interfaces']:
                if i['useip'] == '1':
                    print "\t","\033[1;32;40m%s\033[0m" % "Listen_IP:","\033[1;32;40m%s\033[0m" % i['ip'].ljust(15),'\t',"\033[1;32;40m%s\033[0m" % u"Listen_port:","\033[1;32;40m%s\033[0m" % i['port']
                else:
                    print "\t","\033[1;32;40m%s\033[0m" % "Listen_IP:","\033[1;32;40m%s\033[0m" % i['dns'].ljust(15),'\t',"\033[1;32;40m%s\033[0m" % u"Listen_port:","\033[1;32;40m%s\033[0m" % i['port']
            host = res[0]
            #print host
            if host['status'] == '1':
                print "\t","\033[1;31;40m%s\033[0m" % "Host:","\033[1;31;40m%s\033[0m" % host['host'].ljust(15),'\t',"\033[1;31;40m%s\033[0m" % "Host_Name:","\033[1;31;40m%s\033[0m" % host['name'].encode('GBK'),'\t',"\033[1;31;40m%s\033[0m" % u'未在监控状态'
            elif host['status'] == '0':
                print "\t","\033[1;32;40m%s\033[0m" % "Host:","\033[1;32;40m%s\033[0m" % host['host'].ljust(15),'\t',"\033[1;32;40m%s\033[0m" % "Host_Name:","\033[1;32;40m%s\033[0m" % host['name'].encode('GBK'),'\t',"\033[1;32;40m%s\033[0m" % u'在监控状态'
                L = [g['name'] for g in host['groups']]
                print "\t","\033[1;32;40m%s\033[0m" % "所在组: ","\033[1;32;40m%s\033[0m" % json.dumps(L, encoding="UTF-8", ensure_ascii=False)
                T = [t['name'].encode('GBK') for t in host['parentTemplates']]
                print "\t","\033[1;32;40m%s\033[0m" % "已挂模板: ","\033[1;32;40m%s\033[0m" % json.dumps(T,encoding="UTF-8", ensure_ascii=False)
                if "Template OS Linux" in T:
                    a_mem = self.item_get(hostip,"vm.memory.size[available]")
                    t_mem = self.item_get(hostip,"vm.memory.size[total]")
                    if t_mem[0]['status'] == '0':
                        t_now = self.sizeformat(int(t_mem[0]['lastvalue']))
                        a_now = self.sizeformat(int(a_mem[0]['lastvalue']))
                        print "\t","\033[1;32;40m%s\033[0m" % "可用内存: ","\033[1;32;40m%s\033[0m" % a_now, '\t', "\033[1;32;40m%s\033[0m" % "总内存: ","\033[1;32;40m%s\033[0m" % t_now                        
                    a_cpu_load = self.item_get(hostip,"system.cpu.load[percpu,avg1]")
                    b_cpu_load = self.item_get(hostip,"system.cpu.load[percpu,avg5]")
                    c_cpu_load = self.item_get(hostip,"system.cpu.load[percpu,avg15]")
                    if a_cpu_load[0]['status'] == '0':
                        one_cpu = str(round(float(a_cpu_load[0]['lastvalue']),2)) + "%"
                        five_cpu = str(round(float(b_cpu_load[0]['lastvalue']),2)) + "%"
                        ten_cpu = str(round(float(c_cpu_load[0]['lastvalue']),2)) + "%"
                        print "\t","\033[1;32;40m%s\033[0m" % "CPU一分钟负载: ","\033[1;32;40m%s\033[0m" % one_cpu,'\t', "\033[1;32;40m%s\033[0m" % "CPU五分钟负载: ","\033[1;32;40m%s\033[0m" % five_cpu,'\t', "\033[1;32;40m%s\033[0m" % "CPU十五分钟负载: ","\033[1;32;40m%s\033[0m" % ten_cpu
                if "Template_TCP_Status" in T:
                    t_listen = self.item_get(hostip,"tcp.status[LISTEN]")
                    t_established = self.item_get(hostip,"tcp.status[ESTAB]")
                    t_syn_recv = self.item_get(hostip,"tcp.status[SYN-RECV]")
                    if t_listen[0]['status'] == '0':
                        print "\t","\033[1;32;40m%s\033[0m" % "TCP_Listen: ","\033[1;32;40m%s\033[0m" % t_listen[0]['lastvalue'], '\t', "\033[1;32;40m%s\033[0m" % "TCP_Established: ","\033[1;32;40m%s\033[0m" % t_established[0]['lastvalue'],'\t', "\033[1;32;40m%s\033[0m" % "TCP_SYN_recv: ","\033[1;32;40m%s\033[0m" % t_syn_recv[0]['lastvalue']


        else:
            print '\t',"\033[1;31;40m%s\033[0m" % "Get Host Error or cannot find this host,please check !"
            return 0

    def host_get(self,hostip):     ##获取某个主机的名称，id，提供ip
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output":["hostid","name","status","host"],
                "filter": {"host": [hostip]}
                },
            "auth": self.authID,
            "id": 1
            })

        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            host = res[0]
            print '\t',"\033[1;32;40m%s\033[0m" % u"发现主机：%s" % host['host']
            return host['hostid']
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % u"主机在zabbix中不存在！"
            return 0


    def host_create(self,hostip,hostname,hostport,hostgroup):
        #hostid = self.host_get(hostip)
        judge = self.show_host_name()
        groupid = self.group_get(hostgroup)
        templateid = self.template_get("Template OS Linux")
#添加模板		
#templateid1 = self.template_get("Template OS Linux")
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.create",
            "params": {
                "host": hostip,
                "name": hostname,
                "interfaces": [
                    {
                        "type": 1,
                        "main": 1,
                        "useip": 1,
                        "ip": hostip,
                        "dns": "",
                        "port": hostport
                    }
                ],
                "groups": [{"groupid": groupid }],
                "templates": [{"templateid": templateid }],
#添加模板后，需要在这里修改				
#"templates": [{"templateid": templateid },{"templateid": templateid1 }],
                "inventory_mode": 0,
            },
            "auth": self.authID,
            "id": 1
            })
        #print hostid
        #print self.get_data(data)
        if hostip not in judge['host'] and hostname not in judge['name']:
           res = self.get_data(data)['result']
           print '\t',"\033[1;32;40m%s\033[0m" % "IP：%s 添加成功"% hostip
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % "IP: %s or NAME: %s aleady exists in zabbix!"% (hostip,hostname)
            res = 0
        return res

    def show_host(self):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output":["status","host"],
                },
            "auth": self.authID,
            "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            nlist = [i['host'] for i in res if i['status'] == '0']
            unlist = [i['host'] for i in res if i['status'] == '1']
            count = int(len(nlist)) + int(len(unlist))
            if nlist:
                print "\t","\033[1;35;40m%s\033[0m" % u"当前共有 %s 个主机" % count
                self.list_output(nlist,8)
            if unlist: 
                self.list_output(unlist,8)


    def show_host_name(self):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output":["name","host"],
                },
            "auth": self.authID,
            "id": 1
            })
        res = self.get_data(data)['result']
        host_dict = {}
        if (res != 0) and (len(res) !=0 ):
            hlist = [i['host'] for i in res]
            nlist = [i['name'] for i in res]
            host_dict['host'] = hlist
            host_dict['name'] = nlist
            return host_dict
        else:
            return 0


    def select_info(self,key):
        hdata = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output":["name","status","host"],
                "search": {'host': key},
                },
            "auth": self.authID,
            "id": 1
            })
        gdata = json.dumps({
            "jsonrpc": "2.0",
            "method": "hostgroup.get",
            "params": {
                "output":["name"],
                "search": {'name':key},
                },
            "auth": self.authID,
            "id": 1
            })
        tdata = json.dumps({
            "jsonrpc": "2.0",
            "method": "template.get",
            "params": {
                "output":["host"],
                "search": {'host':key},
                },
            "auth": self.authID,
            "id": 1
            })
        idata = json.dumps({
            "jsonrpc": "2.0",
            "method": "item.get",
            "params": {
                "output":["name"],
                "search": {'name':key},
                },
            "auth": self.authID,
            "id": 1
            })
        request = [hdata,gdata,tdata,idata]
        result_list = []
        for i in request:
            res = self.get_data(i)['result']
            if (res != 0) and (len(res) !=0 ):
                for i in res:
                    if i.has_key('hostid'):
                        print '\t',"\033[1;36;40m%s\033[0m" % u"找到主机 %s"% i['host']
                    if i.has_key('groupid'):
                        print '\t',"\033[1;35;40m%s\033[0m" % u"找到组 %s"% i['name']
                    if i.has_key('templateid'):
                        print '\t',"\033[1;37;40m%s\033[0m" % u"找到模板 %s"% i['host']
                    if i.has_key('itemid'):
                        print '\t',"\033[1;38;40m%s\033[0m" % u"找到监控项 %s"% i['name']



    def host_delete(self,hostip):
        hostid = self.host_get(hostip)
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.delete",
            "params": [hostid],
            "auth": self.authID,
            "id": 1
            })
        if hostid == 0:
            result =  0
        else:
            res = self.get_data(data)['result']
            result = res['hostids']
            print '\t',"\033[1;35;40m%s\033[0m" % u"主机 %s 已被移除！" % hostip
        return result


    def group_get(self,groupname):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "hostgroup.get",
                "params": {
                    "output": "extend",
                    "filter": {
                        "name": [groupname]
                    }
                },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):

            print '\t',"\033[1;32;40m%s\033[0m" % u"发现主机组：%s" % res[0]['name']

            return res[0]['groupid']
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % u"Cannot find this group in zabbix!"
            return 0


    def group_create(self,groupname):
        groupid = self.group_get(groupname)
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "hostgroup.create",
                "params": {
                    "name": groupname
                },
                "auth": self.authID,
                "id": 1
            })
        if groupid == 0:
            res = self.get_data(data)['result']
            print '\t',"\033[1;31;40m%s\033[0m" % u"Group %s create success!"% res['groupids']
            return res['groupids']
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % "This group aleady exists in zabbix!"
            return 0

    def group_info(self,groupname):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "hostgroup.get",
                "params": {
                    "output": "extend",
                    "selectHosts": ['host'],
                    "selectTemplates": ['name'],
                    "filter": {"name": [groupname]}
                    },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            temps = res[0]['templates']
            hosts = res[0]['hosts']
            print "\t","\033[1;32;40m%s\033[0m" % "Group:","\033[1;32;40m%s\033[0m" % groupname
            tlist = [t['name'] for t in temps]
            hlist = [h['host'] for h in hosts]
            if tlist:
                print "\t","\033[1;32;40m%s\033[0m" % u"组内模板有: ","\033[1;32;40m%s\033[0m" % json.dumps(tlist, encoding="UTF-8", ensure_ascii=False)
            if hlist:
                print "\t","\033[1;32;40m%s\033[0m" % u"组内主机有: ","\033[1;32;40m%s\033[0m" % json.dumps(hlist, encoding="UTF-8", ensure_ascii=False)
        else:
            print "\t","\033[1;31;40m%s\033[0m" % u"Cannot find this group in zabbix: "
            return 0
        
    def show_group(self):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "hostgroup.get",
                "params": {
                    "output": ['name']
                    },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        nlist = [i['name'] for i in res]
        if nlist:
            print "\t","\033[1;35;40m%s\033[0m" % u"当前共有 %s 个组" % len(nlist)
            self.list_output(nlist,5)

    def group_delete(self,groupname):
        groupid = self.group_get(groupname)
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "hostgroup.delete",
                "params": [groupid],
                "auth": self.authID,
                "id": 1
            })
        if groupid == 0:
            return 0
        else:
            res = self.get_data(data)['result']
            print res['groupids']
            print "This group %s is delete success" % groupname
            return res['groupids']

    def template_get(self,templatename):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "template.get",
                "params": {
                    "output": "extend",
                    "filter": {
                        "host": [templatename]
                    }
                },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):

            print '\t',"\033[1;32;40m%s\033[0m" % u"发现模板: %s"% templatename
            return res[0]['templateid']
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % u"模板：%s 未发现"% templatename
            return 0

    def show_template(self):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "template.get",
                "params": {
                    "output": ['name'],
                },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        if (res != 0) and (len(res) !=0 ):
            nlist = [i['name'] for i in res]
            if nlist:
                print "\t","\033[1;35;40m%s\033[0m" % u"当前共有 %s 个模板" % len(nlist)
                self.list_output(nlist,4)

    def template_delete(self,templatename):
        template_id = self.template_get(templatename) 
        if template_id:
            data = json.dumps(
                {
                    "jsonrpc": "2.0",
                    "method": "template.delete",
                    "params": [template_id],
                    "auth": self.authID,
                    "id": 1
                })
            res = self.get_data(data)['result']
            print "\t","\033[1;35;40m%s\033[0m" % u"模板 %s 已删除！" % templatename
        else:
            print "\t","\033[1;31;40m%s\033[0m" % u"模板 %s 删除失败！" % templatename
            return 0

    def template_info(self,templatename):
        data = json.dumps(
            {
                "jsonrpc": "2.0",
                "method": "template.get",
                "params": {
                    "output": ['name'],
                    "selectHosts": ['host'],
                    "selectItems": ['name','key_','delay','status'],
                    "selectDiscoveries": ['delay','name','key_','status'],
                    "selectTriggers": ['status','description','expression','value'],                    
                    "filter": {
                        "host": [templatename]
                    }
                },
                "auth": self.authID,
                "id": 1
            })
        res = self.get_data(data)['result']
        print '\t',"\033[1;32;40m%s\033[0m" % u"模板：%s" % templatename
        try:
            hosts = res[0]['hosts']
        except KeyError:
            hosts = ''
        hlist = [i['host'] for i in hosts if hosts]
        if hlist:
            print '\t',"\033[1;35;40m%s\033[0m" % u"关联此模板的主机："
            self.list_output(hlist,8)
        try:
            discoveries = res[0]['discoveries']
        except KeyError:
            discoveries = ''
        if discoveries:
            print '\t',"\033[1;35;40m%s\033[0m" % u"自动发现规则："
            for i in discoveries:
                if i['status'] == '0':
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"模板自动发现规则：%s" % i['name'],'\t',"\033[1;32;40m%s\033[0m" % u"规则执行周期：%s 秒" % i['delay'],'\t',"\033[1;32;40m%s\033[0m" % u"已启用"
                else:
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"模板自动发现规则：%s" % i['name'],'\t',"\033[1;32;40m%s\033[0m" % u"规则执行周期：%s 秒" % i['delay'],'\t',"\033[1;32;40m%s\033[0m" % u"未启用"
        try:
            items = res[0]['items']
        except KeyError:
            items = ''
        if items:
            print '\t',"\033[1;35;40m%s\033[0m" % u"模板监控项："
            for i in items:
                if i['status'] == '0':
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"监控项名称：%s" % i['name'],'\t',"\033[1;32;40m%s\033[0m" % u"监控项KEY：%s" % i['key_'],'\t',"\033[1;32;40m%s\033[0m" % u"数据收集周期：%s 秒" % i['delay'],'\t',"\033[1;32;40m%s\033[0m" % u"已启用"
                else:
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"监控项名称：%s" % i['name'],'\t',"\033[1;32;40m%s\033[0m" % u"监控项KEY：%s" % i['key_'],'\t',"\033[1;32;40m%s\033[0m" % u"数据收集周期：%s 秒" % i['delay'],'\t',"\033[1;32;40m%s\033[0m" % u"未启用"
        try:
            triggers = res[0]['triggers']
        except KeyError:
            triggers = ''
        if triggers:
            print '\t',"\033[1;35;40m%s\033[0m" % u"告警触发器："
            for i in triggers:
                if i['status'] == '0':
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"触发器名称：%s" % i['description'],'\t',"\033[1;32;40m%s\033[0m" % u"表达式：%s" % i['expression'],'\t',"\033[1;32;40m%s\033[0m" % u"已启用"
                else:
                    print '\t\t',"\033[1;32;40m%s\033[0m" % u"触发器名称：%s" % i['description'],'\t',"\033[1;32;40m%s\033[0m" % u"表达式：%s" % i['expression'],'\t',"\033[1;32;40m%s\033[0m" % u"未启用"
        

    def host_add_groups(self,hostip,grouplist):
        hostid = self.host_get(hostip)
        if isinstance(grouplist,list):
            grouplist = grouplist 
        else:
            grouplist = grouplist.split()
        if hostid == 0:
            print '\t',"\033[1;31;40m%s\033[0m" % "This host cannot find in zabbix,please check it !"
            sys.exit()
        else:
            for i in grouplist:
                a = self.group_get(i)
                if a != 0:
                    data = json.dumps({
                        "jsonrpc": "2.0",
                        "method": "host.massadd",
                        "params": {
                            "hosts":[{"hostid": hostid}],
                            "groups": [
                                {"groupid": a}
                            ]
                        },
                        "auth": self.authID,
                        "id": 1
                        })
                    res = self.get_data(data)['result']
                    if (res != 0) and (len(res) !=0 ):
                        print '\t',"\033[1;32;40m%s\033[0m" % u"主机 %s 添加组 %s 成功！" % (hostip,i)
                else:
                    print '\t',"\033[1;31;40m%s\033[0m" % u"添加组 %s 失败！" % i
                    return 0

    def host_remove_groups(self,hostip,grouplist):
        hostid = self.host_get(hostip)
        if hostid == 0:
            print '\t',"\033[1;31;40m%s\033[0m" % "未发现主机 %s 撤销失败！" % hostip
            sys.exit()
        if isinstance(grouplist,list):
            grouplist = grouplist 
        else:
            grouplist = grouplist.split()

        for i in grouplist:
            a = self.group_get(i)
            if a != 0:
                data = json.dumps({
                    "jsonrpc": "2.0",
                    "method": "host.massremove",
                    "params": {
                        "hostids": [hostid],
                        "groupids": [a]
                    },
                    "auth": self.authID,
                    "id": 1
                    })
                res = self.get_data(data)['result']
                if (res != 0) and (len(res) !=0 ):
                    print '\t',"\033[1;31;40m%s\033[0m" % u"组 %s 已从主机 %s 上撤销！" % (i,hostip)
            else:
                print '\t',"\033[1;31;40m%s\033[0m" % u"未发现组 %s 撤销失败！" % i
                return 0


    def host_add_templates(self,hostip,templatelist):
        hostid = self.host_get(hostip)
        if isinstance(templatelist,list):
            templatelist = templatelist 
        else:
            templatelist = templatelist.split()
        if hostid == 0:
            print '\t',"\033[1;31;40m%s\033[0m" % "This host cannot find in zabbix,please check it !"
            sys.exit()
        else:
            for i in templatelist:
                a = self.template_get(i)
                if a != 0:
                    data = json.dumps({
                        "jsonrpc": "2.0",
                        "method": "host.massadd",
                        "params": {
                            "hosts":[{"hostid": hostid}],
                            "templates": [
                                {"templateid": a}
                            ]
                        },
                        "auth": self.authID,
                        "id": 1
                        })
                    res = self.get_data(data)['result']
                    if (res != 0) and (len(res) !=0 ):
                        print '\t',"\033[1;32;40m%s\033[0m" % u"模板 %s 已添加！"% i
                else:
                    print '\t',"\033[1;31;40m%s\033[0m" % "模板 %s 添加失败！" % i
                    return 0

    def host_clear_templates(self,hostip,templatelist):
        hostid = self.host_get(hostip)
        if isinstance(templatelist,list):
            templatelist = templatelist 
        else:
            templatelist = templatelist.split()
        if hostid == 0:
            print '\t',"\033[1;31;40m%s\033[0m" % "This host cannot find in zabbix,please check it !"
            sys.exit()
        else:
            for i in templatelist:
                a = self.template_get(i)
                if a != 0:
                    data = json.dumps({
                        "jsonrpc": "2.0",
                        "method": "host.massremove",
                        "params": {
                            "hostids": [hostid],
                            "templateids_clear": [a]
                        },
                        "auth": self.authID,
                        "id": 1
                        })
                    res = self.get_data(data)['result']
                    if (res != 0) and (len(res) !=0 ):
                        print '\t',"\033[1;31;40m%s\033[0m" % "Delete template %s from %s" % (templatelist, hostip)
                else:
                    print '\t',"\033[1;31;40m%s\033[0m" % "Template %s cannot find in zabbix" % templatelist
                    return 0

###--------------------------------------------------------------------分割线-----------------------------------------------------

def check_ip(ip):
    q = ip.split('.')
    return len(q) == 4 and len(filter(lambda x: x >= 0 and x <= 255, map(int, filter(lambda x: x.isdigit(), q)))) == 4
    
def judge_fun():
    while True:
        yes = raw_input("继续？（yes/no）")
        if yes:
            if yes == "yes":
                main()
            elif yes == "no":
                sys.exit()
            else:
                print '\t',"Please input ‘yes’ or ‘no’"

def add_one_host():
    hostip = raw_input("输入需要添加的主机IP：")
    while True:
        if hostip:
            if check_ip(hostip):
                break
            else:
                print "\t","输入的IP格式无效"
                hostip = ''
        else:
           hostip = raw_input("请输入你要添加的主机IP：")

    hostname = raw_input("输入主机NAME（默认：IP）：")
    hostport = raw_input("输入监听端口（默认：10050）：")
    hostgroup = raw_input("添加到组（默认：Linux servers）：")

    if not hostname:
        hostname = hostip
    if not hostport:
        hostport = '10050'
    if not hostgroup:
        hostgroup = "Linux servers"
    zai.host_create(hostip,hostname,hostport,hostgroup)
    judge_fun()

def create_one_group():
    while True:
        groupname = raw_input("请输入你要添加的组名：")
        if groupname:
            break
    zai.group_create(groupname)
    judge_fun()

def host_add_one_template():
    while True:
        hostip = raw_input("请输入主机IP：")
        if hostip:
            if check_ip(hostip):
                break
            else:
                print "\t","输入的IP格式无效"
                hostip = ''
    aa = zai.host_info(hostip)
    if aa is not 0:
        while True:
            templatename = raw_input("请输入模板名,多个模板用逗号隔开：")
            if templatename:
                break
 
        if "," in templatename:
            tlist = templatename.split(',')
        else:
            tlist = templatename
        print "你要添加的模板有：%s"% tlist
        zai.host_add_templates(hostip,tlist)
    judge_fun()    

def host_delete_one_template():
    while True:
        hostip = raw_input("请输入主机IP：")
        if hostip:
            if check_ip(hostip):
                break
            else:
                print "\t","输入的IP格式无效"
                hostip = ''
    aa = zai.host_info(hostip)
    if aa is not 0:
        while True:
            templatename = raw_input("请输入模板名,多个模板用逗号隔开：")
            if templatename:
                break
    
        if "," in templatename:
            tlist = templatename.split(',')
        else:
            tlist = templatename
        print "你要撤销的模板有：%s"% tlist
        zai.host_clear_templates(hostip,tlist)
    judge_fun()

def select_host_information():
    while True:
        hostip = raw_input("请输入你要查询的host：")
        if hostip:
            break
    zai.host_info(hostip)
    judge_fun()

def host_add_one_group():
    while True:
        hostip = raw_input("请输入主机host：")
        if hostip:
            break
    while True:
        groupname = raw_input("请输入组名（多个组用逗号隔开）：")
        if groupname:
            break
    aa = zai.host_info(hostip)
    if aa is not 0:
        if "," in groupname:
            glist = groupname.split(',')
        else:
            glist = groupname
        print "你要添加的组有：%s" % glist
        zai.host_add_groups(hostip,glist)
    judge_fun()

def host_delete_one_group():
    while True:
        hostip = raw_input("请输入主机host：")
        if hostip:
            break
    while True:
        groupname = raw_input("请输入组名（多个组用逗号隔开）：")
        if groupname:
            break
    aa = zai.host_info(hostip)
    if aa is not 0:
        if "," in groupname:
            glist = groupname.split(',')
        else:
            glist = groupname
        print "你要撤销的组有：%s" % glist
        zai.host_remove_groups(hostip,groupname)
    judge_fun()

def del_one_host():
    while True:
        hostip = raw_input("请输入主机host：")
        if hostip:
            break
    aa = zai.host_info(hostip)
    if aa is not 0:
        zai.host_delete(hostip)
    judge_fun()

def del_one_group():
    while True:
        groupname = raw_input("请输入组名：")
        if groupname:
            break
    zai.group_delete(groupname)
    judge_fun()

def del_one_template():
    while True:
        template_name = raw_input("请输入模板名：")
        if temlate_name:
            break
    zai.template_delete(temlate_name)
    judge_fun()

def select_group_information():
    while True:
        group_name = raw_input("请输入组名：")
        if group_name:
            break
    zai.group_info(group_name)
    judge_fun()

def select_template_information():
    while True:
        t_name = raw_input("请输入模板名：")
        if t_name:
            break
    zai.template_info(t_name)
    judge_fun()

def show_all():
    zai.show_host()
    zai.show_group()
    zai.show_template()
    judge_fun()

def show_h():
    zai.show_host()
    judge_fun()

def show_g():
    zai.show_group()
    judge_fun()

def show_t():
    zai.show_template()
    judge_fun()

def select_key():
    while True:
        key = raw_input("请输入查找的关键字（不允许有空格）：")
        if key:
            zai.select_info(key)
            research = raw_input("继续查找？（yes or no）：")
            if research in ['no','yes'] and research == 'no':
                break 
    judge_fun()

def batch_create_host():
    print '\t\t',"\033[1;35;40m%s\033[0m" % "批量添加需要提供一个绝对路径的文件（例：/tmp/hosts.txt）"
    print '\t\t',"\033[1;35;40m%s\033[0m" % "端口和组如果没有提供的话，默认10050，Linux servers"
    print '\t\t',"\033[1;35;40m%s\033[0m" % "默认添加模板“Template OS Linux”"
    print '\t', "\033[1;37;40m%s\033[0m" % "文件格式(可只提供一个IP):"
    print '\t\t',"\033[1;36;40m%s\033[0m" % "192.168.0.1 ,test001 ,10050 ,Linux servers"
    while True:
        src = raw_input("请输入hosts文件路径：")
        if src:
            break
    if os.path.isfile(src):
        file_object = open(src,'rU')
        try:
            for line in file_object:
                ll = line.strip('\n').split(',')
                if not line.strip('\n'):
                    continue
                ip = ll[0].strip()
                if not check_ip(ip):
                    print '\t',"无效IP：%s" % ip
                    continue  
                try:
                    name = ll[1].strip()
                except IndexError:
                    name = ip
                try:
                    port = ll[2].strip()
                except IndexError:
                    port = '10050'
                try:
                    groupname = ll[3].strip()
                except IndexError:
                    groupname = "Linux servers"
                zai.host_create(ip,name,port,groupname)
                
        finally:
            file_object.close()
    else:
        print '\t',"\033[1;31;40m%s\033[0m" % "文件不可用"
    judge_fun()    



def choice_show(choice):
    if choice == '1':
        select_host_information()
    elif choice == '2':
        select_group_information()
    elif choice == '3':
        select_template_information()
    elif choice == '4':
        show_h()
    elif choice == '5':
        show_g()
    elif choice == '6':
        show_t()
    elif choice == '7':
        main()
    else:
        hosts = raw_input("请输入要删除的host：")
        hlist = hosts.split()
        for i in hlist:
            zai.host_delete(i)


def main():
    print "\033[1;33;40m%s\033[0m" % "关键字查找请输入：select\r\n创建主机请输入：create_h\r\n批量创建主机请输入：batch\r\n创建组请输入：create_g\r\n给主机添加模板请输入：add_t\r\n取消主机模板请输入：rm_t\r\n给主机添加组请输入：add_g\r\n取消主机组请输入：rm_g\r\n删除主机请输入：del_h\r\n删除组请输入：del_g\r\n删除模板请输入：del_t\r\n查询信息请输入：show\r\n退出输入：exit"
    while True:
        args = raw_input("请选择你想执行的类型：")
        if args in ['select','show_all','create_h','batch','create_g','add_g','add_t','rm_t','rm_g','del_h','del_g','del_t','show','exit']:
            break
        else:
            print '\t',"\033[1;31;40m%s\033[0m" % "选择项不正确！"
    print '\t',"\033[1;35;40m%s\033[0m" % '你输入的是: %s' % args
    if args == 'create_h':
        add_one_host()
    if args == 'batch':
        batch_create_host()
    if args == 'create_g':
        create_one_group()
    if args == 'add_t':
        host_add_one_template()
    if args == 'rm_t':
        host_delete_one_template()
    if args == 'add_g':
        host_add_one_group()
    if args == 'rm_g':
        host_delete_one_group()
    if args == 'del_h':
        del_one_host()
    if args == 'del_g':
        del_one_group()
    if args == 'del_t':
        del_one_template()
    if args == 'select':
        select_key()
    if args == 'show_all':
        show_all()
    if args == 'show':
        print '\t',"\033[1;33;40m%s\033[0m" % "1.查询主机信息\r\n",'\t',"\033[1;33;40m%s\033[0m" % "2.查询组信息\r\n",'\t',"\033[1;33;40m%s\033[0m" % "3.查询模板信息\r\n",'\t',"\033[1;33;40m%s\033[0m" % "4.显示所有主机\r\n",'\t',"\033[1;33;40m%s\033[0m" % "5.显示所有组\r\n",'\t',"\033[1;33;40m%s\033[0m" % "6.显示所有模板\r\n",'\t',"\033[1;33;40m%s\033[0m" % "7.返回\r\n",'\t',"\033[1;33;40m%s\033[0m" % "8.批量删除主机"
        while True:
            choice = raw_input("请输入数字：")
            if choice in ['1','2','3','4','5','6','7','8']:
                break
            else:
                print '\t',"\033[1;31;40m%s\033[0m" % "选择项不正确！"
        choice_show(choice)
    if args == 'exit':
        sys.exit()

if __name__ == "__main__":
#    while True:
#        zurl = raw_input("请输入zabbix的地址（例：http://127.0.0.1/zabbix）：")
#        user = raw_input("请输入用户名：")
#        password = raw_input("请输入密码：")
#        if zurl and user and password:
#            break
#        else:
#            print '\t',"\033[1;32;40m%s\033[0m" % "输入的信息不完整"
#    zai = zabbixtools(zurl,user,password)
###zabbix地址和用户名密码
	zai = zabbixtools("http://zabbix.ds.com","admin","zabbix")
    if zai: main()
