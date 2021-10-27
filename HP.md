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


#### Dhcp snooping

Snoop sample:
```
dhcp-snooping
dhcp-snooping vlan 1-1024
dhcp-snooping trust 49-51
```

```
show dhcp-snooping

 DHCP Snooping Information

  DHCP Snooping              : Yes
  Enabled VLANs              : 1-1024
  Verify MAC address         : Yes
  Option 82 untrusted policy : drop
  Option 82 insertion        : Yes
  Option 82 remote-id        : mac
  Store lease database       : Not configured

                  Max     Current Bindings
   Port  Trust  Bindings  Static   Dynamic
  -----  -----  --------  ----------------
    49    Yes      -        -        -
    50    Yes      -        -        -
    51    Yes      -        -        -

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

---

# HP Aruba OS CX

## Configuration


#### OS CX LAG to Fortigate LACP

On CX switch:
```
show running-config interface lag 12
interface lag 12
    no shutdown
    no routing
    vlan trunk native 1
    vlan trunk allowed 1-30
    lacp mode active
    lacp rate fast
    exit
```

On Fortigate:
```
config system interface
    edit "Some LACP"
        set vdom "root"
        set ip 172.17.2.254 255.0.0.0
        set allowaccess ping
        set type aggregate
        set member "x1" "x2"
        set device-identification enable
        set lldp-transmission enable
        set role lan
        set snmp-index 24
        set lacp-mode passive
    next
end
```

---

### 6300 stack PSU and fans
```
show environment  power-supply

         Product  Serial                PSU           Wattage
Mbr/PSU  Number   Number                Status        Maximum
--------------------------------------------------------------
1/1      JL085A   xxxxxxxxxx            OK            250
1/2      JL085A   xxxxxxxxxx            OK            250
2/1      JL085A   xxxxxxxxxx            OK            250
2/2      JL085A   xxxxxxxxxx            OK            250
```

```
show environment fan

Fan tray information
--------------------------------------------------------------------------------
Name  Description                           Status        Serial Number  Fans
--------------------------------------------------------------------------------
1/1   JL669A Aruba 6300M Fan Tray           ready         xxxxxxxxxx     2
1/2   JL669A Aruba 6300M Fan Tray           ready         xxxxxxxxxx     2
2/1   JL669A Aruba 6300M Fan Tray           ready         xxxxxxxxxx     2
2/2   JL669A Aruba 6300M Fan Tray           ready         xxxxxxxxxx     2
Fan information
---------------------------------------------------------------------------
Mbr/Fan or    Product  Serial Number  Speed   Direction      Status  RPM
Mbr/Tray/Fan  Name
---------------------------------------------------------------------------
1/1/1         N/A      N/A            slow    front-to-back  ok      4156
1/1/2         N/A      N/A            slow    front-to-back  ok      4156
1/2/1         N/A      N/A            slow    front-to-back  ok      4121
1/2/2         N/A      N/A            slow    front-to-back  ok      4167
2/1/1         N/A      N/A            slow    front-to-back  ok      4187
2/1/2         N/A      N/A            slow    front-to-back  ok      4143
2/2/1         N/A      N/A            slow    front-to-back  ok      4176
2/2/2         N/A      N/A            slow    front-to-back  ok      4141
```

### 6200 stack PSU and fans
```
show environment power-supply

         Product  Serial                PSU           Wattage
Mbr/PSU  Number   Number                Status        Maximum
--------------------------------------------------------------
1/1      N/A      N/A                   OK            200
2/1      N/A      N/A                   OK            200
```

```
show environment fan

Fan information
---------------------------------------------------------------------------
Mbr/Fan       Product  Serial Number  Speed   Direction      Status  RPM
              Name
---------------------------------------------------------------------------
1/1           N/A      N/A            slow    left-to-back   ok      4128
1/2           N/A      N/A            slow    left-to-back   ok      4192
1/3           N/A      N/A            slow    left-to-back   ok      4158
2/1           N/A      N/A            slow    left-to-back   ok      4134
2/2           N/A      N/A            slow    left-to-back   ok      4172
2/3           N/A      N/A            slow    left-to-back   ok      4189
```



---
