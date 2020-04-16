在4.4版本中每个模板都分开，在修改的时候要进入到每个模板中进行修改。并且在4.4版本中，引用了很多内置变量来做的默认值，这是可以修改的。

比如：`{Template Module Zabbix agent:zabbix[host,agent,available].max({$AGENT.TIMEOUT})}=0`中的`$AGENT.TIMEOUT`这仅仅是内置的变量，是可以手动修改的。

案例版本4.4.6

windows参考：https://www.zabbix.com/cn/integrations/windows

linux参考：https://www.zabbix.com/cn/integrations/linux

## CPU

除了内置的CPU信息之外，我们 仍然需要添加一个CPU的triggers。

你需要添加一个items。key: ` system.cpu.num`来辅助计算负载

name: `{HOST.IP} {HOST.NAME} CPU load 15分钟持续负载超过核心数`

```
({Template Module Linux CPU by Zabbix agent:system.cpu.num.last()}*1)<{Template Module Linux CPU by Zabbix agent:system.cpu.load[all,avg15].last()}
```

## 内存调整

对于不必要的swap，你可能需要Disable。否则会出现大量的警告。如果你在案例中有大量swap使用，那么你需要自己决定如何做。

- 添加新的内存trigger

name: `{HOST.NAME} 可以使用内存空间不足100M已持续三分钟`

```
{Template Module Linux memory by Zabbix agent:vm.memory.size[available].last(3m)}<100M
```

如果在三分钟内内存小于100M，就发送灾难报警。

而自带的`Lack of available memory ( < {$MEMORY.AVAILABLE.MIN} of {ITEM.VALUE2})` 不需要关闭。

对于虚拟内存要求不高的，可以关闭swap

- windows

key:  `vm.memory.size[available]`。[参考](https://www.zabbix.com/documentation/current/manual/appendix/items/vm.memory.size_params)

name :  `{HOST.NAME} 可以使用内存空间不足100M已持续三分钟`	

```
{Template Module Windows memory by Zabbix agent:vm.memory.size[available].last(3m)}<100M
```

## 网卡流量

同样需要添加一个网卡流量的监控的trigger

nane: `{HOST.NAME} 网卡{#IFNAME}持续5分钟大于100M`

```
{Template Module Linux network interfaces by Zabbix agent:net.if.in["{#IFNAME}"].min(5m)}>100M
```

## 磁盘

实际上磁盘的trigger已经很够了，那么他自带的是"磁盘严重不足并将在24小时内写满，或者不足5G"，只要满足其中一个条件就发生警告。但是在实际中，并不是我需要的。比如，我需要在磁盘之剩下百分10的时候就立马告警。实际上自带的已经够用，但是我仍然要加一个

name:  `磁盘空间已经使用超过90% {#FSNAME}`

```
{Template Module Linux filesystems by Zabbix agent:vfs.fs.size[{#FSNAME},pused].last()}>90
```

- windowns

name: `磁盘空间已经使用超过90% {#FSNAME}`

```
{Template OS Windows by Zabbix agent:vfs.fs.size[{#FSNAME},pused].last()}>90
```

对于新的磁盘，我建议再做一个关于磁盘的graph，如果你是timescaledb那就更有必要了