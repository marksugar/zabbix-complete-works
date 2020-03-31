sc stop  "Zabbix Agent" >nul 2>nul
sc delete  "Zabbix Agent" >nul 2>nul
chcp 65001
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -i
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -s