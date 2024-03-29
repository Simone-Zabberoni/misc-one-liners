# S57xx / 63xx useful stuff

## Management interface setup

```
system-view
interface MEth0/0/1
 ip address 172.30.1.45 255.255.254.0
quit
ip route-static 0.0.0.0 0.0.0.0 MEth0/0/1 172.30.1.254
```

## Upgrade

Switch as ftp client - don't forget the `binary` statement! f%%%ing ftp!

```
ftp 1.2.3.4
bin
get S5730SI-V200R019C00SPC500.cc
......
bye
```

Set the new image as default and reload:

```
startup system-software S5730SI-V200R019C00SPC500.cc
reboot

Warning: It will take a few minutes to upgrade firmware. Please do not switchover, reset, remove, or power off the board when upgrade is being performed. Please keep system stable..................................................................................................................................
```

## Confirm startup firmware and patch:
```
<SW-SAMPLE>display startup
MainBoard:
  Configured startup system software:        flash:/s5735-l1-v200r021c00spc100.cc
  Startup system software:                   flash:/s5735-l1-v200r021c00spc100.cc
  Next startup system software:              flash:/s5735-l1-v200r021c00spc100.cc
  Startup saved-configuration file:          flash:/vrpcfg.zip
  Next startup saved-configuration file:     flash:/vrpcfg.zip
  Startup paf file:                          default
  Next startup paf file:                     default
  Startup license file:                      default
  Next startup license file:                 default
  Startup patch package:                     NULL
  Next startup patch package:                flash:/s5735-l-v200r021sph180.pat
```

## Manual patch loading (this does nothing... but...)
```
<SW-SAMPLE>patch load s5735-l-v200r021sph180.pat all run
Info: The patch is being loaded. Please wait for a moment...
Info: The master board does not have C patch to be loaded.
Info: The master board does not have kernel patch to be loaded.
Info: The master board does not have bin patch to be run.
Info: Finished loading the patch.

<SW-SAMPLE>patch active all.
Info: The master board does not have C patch to be activated.
Info: The master board does not have kernel patch to be activated.
Info: The master board does not have bin patch to be activated..
Info: Finished activating the patch.

<SW-SAMPLE>patch run all.
Info: The master board does not have C patch to be run.
Info: The master board does not have kernel patch to be run.
Info: The master board does not have bin patch to be run..
Info: Finished running the patch.
```

## Factory reset & reboot

```
<HUAWEI>reset factory-configuration
Warning: The command will delete all the configurations and files (except the startup, patch, module, and license files) from the device. Continue? [Y/N]:y
Warning: The system will reboot after configurations and files are deleted. Continue? [Y/N]:y
Info: Start restoring factory configurations. Please wait...
Info: This operation will take several seconds. Please wait.......
```

## Device info, labels, serial numbers

```
<SW>display device
S5730-48C-SI-AC's Device status:
Slot Sub  Type                   Online    Power    Register     Status   Role
-------------------------------------------------------------------------------
0    -    S5730-48C-SI           Present   PowerOn  Registered   Normal   Master
     1    ES5D21Q04Q01           Present   PowerOn  Registered   Normal   NA
     PWR1 POWER                  Present   PowerOff Registered   Abnormal NA
     PWR2 POWER                  Present   PowerOn  Registered   Normal   NA
     FAN1 FAN                    Present   PowerOn  Registered   Normal   NA
```

```
<SW>display device manufacture-info
Slot  Sub  Serial-number          Manu-date
- - - - - - - - - - - - - - - - - - - - - -
0     -    xxxxxxxxxxxxxxxxxxxx   2019-12-26
      1    xxxxxxxxxxxxxxxx       2019-12-14
```

