$processors = Get-WmiObject win32_PerfFormattedData_PerfOS_Processor | ?{$_.name -ne "_Total"} | Select Name
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($perfProcessors in $processors)
{
    if ($idx -lt $processors.Count)
    {
        $line= "{ `"{#PROCESSOR}`" : `"" + $perfProcessors.Name + "`" },"
        write-host $line
    }
    elseif ($idx -ge $drives.Count)
    {
    $line= "{ `"{#PROCESSOR}`" : `"" + $perfProcessors.Name + "`" }"
    write-host $line
    }
    $idx++;
}
write-host
write-host " ]"
write-host "}"