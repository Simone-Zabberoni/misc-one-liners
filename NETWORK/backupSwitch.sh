#!/bin/bash
# Lazy todo: parametric admin!

date=$(date '+%Y%m%d%H%M')
backupDir=$date-backup
mkdir  $backupDir 2> /dev/null

name=$(echo $1| cut -d " " -f1)
ip=$(echo $1| cut -d " " -f2)


echo Backupping $name - $ip...

hlogin -u admin -c 'show run' $ip > $backupDir/$date-$name.conf

echo "$name - $ip: End"
