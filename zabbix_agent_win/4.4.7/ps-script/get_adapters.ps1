$interfaces = Get-WmiObject win32_PerfFormattedData_Tcpip_NetworkInterface | ?{$name -ne "isatap*"} | Select Name
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($perfinterfaces in $interfaces)
{
    if ($idx -lt $interfaces.Count)
    {
        $line= "{ `"{#INTERFACE}`" : `"" + $perfinterfaces.Name + "`" },"
        write-host $line
    }
    elseif ($idx -ge $drives.Count)
    {
    $line= "{ `"{#INTERFACE}`" : `"" + $perfinterfaces.Name + "`" }"
    write-host $line
    }
    $idx++;
}
write-host
write-host " ]"
write-host "}"