```
<SW>display elabel
Warning: It may take a long time to excute this command. Continue? [Y/N]:y
Info: It is executing, please wait....
/$[System Integration Version]
/$SystemIntegrationVersion=3.0


[Slot_0]
/$[Board Integration Version]
/$BoardIntegrationVersion=3.0


[Main_Board]

/$[ArchivesInfo Version]
/$ArchivesInfoVersion=3.0


[Board Properties]
BoardType=S5730-48C-SI-AC
BarCode=xxxxxxxxxx
Item=xxxxxxxxxxxx
Description=S5730-48C-SI Bundle(24 Ethernet 10/100/1000 ports,8 10 Gig SFP+,with 1 interface slot,with 150W AC power supply)
Manufactured=2019-12-26
VendorName=Huawei
IssueNumber=00
CLEICode=
BOM=

[cut]

[Board Properties]
BoardType=xxxxxxxxxxxx
BarCode=xxxxxxxxxx
Item=xxxxxxxxxxxxxxxxxxxx
Description=S5700 Series,ES0W2PSA0150,150W AC Power Module
Manufactured=2019-12-11
VendorName=Huawei
IssueNumber=00
CLEICode=
BOM=

[cut]

```

## Interfaces configuration

### Trunk with vlan 1 native

```
interface XGigabitEthernet0/0/8
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
#
interface 40GE0/1/1
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
#
```

### Trunk with another vlan native

```
interface GigabitEthernet1/0/13
 port link-type trunk
 port trunk pvid vlan 4
 port trunk allow-pass vlan 2 to 4094
#
```

### Access port

```
interface GigabitEthernet1/0/14
 port link-type access
 port default vlan 10
#
```

### LACP with vlan trunk

```
interface Eth-Trunk1
 description some trunk
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
 mode lacp
 max active-linknumber 2
#

interface XGigabitEthernet0/0/1
 eth-trunk 1
#
interface XGigabitEthernet0/0/2
 eth-trunk 1
```

## Trunk creation script

```
cat huawei-ethtrunk-create.sh
#!/bin/bash


FROM=1
TO=11


for (( interface=$FROM; interface<=$TO; interface++ ))
do

        echo "interface Eth-Trunk${interface}"
        echo "port link-type trunk"
        echo "port trunk allow-pass vlan 2 to 4094"
        echo "mode lacp"
        echo "max active-linknumber 2"
        echo "q"

        echo "interface GigabitEthernet0/0/${interface}"
        echo "eth-trunk ${interface}"

        echo "interface GigabitEthernet1/0/${interface}"
        echo "eth-trunk ${interface}"
        echo " "
done
```

## Clear interface config

```
interface GigabitEthernet0/0/24
clear configuration this
y
undo shutdown
```

## Clear interface script

```
cat huawei-interface-clear.sh
#!/bin/bash

#ROOT_INTERFACE="GigabitEthernet0/0"
ROOT_INTERFACE="GigabitEthernet1/0"
FROM=1
TO=22


for (( interface=$FROM; interface<=$TO; interface++ ))
do
        echo "interface $ROOT_INTERFACE/${interface}"
        echo "clear configuration this"
        echo "y"
        echo "undo shutdown"
done

```

## VCMP (automatic vlan propagation - similar to Cisco VTP)

VCMP server
```
system-view
vcmp role server
y

vcmp domain your-vcmp-domain
vcmp device-id your-switch-name
vcmp authentication sha2-256 password some-password
```

VCMP client
```
vcmp role client
vcmp domain your-vcmp-domain
vcmp authentication sha2-256 password some-password
```

## Simple vlan interface and routing
```
interface Vlanif10
 ip address 10.0.10.1 255.255.255.0
ip route-static 0.0.0.0 0.0.0.0 Vlanif10 10.0.10.254 
```

## Stack setup

On the first device set the maximum priority (100 by default):

```
stack slot 0 priority 100
```

On the second device set a lower priority, then renumber it and reload it

```
stack slot 0 priority 50
stack slot 0 renumber 1
reboot
```

After the reboot connect the stack loop, the secondary will detect it and reboot again to merge the stack:

```
<HUAWEI>Dec 20 2019 17:59:24 HUAWEI %%01FSP/4/SWTICH_REBOOTING(l)[2]:An SPDU message is received from another MPU, and the switch 1 will reboot.
<HUAWEI>Device will restart for stack merge
```

To check:

```
display stack
Stack mode: Card
Stack topology type: Ring
Stack system MAC: xxxx-xxxx-xxxx
MAC switch delay time: 10 min
Stack reserved VLAN: 4093
Slot of the active management port: 1
Slot      Role        MAC Address      Priority   Device Type
-------------------------------------------------------------
0         Master      xxxx-xxxx-xxxx   100        S5730-48C-SI-AC
1         Standby     xxxx-xxxx-xxxx   50         S5730-48C-SI-AC
```


