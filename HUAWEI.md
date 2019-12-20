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

Test: unplug one of the QSFP+ connector, the topology changes to `link`:

```
Dec 20 2019 16:57:30 HUAWEI %%01FSP/4/TOPO_CHANGE(l)[55]:Topology changed from 1 to 0(0: link, 1: ring).
```
