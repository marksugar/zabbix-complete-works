首要前提：
- zabbix默认安装位置/etc/zabbix/
- 安装redis-cli（如果没有安装，脚本会进行安装）
- 你不介意将redis密码存放在计划任务里面，同时你取的值最小单位是分钟

注意： 如果你的redis是有密码的，请修改crontab中的redis-cli 参数，添加-a PASSWORD即可

模板在`https://github.com/LinuxEA-Mark/zabbix3.0.2-complete-works/tree/master/redis/redis-info-templates`路径下，也就是当前的redis-info-templates目录下

curl -Lk https://raw.githubusercontent.com/LinuxEA-Mark/zabbix3.0.2-complete-works/master/redis/redis-info-status.sh|bash
