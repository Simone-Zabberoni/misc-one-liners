# IBM - Thales Software



## Guardium / Vormetric / CTE VTE LDT - Transparent file encryption


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

## QRadar

TBD.


