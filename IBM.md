# IBM - Thales Software



## Guardium / Vormetric / CTE VTE LDT - Transparent file encryption


### API example - decrypt LDT guarded GP

https://thalesdocs.com/ctp/cm/2.5/admin/cte_ag/cte-api-examples/cte-decrypt-ldt/index.html



### Voradmin agent stuff


Status of all LDT Guard Points:

```
C:\Program Files\Vormetric\DataSecurityExpert\agent\vmd\bin>voradmin.exe ldt list all
Successfully list file in progress rekey for all the guard points

GuardPoint                    Rekey Status In Progress     Guard point Status
------------------------------ ----------   --------------  -------------------
d:\some_directory               Rekeyed       0 Files       Done
d:\another_directory            Rekeying      2 Files       Transformation in progress
```


Details of a specific LDT Guard Point

```
C:\Program Files\Vormetric\DataSecurityExpert\agent\vmd\bin>voradmin.exe ldt attr get  d:\some_directory

Live Data Transformation Stats
--------------------------------

    Rekey Status                      LDT_ST_REKEYED
    Last rekey completion time        08/18/2021 19:38:28
    Rekey Start time                  08/18/2021 19:8:39
    Estimated rekey completion time   000:00:00

File Stats:
    Total      16203
    Rekeyed    16203
    Skipped    0
    Errored    0
    Passed     0
    Removed    0
    Excluded   0

Data Stats:
    Total      24 GB (26231619379 Bytes)
    Rekeyed    24 GB (26231619379 Bytes)
    Truncated  0 Bytes
```

Even more details:
```
C:\Program Files\Vormetric\DataSecurityExpert\agent\vmd\bin>voradmin.exe ldt attr get  d:\some_directory -details
[cut]

```

---

## xForce

### References
https://www.ibm.com/it-it/products/xforce-exchange
https://api.xforce.ibmcloud.com/doc/?_ga=2.91452125.659528146.1631004279-858860502.1612432487
https://securityintelligence.com/a-gentle-introduction-to-the-x-force-exchange-api/#.Va5HhHUVhBc
https://www.ibm.com/it-it/products/xforce-exchange/editions