Stack configuration reset - if something goes wrong
```
<HUAWEI>system-view
Enter system view, return user view with Ctrl+Z.
[HUAWEI]reset stack configuration
Warning: This operation will clear all stack configurations and may lead to the loss of the slot ID configuration and cause the device to reset immediately. Are you sure you want to continue? [Y/N]:y
Info: This operation may take a few seconds. Please wait.....
```


Stack node selective reload
```
reset slot slot-id command to restart a specified stack member device. slot-id specifies the stack ID of a member device.
```


Other commands

```
display stack peers
display stack configuration
display stack channel all
```

Test: unplug one of the QSFP+ connector, the topology changes to `link`:

```
Dec 20 2019 16:57:30 HUAWEI %%01FSP/4/TOPO_CHANGE(l)[55]:Topology changed from 1 to 0(0: link, 1: ring).
```

Stack with service ports - configure with _unplugged_ cables:

```
system-view
interface stack-port 0/1
port interface XGigabitEthernet 0/0/1 enable
y

interface stack-port 0/2
port interface XGigabitEthernet 0/0/2 enable
y

```

On the secondary:

```
system-view
interface stack-port 0/1
port interface XGigabitEthernet 0/0/1 enable
y

interface stack-port 0/2
port interface XGigabitEthernet 0/0/2 enable
y

stack slot 0 renumber 1
y

```

Reboot both nodes and plug the cables.

## RANCID Stuff

Uses a custom h3clogin expect script: https://github.com/Simone-Zabberoni/misc-one-liners/blob/master/h3clogin

Config file:

```

# cat /root/.cloginrc

add password _ someStrongerPassword
add method _ ssh
add cyphertype \* aes256-ctr,aes128-ctr

```

Some cmd files:

```

# cat add-szabberoni.cmd

system-view
aaa
local-user szabberoni password irreversible-cipher SomeStrongPassword123!
local-user szabberoni privilege level 15
local-user szabberoni service-type telnet terminal ssh ftp http
quit
quit

```

```

# cat disable-initial-pass-warning.cmd

system-view
aaa
local-aaa-user password policy administrator
undo password alert original
quit
quit
quit

```

```

# cat ntp-fixup.cmd

system-view
undo ntp-service unicast-server 2.3.4.5
ntp-service unicast-server 1.2.3.4
ntp-service refclock-master 15
clock timezone Bern,Rome,Stockholm,Vienna add 01:00:00
clock daylight-saving-time Bern,Rome,Stockholm,Vienna repeating 00:00 last Sun Mar 00:00 last Sun Oct 01:00 2000 2099
quit
save
y
quit



# cat logSet.cmd

system-view
info-center channel 6 name SomeChannelName
info-center source default channel SomeChannelName log level notification
info-center loghost source Vlanif 123
info-center loghost 1.2.3.4 channel SomeChannelName
quit
save force
quit


```

```

# cat ntp-show.cmd

displa clock
display ntp-service session
quit

```

Run them:

```

# h3clogin -u admin -x disable-initial-pass-warning.cmd 1.2.3.4

# h3clogin -u admin -x add-szabberoni.cmd 1.2.3.4

```

Run custom commands:

```

# h3clogin -u admin -c 'display current' 1.2.3.4

```

## SSH setup, disable telnet

```
system-view
ssh server key-exchange dh_group14_sha256
ssh server cipher aes256_ctr

dsa local-key-pair create


undo telnet server enable
stelnet server enable
ssh server-source -i Vlanif 168
y
quit

system-view
user-interface vty 0 4
idle-timeout 0
authentication-mode aaa
protocol inbound ssh
quit

```

## https server binding on interface
```
system-view
http server-source -i Vlanif90
y
quit
```

## DNS setup
```
system-view
dns resolve
dns server 8.8.8.8
quit
```


