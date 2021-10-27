# Fortigate useful commands


# CONFIGURATION

### Interfaces

##### Basic interface setup
```
config system interface
edit "port1"
set mode static
set ip 192.168.1.201 255.255.255.0
set allowaccess ping https ssh telnet http
end
```

##### LACP Interface - vlan1
```
config system interface
edit "LACP-VLAN1"
set vdom "root"
set mode manual
set ip 192.168.1.1 255.255.255.0
set type aggregate
set member "internal1" "internal2" 
set device-identification enable
set lldp-transmission enable
set role lan
next
end
```

#### GRE tunnel and interface ip setup
```
config system gre-tunnel
    edit "GRE_1_1"
        set interface "port1"
        set remote-gw 172.22.1.1
        set local-gw 172.21.1.1
    next
    edit "GRE_2_2"
        set interface "port2"
        set remote-gw 172.22.2.1
        set local-gw 172.21.2.1
    next
end
```

```
config system interface
edit "GRE_1_1"
set ip 10.99.1.1 255.255.255.255
set type tunnel
set remote-ip 10.99.1.2
set interface "port1"
next

edit "GRE_2_2"
set ip 10.99.2.1 255.255.255.255
set type tunnel
set remote-ip 10.99.2.2/32
set interface "port2"
next
end
```

---

### Licensing issue on evaluation vm

#### NTP Fixup
```
config system ntp
set ntpsync disable
set type custom
end
```

#### or Factory reset
```
exec factoryreset
```

---


### NAT

##### VIP Configuration
```
config firewall vip
edit "VIP_SOMETHING_TCP_443"
set extip 1.2.3.4
set extintf "any"
set portforward enable
set mappedip "192.186.1.20"
set extport 443
set mappedport 443
next
end

config firewall vip
edit "VIP_SOMETHING_UDP_554"
set extip 1.2.3.4
set extintf "any"
set portforward enable
set mappedip "192.168.1.20"
set extport 554
set mappedport 554
set protocol udp
next
end
```
---

### Wireless


##### Fortigate WEP obsolete configuration - CLI ONLY
```
config wireless-controller vap
edit legacy-wifi-ssid
set security-obsolete-option enable
set security wep64
set key 70617373776f7264	<- hex for "password"
end
```


---

### Routing

### MTU and mss
MTU and MSS Clamp: https://docs.fortinet.com/document/fortigate/7.0.0/administration-guide/596096/interface-mtu-packet-size


#### Ospf and DUAL gre setup - small mtu, propagation filtering and Cisco ABR

```
# show router prefix-list
config router prefix-list
    edit "ospf-filter"
        config rule
            edit 1
                set action deny
                set prefix 192.168.20.0 255.255.255.0
                unset ge
                unset le
            next
            edit 2
                set prefix any
                unset ge
                unset le
            next
        end
    next
end


# show router ospf
config router ospf
    set abr-type cisco
    set router-id 192.168.1.1
    config area
        edit 0.0.0.0
            config filter-list
                edit 1
                    set list "ospf-filter"
                next
            end
        next
    end
    config ospf-interface
        edit "GRE_1_1"
            set interface "GRE_1_1"
            set dead-interval 40
            set hello-interval 10
            set mtu 1300
            set network-type point-to-point
        next
        edit "GRE_1_2"
            set interface "GRE_1_2"
            set dead-interval 40
            set hello-interval 10
            set mtu 1300
            set network-type point-to-point
        next
    end
    config network
        edit 5
            set prefix 192.168.2.0 255.255.255.0
        next
        edit 3
            set prefix 192.168.3.0 255.255.255.0
        next
        edit 4
            set prefix 192.168.10.0 255.255.255.0
        next
    end
    config redistribute "connected"
    end
    config redistribute "static"
    end
    config redistribute "rip"
    end
    config redistribute "bgp"
    end
    config redistribute "isis"
    end
end


```

---

# SHOW 

```
# show full-configuration firewall vip
# show full-configuration vpn ipsec phase1-interface
```

```
config router static
show 
[cut]
```

