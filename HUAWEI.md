# S57xx useful stuff

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
interface stack-port 0/1
port interface XGigabitEthernet 0/0/1 enable

interface stack-port 0/2
port interface XGigabitEthernet 0/0/2 enable
```

On the secondary:

```

stack slot 0 renumber 1

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
local-user szabberoni password cipher SomeStrongPassword123!
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

## POE

```
[some-switch] display poe power-state
PORTNAME            POWERON/OFF  ENABLED  FAST-ON  PRIORITY STATUS
--------------------------------------------------------------------------------
GigabitEthernet0/0/1     on      enable   -        Low      Powered
GigabitEthernet0/0/2     off     enable   -        Low      Detecting
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

```

```