## SNMP
```
snmp-agent
snmp-agent community read cipher BLAHBLAH
snmp-agent sys-info contact yourmail@tld
snmp-agent sys-info location yourLocation
snmp-agent sys-info version v2c
undo snmp-agent sys-info version v3
undo snmp-agent protocol source-status all-interface
snmp-agent protocol source-interface Vlanif123
undo snmp-agent protocol source-status ipv6 all-interface
```

## LLDP over SNMP

Needed if you use netdisco or if you need to access lldp info through snmp:

Rif: https://support.huawei.com/enterprise/en/doc/EDOC1000178174/b81cd830/why-the-lldp-neighbor-information-cannot-be-obtained-through-snmp-or-the-operations-performed-on-lldp-mib-objects-do-not-take-effect


```
snmp-agent mib-view included iso-view iso
snmp-agent community read cipher some_community mib-view iso-view
```


## Logging

Setup a remote syslog with a specific log level:

```
info-center channel 6 name SomeChannelName
info-center source default channel SomeChannelName log level notification
info-center loghost source Vlanif 123
info-center loghost 1.2.3.4 channel SomeChannelName
```

Filter out noisy logs:

```
info-center filter-id bymodule-alias FSP AUTOCONFIGFAILED
```

## Local log show
```
display logfile logfile/log.log
```


## Interface mirroring

Create the observe (aka mirror) port, yout analyzer will be connected here:

```
system-view
observe-port 1 interface GigabitEthernet 1/0/14
```

Select the target port, bind it to the monitor port and select the traffic direction to monitor:

```
system-view
interface GigabitEthernet 1/0/1
port-mirroring to observe-port 1 both
```

Display monitoring status:

```
display port-mirroring
  ----------------------------------------------------------------------
  Observe-port 1 : GigabitEthernet1/0/14
  ----------------------------------------------------------------------
  Port-mirror:
  ----------------------------------------------------------------------
       Mirror-port               Direction  Observe-port
  ----------------------------------------------------------------------
  1    GigabitEthernet1/0/1      Inbound    Observe-port 1
  2    GigabitEthernet1/0/1      Outbound   Observe-port 1
  ----------------------------------------------------------------------

display observe-port
  ----------------------------------------------------------------------
  Index          : 1
  Untag-packet   : No
  Forwarding     : Yes
  Interface      : GigabitEthernet1/0/14
  ----------------------------------------------------------------------
```

## GBIC Debug

```

<SOME-SWITCH>display transceiver interface XGigabitEthernet0/0/1

## XGigabitEthernet0/0/1 transceiver information:

Common information:
Transceiver Type :10GBASE_ER_SFP
Connector Type :LC
Wavelength(nm) :1550
Transfer Distance(m) :30000(9um)
Digital Diagnostic Monitoring :YES
Vendor Name :Judging
Vendor Part Number :Judging
Ordering Name :

---

Manufacture information:
Manu. Serial Number :xxxxxxxxxxxx
Manufacturing Date :xxxxxxxxxxxx
Vendor Name :Judging

---

```

```

<SOME-SWITCH>display transceiver diagnosis interface XGigabitEthernet0/0/1
Port XGigabitEthernet0/0/1 transceiver diagnostic information:
Parameter Current Low Alarm High Alarm
Type Value Threshold Threshold Status

---

TxPower(dBm) 0.61 -8.70 7.00 normal
RxPower(dBm) -33.98 -19.79 2.00 abnormal
Current(mA) 45.94 20.00 120.00 normal
Temp.(¡ãC) 31.48 -5.00 75.00 normal
Voltage(V) 3.29 3.03 3.56 normal

```

