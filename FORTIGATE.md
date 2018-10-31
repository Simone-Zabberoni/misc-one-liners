# Fortigate useful commands


## Performance troubleshooting

Equivalent procinfo and cpuinfo 
Reference: http://kb.fortinet.com/kb/viewContent.do?externalId=FD30084

```
fw # get system performance status
CPU states: 32% user 67% system 0% nice 1% idle
CPU0 states: 32% user 67% system 0% nice 1% idle
Memory states: 33% used
Average network usage: 5898 / 5810 kbps in 1 minute, 7604 / 7636 kbps in 10 minutes, 5279 / 5258 kbps in 30 minutes
Average sessions: 2571 sessions in 1 minute, 2670 sessions in 10 minutes, 2305 sessions in 30 minutes
Average session setup rate: 19 sessions per second in last 1 minute, 18 sessions per second in last 10 minutes, 15 sessions per second in last 30 minutes
Virus caught: 0 total in 1 minute
IPS attacks blocked: 0 total in 1 minute
Uptime: 176 days,  1 hours,  10 minutes
```

```
fw # diagnose hardware sysinfo memory
        total:    used:    free:  shared: buffers:  cached: shm:
Mem:  1928798208 646651904 1282146304        0  1753088 201564160 153124864
Swap:        0        0        0
MemTotal:      1883592 kB
MemFree:       1252096 kB
MemShared:           0 kB
Buffers:          1712 kB
Cached:         196840 kB
SwapCached:          0 kB
Active:         102560 kB
Inactive:        96128 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      1883592 kB
LowFree:       1252096 kB
SwapTotal:           0 kB
SwapFree:            0 kB
```


Equivalent top
Reference: http://kb.fortinet.com/kb/documentLink.do?externalID=FD30531

```
diagnose sys top 2 20

Run Time:  176 days, 1 hours and 22 minutes
80U, 19N, 0S, 1I; 1839T, 1213F
         sslvpnd       71      R      90.1     1.3
             wad       86      S       7.3     3.3
          newcli    32290      R       1.4     0.8
          httpsd    32278      S       0.4     1.2
        dnsproxy       95      S       0.0     3.0
       scanunitd    32178      S <     0.0     2.0
       scanunitd    32172      S <     0.0     2.0
       scanunitd     7249      S <     0.0     2.0
         cmdbsvr       35      S       0.0     1.7
         pyfcgid    32088      S       0.0     1.6
         pyfcgid    32090      S       0.0     1.6
         pyfcgid    32089      S       0.0     1.6
         pyfcgid    32086      S       0.0     1.4
         miglogd       54      S       0.0     1.4
          httpsd    29716      S       0.0     1.3
       forticron       65      R       0.0     1.3
          httpsd    29757      S       0.0     1.3
       ipshelper    16913      S <     0.0     1.2
          httpsd       56      S       0.0     1.1
          httpsd      108      S       0.0     1.0
```

Table reference:

```
The meaning of the letters on the second line of the output is given in the following table.
 
U  - User cpu usage (%)
S  - System cpu usage (%)
I  - dle cpu usage (%)
T  - Total memory
F  - Free memory
KF - Kernel free memory

The following table describes the output format of the others lines. 

Column #1 - Process name
Column #2 - Process identification (PID)
Column #3 - One letter process status
				S: sleeping process
				R: running process
				<: high priority
Column #4 - CPU usage (%)
Column #5 - Memory usage (%)
```


## VTEP / VXLAN setup - in progress

### Informations

At the time (31/10/2018) there isn't any kb or clear article for the following scenario.
The following setup comes from experimentation and a ticket with FG support.

Scenario
- 2 FG cluster (HQ and Branch)
- 2 WANs per site

Desiderata
- multiple VXLAN tunnel HQ-Branch
- encryption on transit 
- WAN balancing for failover

ToDo list
- [x] document the proposed setup
- [ ] implement and test without OSPF
- [ ] implement and test with OSPF
- [ ] implement and test with vlan interface (dot1q)


