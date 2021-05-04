# HP Switches

## Configuration

#### 2930M - SSL only web management

Clear pki, create a new self signed cert and install it
```
crypto pki zeroize

crypto pki identity-profile SomeSwitchCert subject
Enter Common Name(CN) : SomeSwitchCert
Enter Org Unit(OU) :
Enter Org Name(O) :
Enter Locality(L) :
Enter State(ST) :
Enter Country(C) :

crypto pki enroll-self-signed certificate-name SomeSwitchCert valid-start 01/01/2021 valid-end 12/31/2041
```

No telnet, no http, ssl only
```
no web-management plaintext
web-management ssl
no telnet-server
```

---

## Various informations, hardware inventory

#### Hardware and serial numbers

System information, serial numbers etc
```
show system
[lots of output]
```

Power supply status and serial numbers
```
# show system  power-supply

Power Supply Status:

  Member  PS#   Model     Serial      State           AC/DC  + V        Wattage   Max
  ------- ----- --------- ----------- --------------- ----------------- --------- ------
  1       1     JL085A    XXXXXXXXXXX Powered         AC 120V/240V         6       250
  1       2     JL085A    XXXXXXXXXXX Powered         AC 120V/240V        16       250
  2       1     JL085A    XXXXXXXXXXX Powered         AC 120V/240V         0       250
  2       2     JL085A    XXXXXXXXXXX Powered         AC 120V/240V        23       250
  3       1     JL085A    XXXXXXXXXXX Powered         AC 120V/240V        14       250
  3       2     JL085A    XXXXXXXXXXX Powered         AC 120V/240V         8       250
```

Stack modules and serial numbers
```
#  show modules

 Status and Counters - Module Information


  Stack ID       : XXXXXXXXXX

  Member
  ID     Slot     Module Description                  Serial Number    Status
  ------ -------- ----------------------------------- ---------------- -------
  1      STK      Aruba JL325A 2p Stacking Module     XXXXXXXXXX       Up
  2      STK      Aruba JL325A 2p Stacking Module     XXXXXXXXXX       Up
  3      STK      Aruba JL325A 2p Stacking Module     XXXXXXXXXX       Up
```




#### SFP+ details

```
# show interfaces transceiver A1

Transceiver Technical Information:

                     Product      Serial             Part
 Port    Type        Number       Number             Number
 ------- ----------- ------------ ------------------ ----------
 A1      SFP+ER      J9153A       XXXXXXXXXX         1990-4064
```

---

## LLDP/CDP Stuff

#### LLDP informations
```
# show lldp info remote-device

 LLDP Remote Devices Information

  LocalPort | ChassisId                 PortId PortDescr SysName
  --------- + ------------------------- ------ --------- ----------------------
  2         | RUJ-XXXX                  Gig...
  48        | CS-XXXX-XX-1-A            Gig...
  49        | 86 ae 12 1e 1b 00         1      A1        PR_SW01_XXXX

```