```

<SOME-SWITCH>display transceiver verbose

## XGigabitEthernet0/0/1 transceiver information:

Common information:
Transceiver Type :10GBASE_ER_SFP
Connector Type :LC
Wavelength(nm) :1550
Transfer Distance(m) :30000(9um)
Digital Diagnostic Monitoring :YES
Vendor Name :OPNEXT,INC
Vendor Part Number :xxxxxxxxxxxxxxxx
Ordering Name :

---

Manufacture information:
Manu. Serial Number :xxxxxxxxxxxx
Manufacturing Date :xxxxxxxxxxxx
Vendor Name :OPNEXT,INC

---

Diagnostic information:
Temperature(¡ãC) :33.66
Temp High Threshold(¡ãC) :75.00
Temp Low Threshold(¡ãC) :-5.00
Voltage(V) :3.29
Volt High Threshold(V) :3.56
Volt Low Threshold(V) :3.03
Bias Current(mA) :46.53
Bias High Threshold(mA) :120.00
Bias Low Threshold(mA) :20.00
RX Power(dBM) :-33.98
RX Power High Warning(dBM) :-1.00
RX Power Low Warning(dBM) :-15.80
RX Power High Threshold(dBM) :2.00
RX Power Low Threshold(dBM) :-19.79
TX Power(dBM) :0.53
TX Power High Warning(dBM) :4.00
TX Power Low Warning(dBM) :-4.70
TX Power High Threshold(dBM) :7.00
TX Power Low Threshold(dBM) :-8.70
Transceiver phony alarm : Yes

---

```

Non-supported transceiver:

With unsupported gbics (or too recent ones!) you'll get:

```

Nov 10 2020 21:56:43+08:00 HUAWEI SRM/3/SFP_EXCEPTION:OID 1.3.6.1.4.1.2011.5.25.129.2.1.9 Optical module exception, SFP is not certified. (EntityPhysicalIndex=67469390, BaseTrapSeverity=5, BaseTrapProbableCause=136192, BaseTrapEventType=9, EntPhysicalContainedIn=67108873, EntPhysicalName=XGigabitEthernet0/0/1, RelativeResource=Interface XGigabitEthernet0/0/1 optical module exception, ReasonDescription=It has been observed that a transceiver has been installed that is not certified by Huawei Ethernet Switch. Huawei cannot ensure that it is completely adaptive and will not cause any adverse effects. If it is continued to be used, Huawei is not obligated to provide support to remedy defects or faults arising out of or resulting from installing and using of the non-certified transceiver.)
```

Alarm suppression (check with support for eligibility):

```
<HUAWEI> system-view

[HUAWEI] transceiver phony-alarm-disable

Info:Transceiver-phony-alarm disable.


```

## POE

```
[some-switch] display poe power-state
PORTNAME            POWERON/OFF  ENABLED  FAST-ON  PRIORITY STATUS
--------------------------------------------------------------------------------
GigabitEthernet0/0/1     on      enable   -        Low      Powered
GigabitEthernet0/0/2     off     enable   -        Low      Detecting
```

## Mac address flap (roaming devices, loops and issues)

```
<sw-1>display mac-address flapping record
 S  : start time
 E  : end time
(Q) : quit VLAN
(D) : error down
-------------------------------------------------------------------------------
Move-Time                 VLAN MAC-Address  Original-Port  Move-Ports   MoveNum
-------------------------------------------------------------------------------
S:2020-07-27 14:53:07 DST 1    1234-230d-1234 GE1/0/1       Eth-Trunk1    10
E:2020-07-27 15:00:24 DST                                   GE0/0/1

-------------------------------------------------------------------------------
Total items on slot 1: 1

-------------------------------------------------------------------------------
Move-Time                 VLAN MAC-Address  Original-Port  Move-Ports   MoveNum
-------------------------------------------------------------------------------
S:2020-07-27 14:25:39 DST 1    1234-230d-1231 GE1/0/1       GE1/0/4       42
E:2020-07-27 15:00:53 DST                                   GE1/0/5

-------------------------------------------------------------------------------
Total items on slot 0: 1
```

## Cable Testing - watch out!

Long cable, unplugged:

```
[HUAWEI-GigabitEthernet0/0/48]virtual-cable-test
Warning: The command will stop service for a while. Continue? [Y/N]:y
Info: This operation may take a few seconds. Please wait for a moment....................done.
Pair A length: 30meter(s)
Pair B length: 31meter(s)
Pair C length: 32meter(s)
Pair D length: 31meter(s)
Pair A state: Open
Pair B state: Open
Pair C state: Open
Pair D state: Open
Info: The test result is only for reference.
```

10 mt cable, unplugged:

