## zabbix Discovery 

本教程基于zabbix4.2进行截图记录，如果有不同的地方，请自行补充

本教程示例信息如下：

- ip段：172.25.12.1-254

- 主机组：dt-api

## 创建Discovery rules

Configuration -> Discovery -> Create discovery rule

![d1](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d1.png)
 现在我要发现的主机ip网段是172.25.12.1到254网段内的所有ip，如下

![d2](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d2.png)

其中 Checks Zabbix agent "agent.hostname"也是获取ip地址的意思。创建完成后就会有一个创建好的Discovery rules，如下图

![d3](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d3.png)

## Discovery list

创建完成后，查看是否已经被自动发现到机器的列表，在Monitoring -> Discovery -> Discovery rule的下拉菜单中选择我们此前创建的自动发现的Discovery rules名称"pt-api-172.25.12"。如果不出意外，你将看到发现的列表

![d4](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d4.png)

## 添加 组/模板

这些机器被发现后，我们需要一个动作将它添加到zabix中并且加到组内。在Monitoring -> Actions -> Event source (Discovery)  -> Create action，如下图

![d5](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d5.png)

- Action

点击Create action，在Action的页面中命名一个名称，如：pt-api，并且需要添加几个条件，在New condition栏中，选择每个条件，并且填写必要的条件，如下

![d6](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d6.png)

在本示例中，添加了4条

- server type  equals  Zabbix agent ：  服务类型等于Zabbix agent
- Host IP equals 172.25.12.1-254  ： 主机ip地址范围等于172.25.12.1-254
- Discovery status equals *Up*  ： 发现状态等于up
- Uptime/Downtime is greater than or equals *600*  ： 正常运行时间/停机时间大于或等于600

添加完成后如下图

![d7](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d7.png)

- Operations

在Operations页面，我们只要关注Operations项，我们仍然和上面一样的方式添加操作的动作，我们至少要完成，添加到主机组里并且给主机添加模板。选择如下几项

![d8](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d8.png)

- Add to host group需要提前给这段将要发现的主机创建一个组

- link to template链接模板

- enable host 

最终显示大概这样（关注红色框内）

![d9](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d9.png)

而后add或者update即可。

而后等待一段时间，主机将会被成功发现，并添加主机链接模板

![d10](https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/img/d10.png)