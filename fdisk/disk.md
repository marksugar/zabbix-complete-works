
```
#!/usr/bin/perl
# -------------------------------------------------------------------------------
# Filename:    disk i/o
# Revision:    1.1
# Date:        20160707
# Author:      mark
# Email:       usertzc@163.com
# Website:     http://www.linuxea.com/1392.html
# -------------------------------------------------------------------------------
# Notice
# Apply zabbix version 2.4.x to 3.0.3 
# auto search disk i/o
#################################################################################

sub get_vmname_by_id
 {
 $vmname=`cat /etc/qemu-server/$_[0].conf | grep name | cut -d \: -f 2`;
 $vmname =~ s/^\s+//;
 $vmname =~ s/\s+$//;
return $vmname
 }
$first = 1;
print "{\n";
print "\t\"data\":[\n\n";

for (`cat /proc/diskstats`)
  {
  ($major,$minor,$disk) = m/^\s*([0-9]+)\s+([0-9]+)\s+(\S+)\s.*$/;
  $dmnamefile = "/sys/dev/block/$major:$minor/dm/name";
  $vmid= "";
  $vmname = "";
  $dmname = $disk;
  $diskdev = "/dev/$disk";

 if (-e $dmnamefile) {
    $dmname = `cat $dmnamefile`;
    $dmname =~ s/\n$//; #remove trailing \n
    $diskdev = "/dev/mapper/$dmname";
    
    if ($dmname =~ m/^.*--([0-9]+)--.*$/) {
    $vmid = $1;
    
                 }
     }

print "\t,\n" if not $first;
  $first = 0;

  print "\t{\n";
  print "\t\t\"{#DISK}\":\"$disk\",\n";
  print "\t\t\"{#DMNAME}\":\"$dmname\",\n";
  print "\t\t\"{#VMNAME}\":\"$vmname\",\n";
  print "\t\t\"{#VMID}\":\"$vmid\"\n";
  print "\t}\n";
  }

print "\n\t]\n";
print "}\n";
```




```
UserParameter=discovery.disks.iostats,/etc/zabbix/scripts/disk.pl
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$10}'
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep $1 | head -1 |awk '{print $$4}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$8}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$7}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep $1 | head -1 | awk '{print $$11}'
```