```
[HUAWEI-GigabitEthernet0/0/48]virtual-cable-test
Warning: The command will stop service for a while. Continue? [Y/N]:y
Info: This operation may take a few seconds. Please wait for a moment..................done.
Pair A length: 9meter(s)
Pair B length: 11meter(s)
Pair C length: 10meter(s)
Pair D length: 10meter(s)
Pair A state: Open
Pair B state: Open
Pair C state: Open
Pair D state: Open
Info: The test result is only for reference.
```

2 mt cable, unplugged:

```
[HUAWEI-GigabitEthernet0/0/48]virtual-cable-test
Warning: The command will stop service for a while. Continue? [Y/N]:y
Info: This operation may take a few seconds. Please wait for a moment..................done.
Pair A length: 1meter(s)
Pair B length: 2meter(s)
Pair C length: 1meter(s)
Pair D length: 2meter(s)
Pair A state: Open
Pair B state: Open
Pair C state: Open
Pair D state: Open
Info: The test result is only for reference.
```

## Misc show stuff

```

[CORE]display lldp neighbor brief
Local Intf Neighbor Dev Neighbor Intf Exptime(s)
GE0/0/23 OneSwitch 119 105
XGE0/0/1 AnotherOne XGE0/0/8 117

```

```

[CORE]display interface Eth-Trunk 1
Eth-Trunk1 current state : DOWN
Line protocol current state : DOWN
Description:sw-ICT
Switch Port, Link-type : trunk(configured),
PVID : 1, Hash arithmetic : According to SIP-XOR-DIP,Maximal BW: 2G, Current BW: 0M, The Maximum Frame Length is 9216
IP Sending Frames' Format is PKTFMT_ETHNT_2, Hardware address is d0c6-5b8d-17e0
Current system time: 2020-06-03 08:48:06+01:00
Last 300 seconds input rate 0 bits/sec, 0 packets/sec
Last 300 seconds output rate 0 bits/sec, 0 packets/sec
Input: 0 packets, 0 bytes
Unicast: 0, Multicast: 0
Broadcast: 0, Jumbo: 0
Discard: 0, Pause: 0
Frames: 0

Total Error: 0
CRC: 0, Giants: 0
Runts: 0, DropEvents: 0
Alignments: 0, Symbols: 0
Ignoreds: 0

Output: 0 packets, 0 bytes
Unicast: 0, Multicast: 0
Broadcast: 0, Jumbo: 0
Discard: 0, Pause: 0

Total Error: 0
Collisions: 0, Late Collisions: 0
Deferreds: 0

    Input bandwidth utilization  :    0%
    Output bandwidth utilization :    0%

---

## PortName Status Weight

GigabitEthernet0/0/24 DOWN 1
GigabitEthernet1/0/24 DOWN 1

---

The Number of Ports in Trunk : 2
The Number of UP Ports in Trunk : 0

```

---

## BGP Lab

Two 6730 connected via XGigabitEthernet0/0/24.

Sw1 base configuration:

```
sysname sw1
#
vlan batch 10 20

interface Vlanif10
 ip address 10.0.10.1 255.255.255.0
#
interface Vlanif20
 ip address 10.0.20.1 255.255.255.0
#
interface MEth0/0/1
 ip address 192.168.1.253 255.255.255.0
#
interface XGigabitEthernet0/0/1
 port link-type access
 port default vlan 10

interface XGigabitEthernet0/0/24
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094

ip route-static 0.0.0.0 0.0.0.0 Vlanif 10 10.0.10.254

bgp 65009
 router-id 10.0.20.1
 peer 10.0.20.2 as-number 65009
 #
 ipv4-family unicast
  undo synchronization
  network 10.0.10.0 255.255.255.0		<- not necessary if default-root advertise
  peer 10.0.20.2 enable
  peer 10.0.20.2 default-route-advertise
```

Sw2 base configuration:

```
sysname sw2
#
vlan batch 20 30 40
interface Vlanif20
 ip address 10.0.20.2 255.255.255.0
#
interface Vlanif30
 ip address 10.0.30.2 255.255.255.0
#
interface Vlanif40
 ip address 10.0.40.2 255.255.255.0
interface XGigabitEthernet0/0/1
 port link-type access
 port default vlan 30
#
interface XGigabitEthernet0/0/2
 port link-type access
 port default vlan 40
#
interface XGigabitEthernet0/0/24
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094

bgp 65009
 router-id 10.0.20.2
 peer 10.0.20.1 as-number 65009
 #
 ipv4-family unicast
  undo synchronization
  network 10.0.30.0 255.255.255.0
  network 10.0.40.0 255.255.255.0
  network 192.168.69.0
  peer 10.0.20.1 enable
```