---

# GET / DEBUG / DIAG / TROUBLESHOOT

#### High availability

```
# get system ha status
HA Health Status: OK
Model: FortiGate-60F
Mode: HA A-P
Group: 0
Debug: 0
Cluster Uptime: 0 days 16:51:43
Cluster state change time: 2021-01-22 02:03:35
Master selected using:
```

#### GRE
```
A_FG # diagnose sys gre list
IPv4:

vd=0 devname=GRE_2_2 devindex=6 ifindex=19
saddr=172.21.2.1 daddr=172.22.2.1 ref=0
key=0/0 flags=0/0 dscp-copy=0 diffservcode=000000

vd=0 devname=GRE_1_1 devindex=3 ifindex=18
saddr=172.21.1.1 daddr=172.22.1.1 ref=0
key=0/0 flags=0/0 dscp-copy=0 diffservcode=000000

total tunnel = 2


IPv6:

total tunnel = 0
```
```
A_FG # diag netlink interface list | grep GRE
if=GRE_1_1 family=00 type=778 index=18 mtu=1476 link=0 master=0
if=GRE_2_2 family=00 type=778 index=19 mtu=1476 link=0 master=0
```
```
A_FG # get system gre-tunnel
== [ GRE_1_1 ]
name: GRE_1_1
== [ GRE_2_2 ]
name: GRE_2_2
```

#### Routing tables
```
get router info routing-table static
get router info routing-table connected
get router info routing-table all
```
#### OSPF Routing tables
```
A_FG # get router info ospf neighbor
OSPF process 0, VRF 0:
Neighbor ID     Pri   State           Dead Time   Address         Interface
10.2.1.1          1   Full/ -         00:00:38    10.99.1.2       GRE_1_1
10.2.1.1          1   Full/ -         00:00:35    10.99.2.2       GRE_2_2
```
```
A_FG # get router info ospf route

OSPF process 0:
Codes: C - connected, D - Discard, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2

C  10.1.1.0/24 [1] is directly connected, port3, Area 0.0.0.0
O  10.2.1.0/24 [11] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
O  10.50.0.0/22 [11] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
C  10.99.1.1/32 [10] is directly connected, GRE_1_1, Area 0.0.0.0
O  10.99.1.2/32 [10] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
C  10.99.2.1/32 [30] is directly connected, GRE_2_2, Area 0.0.0.0
O  10.99.2.2/32 [10] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
O  10.255.1.7/32 [110] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
O  10.255.1.8/32 [10] via 10.99.1.2, GRE_1_1, Area 0.0.0.0
```
```
A_FG # get router info routing-table ospf			<- example with different interface cost
Routing table for VRF=0
O       10.2.1.0/24 [110/11] via 10.99.1.2, GRE_1_1, 00:14:08
O       10.50.0.0/22 [110/11] via 10.99.1.2, GRE_1_1, 00:14:08


A_FG # get router info routing-table ospf			<- example with the same interface cost
Routing table for VRF=0
O       10.2.1.0/24 [110/11] via 10.99.1.2, GRE_1_1, 00:01:41
                    [110/11] via 10.99.2.2, GRE_2_2, 00:01:41
O       10.50.0.0/22 [110/11] via 10.99.1.2, GRE_1_1, 00:01:41
                     [110/11] via 10.99.2.2, GRE_2_2, 00:01:41

```

