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



## Remote management

Connect to remote powershell from a machine in the same domain:

```
c:\Users\someone> Enter-PSSession -computername someComputer

[someComputer] c:\Users\someone>
```

From a non-domain machine you need to setup trusted hosts (https://social.technet.microsoft.com/Forums/windowsserver/en-US/f4b79641-92cb-4aa7-8cd3-921853b9e0d5/using-enterpssession-on-lan-without-domain?forum=winserverpowershell) or use PsExec:

```
C:\Users\simone>psexec \\someServer -u myDom\s.zabberoni powershell

PsExec v2.2 - Execute processes remotely
Copyright (C) 2001-2016 Mark Russinovich
Sysinternals - www.sysinternals.com

Password: ---------

Windows PowerShell
Copyright (C) 2016 Microsoft Corporation. All rights reserved.

PS C:\> hostname
someServer
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

Get locked accounts and the bad logon count, excluding disabled and administrative accounts:

```
Search-ADAccount -Lockedout |where {$_.enabled -and $_.Name -NotLike "Admin*"} | ForEach-Object { get-aduser $_.samaccountname -property BadLogonCount | select Name, SamAccountName,BadLogonCount }

Name                                    SamAccountName                                                    BadLogonCount
----                                    --------------                                                    -------------
John Smith                              JSMITH                                                                        2
Some User                               SOMEUSE2                                                                      1
```


Search AD Object by name:


```
Get-ADObject  -Filter {name -like "SOMEPC*"} | fl
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
Get-Content .\groups.txt | ForEach-Object { New-ADGroup -Name "$_" -GroupScope Global -Path "OU=MyOU,DC=domin,DC=tld" }
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

Reset file permission recursively, based on a master file access-list:
```
$NewAcl = Get-Acl File0.txt
Get-ChildItem c:\temp -Recurse -Include *.txt -Force | Set-Acl -AclObject $NewAcl
```

Count files in a directory:
```
[System.IO.Directory]::GetFiles("c:\windows\temp", "*").Count
```

Count files in a directory and subdirs (one liner for zabbix):
```
$queueFiles = get-childitem '{$QUEUE_DIR}' -File -Recurse; if ($queueFiles) { Write-host $queueFiles.Length } else { write-host 0 }
```

Count files in a directory and subdirs with CMD only:
```
@echo off
for /f %%A in ('dir "%1"  /a-d-s-h /b /s ^| find /v /c ""') do set cnt=%%A
echo %cnt%
```

Usage:
```
c:\somwhere>fileCount.bat
3

c:\somwhere>fileCount.bat c:\somwhere-else
134
```

Search strings inside all files of a path:
```
ls -r c:\somewhere -file | % {Select-String -path $_ -pattern 'string_pattern'}
```

## Services

With WMI:

```
Get-WmiObject Win32_Service -Filter "Name LIKE 'VmWare%'" | ft

ExitCode Name               ProcessId StartMode State   Status
-------- ----               --------- --------- -----   ------
       0 VMware NAT Service      4484 Auto      Running OK
       0 VMwareHostd             6256 Auto      Running OK
```

With get-service:
```
Get-Service -Name "VMware*"

Status   Name               DisplayName
------   ----               -----------
Running  VMware NAT Service VMware NAT Service
Running  VMwareHostd        VMware Workstation Server
```

## JSON & Web Requests

Sample - Services to zabbix LLD discovery:

```
$result = @{}
$result.data = @()

Get-WmiObject Win32_Service -Filter "Name LIKE 'VmWare%'" | ForEach-Object { 
    $result.data += @{
        "{#PROCESS_ID}" = $_.ProcessId;
        "{#SERVICE_NAME}" = $_.Name;
        "{#SERVICE_STATUS}" =  $_.Status;
    }
} 

$result | ConvertTo-Json
```

Result:
```
{
    "data":  [
                 {
                     "{#SERVICE_NAME}":  "VMware NAT Service",
                     "{#PROCESS_ID}":  4484,
                     "{#SERVICE_STATUS}":  "OK"
                 },
                 {
                     "{#SERVICE_NAME}":  "VMwareHostd",
                     "{#PROCESS_ID}":  6256,
                     "{#SERVICE_STATUS}":  "OK"
                 }
             ]
}
```

InvokeWebRequest or wget (alias):

```
alias wget

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           wget -> Invoke-WebRequest
```

Basic invocation:

```
 wget https://jsonplaceholder.typicode.com/users | ConvertFrom-Json

id       : 1
name     : Leanne Graham
username : Bret
email    : Sincere@april.biz
address  : @{street=Kulas Light; suite=Apt. 556; city=Gwenborough; zipcode=92998-3874; geo=}
phone    : 1-770-736-8031 x56442
website  : hildegard.org
company  : @{name=Romaguera-Crona; catchPhrase=Multi-layered client-server neural-net; bs=harness real-time e-markets}

id       : 2
name     : Ervin Howell
username : Antonette
email    : Shanna@melissa.tv
address  : @{street=Victor Plains; suite=Suite 879; city=Wisokyburgh; zipcode=90566-7771; geo=}
phone    : 010-692-6593 x09125
website  : anastasia.net
company  : @{name=Deckow-Crist; catchPhrase=Proactive didactic contingency; bs=synergize scalable supply-chains}

[cut]
```


Print attribute values:

```
((wget https://jsonplaceholder.typicode.com/users) | ConvertFrom-Json).name
Leanne Graham
Ervin Howell
Clementine Bauch
[cut]
```

Select specific attributes (mind the parentheses):

```
 ((wget https://jsonplaceholder.typicode.com/users) | ConvertFrom-Json) | select name, username

name                     username
----                     --------
Leanne Graham            Bret
Ervin Howell             Antonette
Clementine Bauch         Samantha
Patricia Lebsack         Karianne
[cut]
```

From json -> filter -> to json:

```
((wget https://jsonplaceholder.typicode.com/users) | ConvertFrom-Json) | Select-Object name,email | ConvertTo-Json
[
    {
        "name":  "Leanne Graham",
        "email":  "Sincere@april.biz"
    },
    {
        "name":  "Ervin Howell",
        "email":  "Shanna@melissa.tv"
    },
[cut]    
```


## Http redirection checking

Use of `Invoke-WebRequest` without the automatic follow redirection to check step by step the flow:

```
Invoke-WebRequest http://some_site.com -MaximumRedirection 0 -erroraction 'silentlycontinue' | % { $_.StatusCode; $_.Headers.Location }
302
https://some_site.com/                         <- https redirection

Invoke-WebRequest https://some_site.com -MaximumRedirection 0 -erroraction 'silentlycontinue' | % { $_.StatusCode; $_.Headers.Location }
302
https://some_site.com/index.php/login          <- uri redirection

Invoke-WebRequest https://some_site.com/index.php/login -MaximumRedirection 0 -erroraction 'silentlycontinue' | % { $_.StatusCode; $_.Headers.Location }
200                                            <- and we're done
```



## Regexp

Basic extract sample:

```
$myString = "Hello, this is (betweet parenthesis) and this is outside"

$r = [regex]"\((.*)\)"
$match = $r.match($myString)
Write-Host $match.groups[1].value
```

The script will output:
```
betweet parenthesis
```

## Basic string stuff

Splitting: 
```
$myString = "This is before # and this is after"
($before, $after) = $myString.Split('#');

Write-Host $before
Write-Host $after
```

The script will output:
```
This is before 
 and this is after
```


## Performance counters

**Important**: the counter names are dependant on the system language...

Some samples:
```
Get-Counter '\processore(_total)\% tempo processore'

Timestamp                 CounterSamples                                                                                      
---------                 --------------                                                                                      
04/07/2018 12:31:54       \\desktop-kp15lkb\processore(_total)\% tempo processore :                                           
                          12,1488778645121                                                                                    

(Get-Counter '\processore(_total)\% tempo processore').CounterSamples.CookedValue
9,45587401333129        


Get-Counter '\processo(chrome)\% tempo processore'

Timestamp                 CounterSamples                                                                                      
---------                 --------------                                                                                      
04/07/2018 12:35:31       \\desktop-kp15lkb\processo(chrome)\% tempo processore :                                             
                          4,67465125356445              
                         
```

## Generic WMI one liners

```
Get-WmiObject -Class Win32_Bios | Format-List  *


PSComputerName                 : DESKTOP-SOMETHING
Status                         : OK
Name                           : 0BIOS Version:0.38
Caption                        : 0BIOS Version:0.38
SMBIOSPresent                  : True
```

```
Get-WmiObject -Class Win32_LogicalDisk | ft

DeviceID DriveType ProviderName    FreeSpace         Size VolumeName
-------- --------- ------------    ---------         ---- ----------
C:               3              192219000832 440031830016
D:               3                 812290048    827322368
E:               5
F:               3                 367546368    914354176
X:               3                5021925376  21453586432
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

SMTP address filtered report - multiple conditions
```
Get-MessageTrackingLog -Start "08/31/2018 09:00:00" -End "08/31/2018 23:30:00" -Eventid "RECEIVE" | % {if (($_.Source -eq "SMTP") -and ($_.clientip -ne "183.93.34.216") -and -not ($_.clientip -like "192.168.*")   ) { $_  } } | ft clientip, Sender, Recipients, MessageSubject
```

Mailbox simple report:
```
get-mailbox | ft Name, PrimarySmtpAddress, SamAccountName

Name                                    PrimarySmtpAddress                      SamAccountName
----                                    ------------------                      --------------
Administrator                           Administrator@something.it              Administrator
Simone Zabberoni                        simone.zabberoni@something.it           szabberoni
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


Manage folder and shared calendar permissions:
```
Get-MailboxFolderPermission -Identity Simone.Zabberoni:\Calendario

FolderName           User                 AccessRights
----------           ----                 ------------
Calendario           Default              {AvailabilityOnly}
Calendario           Anonymous            {None}
Calendario           Mario Rossi		  {Reviewer}


Add-MailboxFolderPermission -Identity Simone.Zabberoni:\Calendario -User Segreteria.Tecnica  -AccessRights Editor

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


## Windows fileshare details


Local:

```
Get-SmbShare

Name                     Path                                      Description
----                     ----                                      -----------
print$                   C:\WINDOWS\system32\spool\drivers         Driver della stampante
C$                       C:\                                       Condivisione predefinita
IPC$                                                               IPC remoto
ADMIN$                   C:\WINDOWS                                Amministrazione remota
```


For remote server with `Get-WmiObject`:

```
Get-WmiObject -Class Win32_Share -ComputerName someserver

Name                     Path                                      Description
----                     ----                                      -----------
print$                   C:\WINDOWS\system32\spool\drivers         Driver della stampante
C$                       C:\                                       Condivisione predefinita
IPC$                                                               IPC remoto
ADMIN$                   C:\WINDOWS                                Amministrazione remota
```


More tips on [http://powershell-guru.com/powershell-tip-89-list-shares-on-local-and-remote-computer/]





