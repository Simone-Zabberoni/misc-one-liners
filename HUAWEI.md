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

## Misc interface stuff

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

## RANCID Stuff

Uses a custom h3clogin expect script: https://github.com/Simone-Zabberoni/misc-one-liners/blob/master/h3clogin

Config file:

```
# cat /root/.cloginrc
add password * someStrongerPassword
add method * ssh
add cyphertype * aes256-ctr,aes128-ctr
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

# cat disable-initial-pass-warning.cmd
system-view
aaa
local-aaa-user password policy administrator
undo password alert original
quit
quit
quit
```

Run them:

```
# h3clogin  -u admin -x disable-initial-pass-warning.cmd 1.2.3.4
# h3clogin  -u admin -x add-szabberoni.cmd 1.2.3.4
```

Run custom commands:

```
# h3clogin  -u admin -c 'display current' 1.2.3.4
```