```
A_FG # get router info ospf interface GRE_1_1
GRE_1_1 is up, line protocol is up
  Internet Address 10.99.1.1/32, Area 0.0.0.0, MTU 1476
  Process ID 0, VRF 0, Router ID 10.1.1.1, Network Type POINTOPOINT, Cost: 10
  Transmit Delay is 1 sec, State Point-To-Point
  Timer intervals configured, Hello 10.000, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:07
  Neighbor Count is 1, Adjacent neighbor count is 1
  Crypt Sequence Number is 0
  Hello received 160 sent 162, DD received 3 sent 4
  LS-Req received 0 sent 0, LS-Upd received 5 sent 5
  LS-Ack received 5 sent 5, Discarded 0


A_FG # get router info ospf interface GRE_2_2
GRE_2_2 is up, line protocol is up
  Internet Address 10.99.2.1/32, Area 0.0.0.0, MTU 1476
  Process ID 0, VRF 0, Router ID 10.1.1.1, Network Type POINTOPOINT, Cost: 10
  Transmit Delay is 1 sec, State Point-To-Point
  Timer intervals configured, Hello 10.000, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:02
  Neighbor Count is 1, Adjacent neighbor count is 1
  Crypt Sequence Number is 0
  Hello received 160 sent 163, DD received 3 sent 4
  LS-Req received 1 sent 1, LS-Upd received 7 sent 7
  LS-Ack received 6 sent 6, Discarded 0
```

Debugging
```
A_FW # diagnose ip router ospf show
OSPF debugging status:
  OSPF all IFSM debugging is on
  OSPF all NFSM debugging is on
  OSPF packet Hello detail debugging is on
  OSPF packet Database Description detail debugging is on
  OSPF packet Link State Request detail debugging is on
  OSPF packet Link State Update detail debugging is on
  OSPF packet Link State Acknowledgment detail debugging is on
  OSPF all LSA debugging is on
  OSPF all NSM debugging is on
  OSPF all events debugging is on
  OSPF all route calculation debugging is on
  OSPF debugging level is CRITICAL
timestamp disabled


A_FW # diagnose ip router ospf level info

A_FW # diagnose debug enable

A_FW # diagnose debug disable

  then revert to critical only
A_FW # diagnose ip router ospf level critical

```


##### Check for policy match (equivalent of GUI Policy Lookup)

```
diag firewall iprope lookup <src_ip> <src_port> <dst_ip> <dst_port> <protocol> <Source interface>
diag firewall iprope lookup 192.168.1.20 12345 8.8.8.8 443 tcp port1
```
*Note: needs a route to the destination, otherwise -> implicit deny*

##### Flow debugging
```
diag debug enable
diag debug flow filter addR <PC1>    or    diag debug flow filter addR <PC2>
diag debug flow show console enable
diag debug flow trace start 100          <== this will display 100 packets for this flow
diag debug enable

diag debug enable
diagnose debug flow filter addr 192.168.1.20
diag debug flow show console enable
diag debug flow trace start 100         
diag debug enable
```



#### Get referenced objects
```
diagnose sys cmdb refcnt show system.interface.name  internal
[cut]


diagnose sys cmdb refcnt show system.interface.name SOME_VLAN_IF
entry used by child table interface:interface-name 'SOME_VLAN_IF' of table system.zone:name 'SOME_ZONE'

diagnose sys cmdb refcnt show system.zone.name SOME_ZONE
entry used by child table srcintf:name 'SOME_ZONE' of table firewall.policy:policyid '6'
entry used by child table srcintf:name 'SOME_ZONE' of table firewall.policy:policyid '9'
entry used by child table srcintf:name 'SOME_ZONE' of table firewall.policy:policyid '8'
entry used by child table dstintf:name 'SOME_ZONE' of table firewall.policy:policyid '7'
```


#### VPN Debugging
```
diagnose vpn ike log filter name <phase1-name>

diagnose vpn ike log filter name MyVPN
diagnose debug app ike -1
diagnose debug enable


diagnose vpn ike log-filter dst-addr 192.168.14.2
diagnose debug app ike 255
diagnose debug enable
```

Stop debug:
```
diagnose vpn ike log-filter clear
diagnose debug disable
```

Should you need to clear an IKE gateway, use the following commands:
```
diagnose vpn ike restart
diagnose vpn ike gateway clear
```


To prompt your FortiGate to connect to FortiGuard, connect to the CLI and use the following command:
```
diagnose debug application update -1
diagnose debug enable
execute update-now
```

#### VPN PSK Extract plaintext
```
https://[Address]:[port]/api/v2/cmdb/vpn.ipsec/phase1-interface?plain-text-password=1
```


---


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

