# Windows Cmd & PowerShell

## Generic cmds


Network load balancing and nic teaming:
```
lbfoadmin.exe
```

Add a dns record to a zone (ie: a cname for www.domain.tld -> www.anotherdomain.tld):

```
dnscmd /recordadd   domain.tld  www CNAME www.anotherdomain.tld
```

Export all dns zones, one txt file each:
```
for /F "tokens=1 skip=3" %a in ('dnscmd /EnumZones') DO dnscmd /ZoneExport %a export_%a.txt
```

List current domain controllers:
```
netdom query /d:ad_domain DC
```

List FSMO roles assignments:
```
netdom query /d:ad_domain FSMO
```

Show AD replication status
```
repadmin /showrepl
```



## Active directory

Import the AD module (install it from Windows Features):
```
Import-module activedirectory
```

Search for any AD user wich contains a string:
```
get-aduser -filter 'Name -like "*zabberoni*"'
```

List all users and respective home and logon script:
```
Get-ADUser -filter * -properties scriptpath, homedrive, homedirectory | ft Name, scriptpath, homedrive, homedirectory
```

List all login scripts assigned to at least one user:
```
Get-ADUser -filter * -properties scriptpath, homedrive, homedirectory | ft  scriptpath | sort.exe | get-unique
----------
script_1.bat
script_2.bat
script_3.bat
```

Check for logons in the last 2 days (see $datecutoff):
```
$datecutoff = (Get-Date).AddDays(-2)
Get-ADComputer -Filter '( LastLogonDate -gt $datecutoff ) -and (OperatingSystem -notlike "*Server*") -and (OperatingSystem -notlike "OnTap")' -Property Name,LastLogonDate
```

Search AD Object by name:

Get-ADObject  -Filter {name -like "SOMEPC*"} | fl
```
DistinguishedName : CN=SOME,OU=Clients,OU=MyOrg.......
Name              : SOMEPC
ObjectClass       : computer
ObjectGUID        : f52acf76-1f39-4fc8-bed2-220de2b1f781
```

List server name in a specific OU:

```
Get-ADcomputer  -SearchBase "OU=Servers,OU=MyOrg......"   -Filter {name -like "*"} | select Name
```

Get group info:
```
Get-ADGroup -Filter 'GroupCategory -eq "Security"' | fl *
```
```
Get-ADGroup -Filter 'Name -eq "GroupName"'
```

Create a group in a specific OU:
```
New-ADGroup -Name "New Group" -GroupScope Global -Path "OU=MyOU,DC=domin,DC=tld"
```

Create groups from a text file, all in a specific OU:
```
Get-Content .\groups.txt | ForEach-Object { New-ADGroup -Name "$_" -GroupScope Global -Path "OOU=MyOU,DC=domin,DC=tld" }
```


## NTP

Set a NTP peer and restart sync:
```
w32tm /config /manualpeerlist:ntp1.inrim.it /syncfromflags:MANUAL
Stop-Service w32time
Start-Service w32time
```


## Printers

Get printers informations:
```
Get-WMIObject -Class Win32_Printer | Select Name,DriverName,PortName| ft -auto

Name                                   DriverName                     PortName      
----                                   ----------                     --------      
10_Ricoh3400_Admin                     RICOH Aficio SP 3400N PCL 6    192.168.3.218
Richo_MP201_First_Floor                RICOH Aficio MP 171 PCL 6      192.168.3.228
04_RicohMP171_Maint                    RICOH Aficio MP 171 PCL 6      192.168.3.221
```

## File operations

Delete files older than 15 days:
```
$root   =  'C:\some\temp'
$limit  =  (Get-Date ). AddDays(-15 )

Get-ChildItem   $root  -Recurse  |  ? {
  -not  $_ .PSIsContainer -and  $_. CreationTime -lt  $limit
} |  Remove-Item
```

Count files in a directory:
```
[System.IO.Directory]::GetFiles("c:\windows\temp", "*").Count
```

## Exchange PowerShell

Show received emails for someone@domain.tld:
```
Get-MessageTrackingLog -Start "03/1/2015 00:00:00" -End "03/23/2015 17:00:00" -Eventid "RECEIVE"  -Sender "someone@domain.tld" | format-table Timestamp,Recipients
```
Show received emails for someone@domain.tld:
```
Get-MessageTrackingLog -Sender "someone@domain.tld" -Start "01/1/2016 00:00:00"
```

Show received emails from a specific IP address:
```
Get-MessageTrackingLog -ResultSize unlimited -Start "03/24/2015 00:00:00" -End "03/25/2015 17:0
0:00" -Eventid "RECEIVE"  | where-object { $_.ClientIP -eq "1.2.3.4" } | format-table Timestamp,Recipients,ClientIP
```

Get SUBMIT events for "someone@domain.tld" with sorting, recipient expansion and CSV output:
```
Get-MessageTrackingLog -Server ExchangeSrv.domain.tld -Start "02/01/2016 00:00:00" -End "03/11/2016 00:00:00" -sender "someone@domain.tld" -resultsize unlimited -EventID SUBMIT| Sort TimeStamp | select timestamp,sender,@{Name=’recipients‘;Expression={[string]::join(“;”, ($_.recipients))}},messagesubject | Export-CSV c:\log\mails.csv
```


Mailbox and transport send/recive size:
```
get-mailbox szabberoni |ft Name, Maxsendsize, maxreceivesize

Name                                    MaxSendSize                             MaxReceiveSize
----                                    -----------                             --------------
Simone Zabberoni                        48.83 MB (51,200,000 bytes)             48.83 MB (51,200,000 bytes)
```
```
get-transportconfig | ft maxsendsize, maxreceivesize

MaxSendSize                                                 MaxReceiveSize
-----------                                                 --------------
15 MB (15,728,640 bytes)                                    15 MB (15,728,640 bytes)
```


Get ForwardingAddress of every mailbox, if set:
```
Get-mailbox | where {$_.ForwardingAddress -ne $Null}| ForEach-Object {
  $ema = Get-Recipient $_.ForwardingAddress
  write-host $_.DisplayName"; " $ema.EmailAddresses
}
```





## MS SQL




Backup local sql VCDB and VUM to file:

```
Import-module  SQLPS
# To set up the user and password run:
# read-host -assecurestring | convertfrom-securestring | out-file C:\securestring.txt

$username   =  "sa"
$password   =  cat  C:\securestring.txt  |  convertto-securestring
$cred  =  new-object  -typename  System.Management.Automation.PSCredential   -argumentlist  $username,  $password

Backup-SqlDatabase  -ServerInstance   vcenter\SQLEXPRESS  -Database  VUMDB  -Credential  $cred  -BackupFile  "D:\backup\VUMDB.bak"  -BackupAction  Database
Backup-SqlDatabase   -ServerInstance  vcenter\SQLEXPRESS  -Database  VCDB  -Credential  $cred  -BackupFile  "D:\backup\VCDB.bak"  -BackupAction  Database
```