Check route propagation on both ends:

```
[sw1]display bgp routing-table

 BGP Local router ID is 10.0.20.1
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 3
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>   10.0.10.0/24       0.0.0.0         0                     0      i
 *>i  10.0.30.0/24       10.0.20.2       0          100        0      i
 *>i  10.0.40.0/24       10.0.20.2       0          100        0      i
```

```
[sw2]display bgp routing-table

 BGP Local router ID is 10.0.20.2
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 4
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>i  0.0.0.0            10.0.20.1       0          100        0      i
 *>i  10.0.10.0/24       10.0.20.1       0          100        0      i
 *>   10.0.30.0/24       0.0.0.0         0                     0      i
 *>   10.0.40.0/24       0.0.0.0         0                     0      i
```

Remove the advertising of 10.0.10.0 from Sw1, leave only the default:

```
[sw1]bgp 65009
[sw1-bgp]ipv4-family unicast
[sw1-bgp-af-ipv4]undo
[sw1-bgp-af-ipv4]undo network 10.0.10.0 255.255.255.0

[sw1]display bgp routing-table

 BGP Local router ID is 10.0.20.1
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 2
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>i  10.0.30.0/24       10.0.20.2       0          100        0      i
 *>i  10.0.40.0/24       10.0.20.2       0          100        0      i
```

Check it on Sw2:

```
<sw2>display bgp routing-table

 BGP Local router ID is 10.0.20.2
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 3
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>i  0.0.0.0            10.0.20.1       0          100        0      i
 *>   10.0.30.0/24       0.0.0.0         0                     0      i
 *>   10.0.40.0/24       0.0.0.0         0                     0      i
```

Add a static route on sw2 (10.0.50.0/24 through 10.0.40.254), import it in bgp and advertise it to Sw1:

```
[sw2] ip route-static 10.0.50.0 255.255.255.0 Vlanif 40 10.0.40.254
[sw2] bgp 65009
[sw2-bgp]import-route static
[sw2-bgp]display bgp routing-table

 BGP Local router ID is 10.0.20.2
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 4
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>i  0.0.0.0            10.0.20.1       0          100        0      i
 *>   10.0.30.0/24       0.0.0.0         0                     0      i
 *>   10.0.40.0/24       0.0.0.0         0                     0      i
 *>   10.0.50.0/24       0.0.0.0         0                     0      ?
```

Check on sw1:

```
[sw1]display bgp routing-table

 BGP Local router ID is 10.0.20.1
 Status codes: * - valid, > - best, d - damped,
               h - history,  i - internal, s - suppressed, S - Stale
               Origin : i - IGP, e - EGP, ? - incomplete


 Total Number of Routes: 3
      Network            NextHop        MED        LocPrf    PrefVal Path/Ogn

 *>i  10.0.30.0/24       10.0.20.2       0          100        0      i
 *>i  10.0.40.0/24       10.0.20.2       0          100        0      i
 *>i  10.0.50.0/24       10.0.20.2       0          100        0      ?
```

Add password authentication:

```
[sw1]bgp 65009
[sw1-bgp]peer 10.0.20.2 password cipher biggipi
```

After a while the bgp sessions goes down:

```
Nov 12 2020 13:57:45 sw1 %%01BGP/3/STATE_CHG_UPDOWN(l)[25]:The status of the peer 10.0.20.2 changed from ESTABLISHED to IDLE. (InstanceName=Public, StateChangeReason=Hold Timer Expired)
```

In the logs you'll find some auth fail:

```
Nov 12 2020 13:55:45 sw2 %%01SOCKET/4/TCP_AUTH_FAILED(s)[6]:TCP authentication failed. (AuthenticationType=MD5, Cause=no local digest, SourceAddress=10.0.20.2, SourcePort=50576, ForeignAddress=10.0.20.1, ForeignPort=179, Protocol=BGP, VpnInstanceName=)
```