### Simplest API curl wrapper 
Download it [here](https://github.com/Simone-Zabberoni/misc-one-liners/blob/master/IBM/xforceUrlCheck.sh).

Requires:
- xForce api key and secret
- jq tool

```

./xforceUrlCheck.sh https://www.ansa.it
{
  "result": {
    "url": "www.ansa.it",
    "cats": {
      "News / Magazines": true,
      "Search Engines / Web Catalogues / Portals": true
    },
    "score": 1,
    "categoryDescriptions": {
      "News / Magazines": "This category contains Web sites with news, headlines and magazines.",
      "Search Engines / Web Catalogues / Portals": "This category contains search engines, Web catalogues and Web portals. Dating sites, Social Networking sites and Business Networking sites are not listed here but in their own categories."
    }
  },
  "associated": [
    {
      "url": "ansa.it",
      "cats": {
        "News / Magazines": true,
        "Search Engines / Web Catalogues / Portals": true
      },
      "score": 1,
      "categoryDescriptions": {
        "News / Magazines": "This category contains Web sites with news, headlines and magazines.",
        "Search Engines / Web Catalogues / Portals": "This category contains search engines, Web catalogues and Web portals. Dating sites, Social Networking sites and Business Networking sites are not listed here but in their own categories."
      }
    }
  ],
  "tags": []
}


./xforceUrlCheck.sh http://lnstagram-covidhelp.ml
{
  "result": {
    "url": "lnstagram-covidhelp.ml",
    "cats": {
      "Early Warning": true
    },
    "score": 10,
    "categoryDescriptions": {
      "Early Warning": "This category contains potentially malicious domains identified by analysing DNS traffic."
    }
  },
  "tags": [
    {
      "entityType": "report",
      "tag": "covid-19",
      "user": "http://www.ibm.com/XFORCE0001",
      "date": "2021-08-29T13:59:50.750000Z",
      "commentId": "",
      "entityId": "url-http://lnstagram-covidhelp.ml",
      "type": "tag",
      "displayName": "X-Force"
    }
  ]
}

```


---

# QRadar

## Console

### Version

Retrieve version, fixpack, ip addresses etc.

```
/opt/qradar/bin/myver -v

Product is 'QRadar'
Appliance is 'software'
Core version is '2021.6.1.20220215133427'
Latest version is '2021.6.1.20220215133427'
Branded version is ''
External version is '7.5.0'
Branded latest version is ''
Release name is '7.5.0 UpdatePackage 1'
Version installed with is '7.3.2.20190410024210'
Internal version is '2021.6.1.0'
RPM version is '2021.6.1.20220215133427'
RPM external version is '7.5.0'
QRM enabled: 'false'
QRM DB enabled: 'false'
QVM DB enabled: 'true'
QF DB enabled: 'false'
Graph DB enabled: 'false'
Console: 'true'
Console IP: '1.2.3.4'
IP address: '1.2.3.4'
Virtual IP: '1.2.3.4'
Virtual Hostname: 'myqradar'
Vendor: 'xxxx'
Branded Product Name: 'QRadar'
Product Description: 'QRadar'
Kernel architecture: 'x86_64'
CPU supports 64bit: 'true'
Operating System: 'Red Hat Enterprise Linux Server release 7.9 (Maipo)'
HA identity: 'N/A'
Connection to Console is encrypted: 'false'
Docker enabled: 'true'
Supports Apps: 'true'
DNS: '1.2.3.5', '1.2.3.6'
Internal Hostname: 'something.localdeployment'
FIPS enabled: 'false'
Secure boot status: 'Only available on EFI firmware systems'
```

### Change qradar ip address

Changing the network settings in an All-in-One system
https://www.ibm.com/docs/en/qsip/7.5?topic=nsm-changing-network-settings-in-all-in-one-system

Use `qchange_netsetup` from a local connection (drac or VmWare console)




### Backups

Location for system and app backup

```
ls /store/backup/back* -alsh

2.7G -rw-r--r-- 1 root root 2.7G Feb 28 00:05 /store/backup/backup.nightly.xxxxxxxxxxxxxx.27_02_2023.config.1677539136013.tgz
2.7G -rw-r--r-- 1 root root 2.7G Mar  1 00:05 /store/backup/backup.nightly.xxxxxxxxxxxxxx.28_02_2023.config.1677625535505.tgz


ls  /store/apps/backup/back* -alsh

1.6G -rw-r--r-- 1 root root 1.6G Feb 28 02:41 /store/apps/backup/backup.apps-volumes.all.1677547803.tgz
1.7G -rw-r--r-- 1 root root 1.7G Mar  1 02:42 /store/apps/backup/backup.apps-volumes.all.1677634202.tgz
```


### Misc

Check postgres version from db itself

```
xpsql -U qradar -t -c "select VERSION();"
 PostgreSQL 11.16 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44), 64-bit
```


### Applications

Application list with id and status:
```
psql -U qradar -c "select id,name,status from installed_application_instance"

  id  |               name                | status
------+-----------------------------------+---------
 1856 | Cisco Cloud Security              | RUNNING
 1056 | Incident Overview                 | RUNNING
 1052 | Reference Data Import - LDAP      | RUNNING
 2101 | QRadar Assistant                  | RUNNING
 2053 | User Analytics                    | ERROR
 1853 | IOC Manager for QRadar            | RUNNING
```
---

## Wincollect


### Intall from commandline

Written on `"CmdLine.txt"` in the install dir:

```
wincollect-7.2.9-72.x64.exe /s /v"/qn INSTALLDIR=\"C:\Program Files\IBM\WinCollect\" AUTHTOKEN=xxxxxxx-xxxxx-xxxxx-xxxxx-xxxxxx FULLCONSOLEADDRESS=_QRADAR_FQDN_:8413 HOSTNAME=_CURRENT_SERVER_ LOG_SOURCE_AUTO_CREATION_ENABLED=True LOG_SOURCE_AUTO_CREATION_PARAMETERS=""Component1.AgentDevice=DeviceWindowsLog&Component1.Action=create&Component1.LogSourceName=_CURRENT_SERVER_&Component1.LogSourceIdentifier=_CURRENT_SERVER_&Component1.Log.Security=true&Component1.Log.System=true&Component1.Log.Application=true&Component1.Log.DNS+Server=false&Component1.Log.File+Replication+Service=false&Component1.Log.Directory+Service=false&Component1.Destination.Name=_QRADAR_FQDN_&Component1.RemoteMachinePollInterval=3000&Component1.EventRateTuningProfile=High+Event+Rate+Server&Component1.MinLogsToProcessPerPass=1250&Component1.MaxLogsToProcessPerPass=1875"""
```


### Token refresh

Navigate to the bin directory for the WinCollect agent. The default path is C:\Program Files\IBM\WinCollect\bin.
To change the authentication token for your WinCollect agent, type:
```
InstallHelper.exe -T xxxxx-xxxx-xxxx-xxxx-xxxxx
```

### Change destination qradar ip address/hostname

https://www.ibm.com/support/pages/wincollect-how-change-or-update-qradar-appliance-manages-agent-updated

Stop the Wincollect service, then edit the file `install_config.txt` located in `%Program Files\IBM\WinCollect\config%`

Modify `ConfigurationServer` and `StatusServer` with the new ip address of FQDN of QRadar, then restartthe  Wincollect service



### Wincollect agent connection issues

After QRAdar ip change, some weird Wincollect issues can arise...

Some fixes to try in sequence (stop and start wincollect agent before and after changes):

1) Replace the old ip with the new one (or FQDN) into `Agentconfig.xml`
Use IP or FQDN, not the Wincollect destination name

2) Rename the old agent key in the QRadar's store
```
cd /store/configservices/wincollect/configserver/SERVERNAME/some.key
mv some.key some.old

systemctl restart ecs-ec-ingress
```
Restart wincollect agent, a new key should appear

3) Renew/redownload configserver.pem 
Go into the wincollect agent configuration folder, delete the configserver.pem file and restart the wincollect service.
In my case, the PEM file was identical... but it worked!