### Proposed solution

The solution breaks down to these components:
- FG-to-GW ipsec in `transport-mode` (http://kb.fortinet.com/kb/documentLink.do?externalID=FD31874)
- ipsec WAN redundancy (https://docs.fortinet.com/uploaded/files/4298/fortigate-ipsecvpn-60.pdf)
- n VXLANs bound to the ipsec port 
- n Virtual Wire Pair to bind VXLANs to their phisical ports (https://help.fortinet.com/fos50hlp/54/Content/FortiOS/fortigate-whats-new-54/Top_VirtualWirePair.htm)

Some other pointers
- Ipsec in tunnel mode and virtual switch - https://travelingpacket.com/2017/09/28/fortigate-vxlan-encapsulation/
- ipsec, dot1q and custom interfaces - https://forum.fortinet.com/tm.aspx?m=168042



### Scenario details

Assumptions:
- VXLAN will bind phyiscal ports, not vlan interfaces (see ToDo)
- Specular configuration (network 192.168.x.y is connected to PortX on both FG)

Ip addresses
```
FG1 WAN1: 203.0.113.1
FG1 WAN2: TBD

FG2 WAN2: 203.0.113.2 
FG2 WAN2: TBD
```

Network/Port/VXLAN mappings
```
Network            FG physical port    VXLAN ID      
--------------     --------------      --------------
192.168.25.0/24    Port2               25
192.168.35.0/24    Port3               35
192.168.45.0/24    Port4               45
```

### Sample - without OSPF, single WAN

Ipsec configuration
```
config vpn ipsec phase1-interface 
  edit "ipsec1" 
    set interface "wan1" 
    set peertype any 
    set proposal aes128-sha1 
    set remote-gw 203.0.113.2 
    set psksecret ENC 
  next 
end 

config vpn ipsec phase2-interface 
  edit "ipsec1" 
    set phase1name "ipsec1" 
    set proposal aes128-sha1 
    set auto-negotiate enable 
    set encapsulation transport-mode 
  next 
end 
```

VXLAN configuration
```
config system vxlan 
  edit "vxlan_port_25" 
    set interface "ipsec" 
    set vni 25 
    set remote-ip "203.0.113.2" 
  next 
end 

config system vxlan 
  edit "vxlan_port_35" 
    set interface "ipsec" 
    set vni 35 
    set remote-ip "203.0.113.2" 
  next 
end 

config system vxlan 
  edit "vxlan_port_45" 
    set interface "ipsec" 
    set vni 45 
    set remote-ip "203.0.113.2" 
  next 
end 
```


Virtual wire pairs
```
config system virtual-wire-pair
  edit vxlan25_port2-VWP
    set member port2 vxlan_port_25
end

config system virtual-wire-pair
  edit vxlan35_port3-VWP
    set member port3 vxlan_port_35
end

config system virtual-wire-pair
  edit vxlan45_port4-VWP
    set member port4 vxlan_port_45
end
```




### Complete solution - TBD
[Todo]


### Trunk port support - TBD

In virtual wire pairs the `wildcard-vlan enable` directive will enable the flow of tagged frames.
In theory this will simplify the setup, **if** the VXLAN permits the flow of tagged frames, by using a single VXLAN over ipsec to carry al VLANS.
```
Switch_Trunk_Port -> FG dot1q port -> VXLAN ===ipsec=== VXLAN -> FG dot1q port -> Switch_Trunk_Port 
```

This is **UNSUPPORTED** in FortiOS 5.4 (http://kb.fortinet.com/kb/documentLink.do?externalID=FD40170) but should be possibile on FortiOS 6 with `set vlanforward enable` or `set wildcard-vlan enable`

**Confirmation needed**

Possible virtual pair
```
config system virtual-wire-pair
  edit trunk-to-VXLAN-VWP
    set member port2 vxlan_all
    set wildcard-vlan enable
end
```