Add password authentication on the other end as well:

```
[sw2]bgp 65009
[sw2-bgp]peer 10.0.20.1 password cipher biggipi
```

And after a while:

```
Nov 12 2020 13:59:31 sw2 %%01BGP/3/STATE_CHG_UPDOWN(l)[5]:The status of the peer 10.0.20.1 changed from OPENCONFIRM to ESTABLISHED. (InstanceName=Public, StateChangeReason=Up)
Nov 12 2020 13:59:31 sw2 %%01RM/4/IPV4_DEFT_RT_CHG(l)[6]:IPV4 default Route is changed. (ChangeType=Add, InstanceId=0, Protocol=BGP, ExitIf=Vlanif20, Nexthop=10.0.20.1, Neighbour=10.0.2
```

---

## VRRP Lab

Sw1 base configuration:

```
sysname sw1
#
vlan batch 10 20 30

interface Vlanif10
 ip address 10.0.10.1 255.255.255.0
 vrrp vrid 10 virtual-ip 10.0.10.254
 vrrp vrid 10 priority 120
 vrrp vrid 10 preempt-mode timer delay 20

interface Vlanif20
 ip address 10.0.20.1 255.255.255.0
 vrrp vrid 20 virtual-ip 10.0.20.254
 vrrp vrid 20 priority 120
 vrrp vrid 20 preempt-mode timer delay 20

interface Vlanif30
 ip address 10.0.30.1 255.255.255.0

interface XGigabitEthernet0/0/1
 port link-type access
 port default vlan 10

interface XGigabitEthernet0/0/24
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
```

Sw2 base configuration:

```
sysname sw2
#
vlan batch 10 20 30

interface Vlanif10
 ip address 10.0.10.2 255.255.255.0
 vrrp vrid 10 virtual-ip 10.0.10.254

interface Vlanif20
 ip address 10.0.20.2 255.255.255.0
 vrrp vrid 20 virtual-ip 10.0.20.254

interface Vlanif30
 ip address 10.0.30.2 255.255.255.0

interface XGigabitEthernet0/0/1
 port link-type access
 port default vlan 10

interface XGigabitEthernet0/0/24
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
```

Check the status on both ends:

```
[sw1]display vrrp br
Total:2     Master:2     Backup:0     Non-active:0
VRID  State        Interface                Type     Virtual IP
----------------------------------------------------------------
10    Master       Vlanif10                 Normal   10.0.10.254
20    Master       Vlanif20                 Normal   10.0.20.254
```

```

[sw2]display vrrp brief
Total:2     Master:0     Backup:2     Non-active:0
VRID  State        Interface                Type     Virtual IP
----------------------------------------------------------------
10    Backup       Vlanif10                 Normal   10.0.10.254
20    Backup       Vlanif20                 Normal   10.0.20.254
```

A pc connected to Sw2 see these mac addresses:

```
Interfaccia: 10.0.10.100 --- 0x6
  Indirizzo Internet    Indirizzo fisico      Tipo
  10.0.10.1             f4-a4-d6-0d-8d-4b     dinamico
  10.0.10.2             f4-a4-d6-25-40-eb     dinamico
  10.0.10.254           00-00-5e-00-01-0a     dinamico
```

Vlanif ip addresses are bound to real Huawei mac addresses, while the VRRP ip address is bound to a virtual mac address.

Testing: unplug Sw1 while PC is connected to Sw2 with a ping to 10.0.10.254:

```
Nov 12 2020 14:30:44 sw2 %%01VRRP/4/STATEWARNINGEXTEND(l)[7]:Virtual Router state BACKUP changed to MASTER, because of protocol timer expired. (Interface=Vlanif10, VrId=10, InetType=IPv4)
```

Just a single packet loss during the migration:

```
Risposta da 10.0.10.254: byte=32 durata=1ms TTL=254
Risposta da 10.0.10.254: byte=32 durata<1ms TTL=254
Richiesta scaduta.
Risposta da 10.0.10.254: byte=32 durata<1ms TTL=254
Risposta da 10.0.10.254: byte=32 durata<1ms TTL=254
Risposta da 10.0.10.254: byte=32 durata<1ms TTL=254
```
