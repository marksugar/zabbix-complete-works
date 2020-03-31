$drives = Get-WmiObject win32_PerfFormattedData_PerfDisk_PhysicalDisk | ?{$_.name -ne "_Total"} | Select Name
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($perfDrives in $drives)
{
    if ($idx -lt $drives.Count)
    {
        $line= "{ `"{#DISKNUMLET}`" : `"" + $perfDrives.Name + "`" },"
        write-host $line
    }
    elseif ($idx -ge $drives.Count)
    {
    $line= "{ `"{#DISKNUMLET}`" : `"" + $perfDrives.Name + "`" }"
    write-host $line
    }
    $idx++;
}
write-host
write-host " ]"
write-host "}"