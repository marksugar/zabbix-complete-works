#!/bin/bash
dd if=/dev/zero of=/swap_file bs=2G count=1
chmod 600 /swap_file
/sbin/mkswap -f /swap_file 
/sbin/swapon /swap_file
echo "/swap_file swap swap defaults 0 0" >> /etc/fstab
free -m
cat /etc/fstab
