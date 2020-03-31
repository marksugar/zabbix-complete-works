:: 一键安装zabbix agent 2.2.9升级版4.4.7，理论支持所有windows系统
:: 有BUG请联系www.linuxea.com And https://github.com/marksugar/zabbix-complete-works
:: 1、修改本脚本里的zabbix_server变量
:: 2、执行本脚本，自动安装zabbix agent到C盘
@Echo off
setlocal enabledelayedexpansion

:: 需要修改IP
set zabbix_server=172.25.200.10

:: 替换配置文件中的server ip
set conf_file=%~dp0\zabbix_agent-4.4.7-windows-amd64-openssl\conf\zabbix_agentd.conf
:: 替换配置文件中的server ip
::for /f "delims=" %%b in ('type "%conf_file%"') do (
::  set str=%%b
::  set "str=!str:127.0.0.1=%zabbix_server%!"
::  echo !str!>>"%conf_file%"_tmp.txt
::)

echo Network IP: %zabbix_server%

:: 获取ip并且替换
for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
set windowshost=%NetworkIP%

for /f "delims=" %%a in ('type "%conf_file%"') do (
  set str=%%a
  set "str=!str:127.0.0.1=%zabbix_server%!"
  set "str=!str:Windows host=%windowshost%!"
  echo str IP: %str%

  echo !str! >>"%conf_file%"_tmp.txt
)
move "%conf_file%" "%conf_file%"_bak.txt
move "%conf_file%"_tmp.txt "%conf_file%"


::echo Network IP: %windowshost%


:: 32 bit or 64 bit process detection
IF "%PROCESSOR_ARCHITECTURE%%PROCESSOR_ARCHITEW6432%"=="x86" (
  set _processor_architecture=32bit
  goto x86
) ELSE (
  set _processor_architecture=64bit
  goto x64
)

:x86
mkdir "c:\Program Files\zabbix_agent_447"
xcopy "%~dp0\zabbix_agent-4.4.7-windows-amd64-openssl\bin" "c:\Program Files\zabbix_agent_447" /e /i /y
copy "%conf_file%" "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" /y
mkdir "c:\Program Files\zabbix_agent_447\ps-script"
copy "%~dp0\ps-script" "c:\Program Files\zabbix_agent_447\ps-script"
sc stop  "Zabbix Agent" >nul 2>nul
sc delete  "Zabbix Agent" >nul 2>nul
chcp 65001
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -i
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -s
goto firewall

:x64
::xcopy "%~dp0\zabbix_agent-4.4.7-windows-amd64-openssl\bin" c:\zabbix_x64 /e /i /y
::copy "%conf_file%" c:\zabbix_x64\zabbix_agentd.conf /y
::sc stop  "Zabbix Agent" >nul 2>nul
::sc delete  "Zabbix Agent" >nul 2>nul
::c:\zabbix_x64\zabbix_agentd.exe -c c:\zabbix_x64\zabbix_agentd.conf -i
::c:\zabbix_x64\zabbix_agentd.exe -c c:\zabbix_x64\zabbix_agentd.conf -s
::goto firewall
mkdir "c:\Program Files\zabbix_agent_447"
xcopy "%~dp0\zabbix_agent-4.4.7-windows-amd64-openssl\bin" "c:\Program Files\zabbix_agent_447" /e /i /y
copy "%conf_file%" "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" /y
mkdir "c:\Program Files\zabbix_agent_447\ps-script"
copy "%~dp0\ps-script" "c:\Program Files\zabbix_agent_447\ps-script"
sc stop  "Zabbix Agent" >nul 2>nul
sc delete  "Zabbix Agent" >nul 2>nul
:: 解决乱码问题
chcp 65001
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -i
"c:\Program Files\zabbix_agent_447\zabbix_agentd.exe" -c "c:\Program Files\zabbix_agent_447\zabbix_agentd.conf" -s
goto firewall


:firewall
:: Get windows Version numbers
For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G) 
For /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') Do (set _major=%%G& set _minor=%%H& set _build=%%I) 
Echo Major version: %_major%  Minor Version: %_minor%.%_build%

:: OS detection
IF "%_major%"=="5" (
  IF "%_minor%"=="0" Echo OS details: Windows 2000 [%_processor_architecture%]
  IF "%_minor%"=="1" Echo OS details: Windows XP [%_processor_architecture%]
  IF "%_minor%"=="2" IF "%_processor_architecture%"=="32bit" Echo OS details: Windows 2003 [%_processor_architecture%]
  IF "%_minor%"=="2" IF "%_processor_architecture%"=="64bit" Echo OS details: Windows 2003 or XP 64 bit [%_processor_architecture%]
  :: 开启防火墙10050端口
  netsh advfirewall firewall add rule name="Zabbix Agent" protocol=TCP dir=in localport=10050 action=allow
  netsh firewall delete portopening protocol=tcp port=10050
  netsh firewall add portopening protocol=tcp port=10050 name=zabbix_10050 mode=enable scope=custom addresses=%zabbix_server%
) ELSE IF "%_major%"=="6" (
  IF "%_minor%"=="0" Echo OS details: Windows Vista or Windows 2008 [%_processor_architecture%]
  IF "%_minor%"=="1" Echo OS details: Windows 7 or Windows 2008 R2 [%_processor_architecture%]
  IF "%_minor%"=="2" Echo OS details: Windows 8 or Windows Server 2012 [%_processor_architecture%]
  IF "%_minor%"=="3" Echo OS details: Windows 8.1 or Windows Server 2012 R2 [%_processor_architecture%]
  IF "%_minor%"=="4" Echo OS details: Windows 10 Technical Preview [%_processor_architecture%]
  :: 开启防火墙10050端口
  netsh advfirewall firewall add rule name="Zabbix Agent" protocol=TCP dir=in localport=10050 action=allow
  netsh advfirewall firewall delete rule name="zabbix_10050"
  netsh advfirewall firewall add rule name="zabbix_10050" protocol=TCP dir=in localport=10050 action=allow remoteip=%zabbix_server%
)

pause
rd /s /q "%~dp0\..\zabbix_agent-4.4.7-windows-amd64-openssl"
del /s /q "%~dp0\..\zabbix_agent-4.4.7-windows-amd64-openssl.zip"
del %0


