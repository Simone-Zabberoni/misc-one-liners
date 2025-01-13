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


### HA, virtual mac, group id

From https://community.fortinet.com/t5/FortiGate/Technical-Tip-A-conflict-HA-virtual-MAC-address-in-the-different/ta-p/189577 :

*Due to different reasons, operating multiple HA clusters under the same Security fabric also requires unique HA group-ids, even if they don't reside on the same network.*

Set a different group id on different clusters 
ie: 
- cluster1: node A and B will have group id 10
- cluster2: node C and D will have group id 20

```
config system ha
    set group-id  XX          <----- ( XX is an integer value from 0-255).
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

#### Security profile groups - make it visible from the GUI

```
config system settings
	set gui-security-profile-group enable
end

config firewall profile-group
edit "some-group"
set av-profile some-profile
end

config firewall policy
edit 0		<- pick an existing policy
set utm-status enable
set profile-type group
set profile-group some-group
end
```

---

### Config file patterns

Remove UUID lines - replace 
```
        set uuid .*\r\n
```


---

### FSSO


https://community.fortinet.com/t5/FortiGate/Technical-Tip-How-to-enable-audit-of-logon-events-on-Windows/ta-p/189816
https://docs.fortinet.com/document/fortigate/7.2.0/administration-guide/450337/fsso
https://community.fortinet.com/t5/FortiGate/Technical-Tip-FSSO-Collector-agent-redundancy-with-two-Windows/ta-p/191577
https://docs.fortinet.com/document/fortigate/7.2.0/administration-guide/503764/fsso-polling-connector-agent-installation

Single connector with redundancy (do the same with LDAP):

```
config user fsso
edit "fsso-conn-redundant"
        set server "10.10.10.1"
        set password ENC ***
        set server2 "10.10.10.2"
        set password2 ENC ***
    next
end
```

List FSSO logon user on the FortiGate.
 ```
# diag debug authd fsso list
```
List authenticated users on the FortiGate.
``` 
# diag firewall auth list
```
List connected FSSO CA.
``` 
# diag debug reset
# diag debug enable
# diag debug authd fsso server-status
```

Additional debug
```
diagnose debug application authd 8256
diagnose debug console timestamp enable
diagnose debug enable
diagnose debug authd fsso server-status
diagnose debug authd fsso list


diagnose debug authd fsso refresh-logons	
diagnose debug authd fsso clear-logons	
diagnose debug authd fsso refresh-groups
```

Debugging authentication process
```
# diag debug reset
# diag debug console timestamp enable
# diag debug application authd -1
# diag debug application fnbamd -1
# diag debug enable
```

---

### VPN authentication order with multiple backends
https://community.fortinet.com/t5/FortiGate/Technical-Tip-A-quick-guide-to-FortiGate-SSL-VPN-authentication/ta-p/202041

TLDR: use realms for different authentication backends (ie RADIUS + LDAP)


### VPN with SAML authentication

#### Pointers

Azure- note the group attribute and the multi group match:
https://docs.fortinet.com/document/fortigate-public-cloud/7.2.0/azure-administration-guide/584456/configuring-saml-sso-login-for-ssl-vpn-with-azure-ad-acting-as-saml-idp
https://learn.microsoft.com/it-it/azure/active-directory/saas-apps/fortigate-ssl-vpn-tutorial

Okta:
https://docs.fortinet.com/document/fortigate/7.4.4/administration-guide/499536/ssl-vpn-with-okta-as-saml-idp




#### Realms and URLS - watch out!!
https://community.fortinet.com/t5/FortiGate/Technical-Tip-SSL-VPN-with-realms-and-SAML-authentication/ta-p/204708

Quote: On 'config user saml', it is not necessary to define the realm for the SP side, and configuration as shown below can be used for both scenarios with and without the realms.

**So, realm name must never be specified on idp/sp URLs** 

Always match trailing `/` in idp and FG conf


#### Debug and group mismatch
```
diagnose debug application samld -1
diag debug enable


diagnose vpn ssl debug-filter src-addr4 <client public ip address>

diagnose debug application samld -1
diagnose debug application sslvpn -1
diag debug enable
```

Look for assertion details, signing errors and mostly the attributes:

```
samld_send_common_reply [122]:     Attr: 17, 29, magic=x-xxxxxxxxxxxxxxxxxxxxxxx
samld_send_common_reply [118]:     Attr: 10, 40, 'username' 'simone.zabberoni@gmail.com'
samld_send_common_reply [118]:     Attr: 10, 19, 'group' 'Everyone'
samld_send_common_reply [118]:     Attr: 10, 23, 'group' 'SSLVPN group'  <- must match the group string into the FG configuration
samld_send_common_reply [122]:     Attr: 11, 566, https://trial-okta_stuff.okta.com?SAMLRequest=xxxxxxxxxxxxxxx
```

Watch out for `No group info in SAML response` and `SAML group mismatch`, fix up group assertion attributes



#### Okta sample

https://docs.fortinet.com/document/fortigate/7.4.4/administration-guide/499536/ssl-vpn-with-okta-as-saml-idp

```
config user saml
    edit "SAML OKTA TEST"
        set entity-id "https://your_firewall_here/remote/saml/metadata/"
        set single-sign-on-url "https://your_firewall_here/remote/saml/login"
        set single-logout-url "https://your_firewall_here/remote/saml/logout"
        set idp-entity-id "http://www.okta.com/okta_id"
        set idp-single-sign-on-url "https://trial-okta_stuff.okta.com/app/trial-okta_stuff_okta_app_here/okta_id/sso/saml"
        set idp-single-logout-url "https://trial-okta_stuff.okta.com"
        set idp-cert "REMOTE_Cert_1"
        set user-name "username"
        set group-name "group"
        set digest-method sha1
    next
```

#### Azure sample

```
config user saml
    edit "azure"
        set cert "Fortinet_CA_SSL"
        set entity-id "https://192.168.2.99:8443/remote/saml/metadata"
        set single-sign-on-url "https://192.168.2.99:8443/remote/saml/login"
        set single-logout-url "https://192.168.2.99:8443/remote/saml/login"
        set idp-entity-id "https://sts.windows.net/SOME_ID/"
        set idp-single-sign-on-url "https://login.microsoftonline.com/SOME_ID/saml2"
        set idp-single-logout-url "https://login.microsoftonline.com/SOME_ID/saml2"
        set idp-cert "REMOTE_Cert_1"
        set user-name "username"
        set group-name "group"
        set digest-method sha1
    next
end
```
```
config user group
    edit "FortiGateAccess"
        set member "azure"
        config match
            edit 1
                set server-name "azure"
                set group-name "GROUP_ID_HERE"
            next
        end
    next
end
```


---

### Backup

#### System profile for RestAPI backup

Read/write settings for a RESTAPI admin capable of backing up the conf.
Note that `"set scope global"` seems to be configurable only via CLI (otherwise a FW with VDOM will respond 403 to the backup request)

```
configure system accprofile
    edit "RestAdminBck"
        set scope global
        set secfabgrp read
        set ftviewgrp read
        set authgrp read
        set sysgrp custom
        set netgrp read
        set loggrp read
        set fwgrp read
        set vpngrp read
        set utmgrp read
        set wanoptgrp read
        set wifi read
        config sysgrp-permission
            set admin read-write
            set upd read
            set cfg read
            set mnt read
        end
    next
end
```

#### Backup api

Create a rest admin with the RestAdminBck profile, save its token and use this string in a shell script (via curl or wget):
```
https://$FGFQDN:$Port/api/v2/monitor/system/config/backup?scope=global&access_token=$API_Key
```


#### SCP Backup
Create a dedicated backup admin with SSH Key authentication

https://community.fortinet.com/t5/FortiGate/Technical-Tip-How-to-authenticate-an-admin-user-to-FortiGate-via/ta-p/190221


Enable scp:
```
config system global set admin-scp enable end
```

Copy the conf:

```
scp your_backup_user@$ARG_HOST:fgt-config $ARG_FILE
```


#### RANCID backup - via ssh

Create a dedicate user (see above)

Check if your rancid setup "knows" Fortigate
```
grep  "fortigate::GetConf" /etc/rancid/rancid.types.base

fortigate;command;fortigate::GetConf;show
fortigate-full;command;fortigate::GetConf;show full-configuration
```

Sample router.db for Fortigate firewall:
```
cat router.db

1.2.3.4;fortigate-full;up
```

Sample .cloginrc for Fortigate firewall:
```
cat .cloginrc

add user 1.2.3.4 ScpBackup
add password 1.2.3.4 a_very_strong_password
add method 1.2.3.4 ssh
add identity  * /home/rancid/.ssh/id_rsa            <- better with keys!
```

Then use rancid-run or flogin.




---

### Fortiswitch

Note: -running, to be completed-


Tier2 switch configuration in a 3 tier MCLAG setup (configurazion of Tier2 switch 1)

```
show switch auto-isl-port-group

config switch auto-isl-port-group
    edit "tier3-rackA-sw1"
            set members "port1"
    next
    edit "tier3-rackB-sw1"
            set members "port2"
    next
    edit "tier3-rackC-sw1"
            set members "port3"
    next
end
```

```
show switch trunk
config switch trunk
    edit "SerialNumberOfTier2Switch-1"              <- to Tier2 partner
        set mode lacp-active
        set auto-isl 1
        set mclag-icl enable
            set members "port21" "port22"
    next
    edit "_FlInK1_MLAG0_"                           <- to tier1
        set mode lacp-active
        set auto-isl 1
        set mclag enable
            set members "port24"
    next
    edit "tier3-rackA-sw1"
        set mode lacp-active
        set auto-isl 1
        set mclag enable
            set members "port1"
    next
    edit "tier3-rackA-sw1"
        set mode lacp-active
        set auto-isl 1
        set mclag enable
            set members "port2"
    next
    edit "tier3-rackA-sw1"
        set mode lacp-active
        set auto-isl 1
        set mclag enable
            set members "port3"
    next
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


#### Show ip address

```
diagnose ip address list
IP=192.168.1.80->192.168.1.80/255.255.255.0 index=5 devname=wan1
IP=10.10.10.1->10.10.10.1/255.255.255.0 index=7 devname=dmz
IP=127.0.0.1->127.0.0.1/255.0.0.0 index=24 devname=root
IP=192.168.1.99->192.168.1.99/255.255.255.0 index=28 devname=lan
IP=10.255.1.1->10.255.1.1/255.255.255.0 index=29 devname=fortilink
IP=127.0.0.1->127.0.0.1/255.0.0.0 index=30 devname=vsys_ha
IP=127.0.0.1->127.0.0.1/255.0.0.0 index=32 devname=vsys_fgfm
IP=127.0.0.1->127.0.0.1/255.0.0.0 index=33 devname=vsys_if#0
```

#### High availability

Status:
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


HA access secondary - https://community.fortinet.com/t5/FortiGate/Technical-Tip-How-to-access-secondary-unit-of-HA-cluster-via-CLI/ta-p/198142
```
execute ha manage 0
```

Force failover:
```
diagnose sys ha reset-uptime
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

Full database (including IPSEC static auto add with distance 15 - reference bug 833399 in 7.2.2 and 7.2.3)
Example with 2 default routes and 2 ipsec with selector 0.0.0.0/0 - with the bug!

```
get router info routing-table database 

Codes: K - kernel, C - connected, S - static, R - RIP, B - BGP
       O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, L1 - IS-IS level-1, L2 - IS-IS level-2, ia - IS-IS inter area
       V - BGP VPNv4
       > - selected route, * - FIB route, p - stale info

Routing table for VRF=0
S       0.0.0.0/0 [15/0] via some_IPSEC_A tunnel 1.2.3.4, [1/0]
                  [15/0] via some_IPSEC_B tunnel 6.7.8.9, [1/0]
S    *> 0.0.0.0/0 [10/0] via a.a.a.a, port1, [200/0]
     *>           [10/0] via b.b.b.b, port2, [201/0]
```

Routing decision for a specific destination (also in this case, with the 833399 bug):
```
get router info routing-table details 8.8.8.8

Routing table for VRF=0
Routing entry for 0.0.0.0/0
  Known via "static", distance 15, metric 0
    via some_IPSEC_A tunnel 1.2.3.4 vrf 0
    via some_IPSEC_B tunnel 6.7.8.9 vrf 0

Routing entry for 0.0.0.0/0
  Known via "static", distance 10, metric 0, best
  * vrf 0 a.a.a.a, via port1
  * vrf 0 b.b.b.b, via port2
```

Routes added by ipsec:
```
diagnose vpn ike routes list
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

#### Fortiswitch debug stuff
To view the MSTP configuration details, use the following commands:

```
get switch stp instance
get switch stp settings
```
 

Use the following commands to display information about the MSTP instances in the network:
```
diagnose stp instance list
diagnose stp vlan list
diagnose stp mst-config list
```

Trunks
```
diagnose switch trunk list
```

MCLAG debug:
```
diagnose switch mclag peer-consistency-check
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

---

# FortiAP

Console usually at 9600, sometimes at 115200

```
putty -serial com10 -sercfg 115200,8,n,1,N
```

## FortiAP config and diag
https://docs.fortinet.com/document/fortiap/7.4.2/fortiwifi-and-fortiap-configuration-guide/65088/fortiap-cli-configuration-and-diagnostics-commands

```
FortiAP-231F # cfg -s
BAUD_RATE:=9600
WTP_NAME:=
WTP_LOCATION:=
FIRMWARE_UPGRADE:=0
FACTORY_RESET:=0
LOGIN_PASSWD_ENC:=cdscdscds--
ADMIN_TIMEOUT:=5
WANLAN_MODE:=WAN-ONLY
AP_MODE:=0
STP_MODE:=0
AP_MGMT_VLAN_ID:=0
ADDR_MODE:=STATIC
AP_IPADDR:=10.32.9.84
AP_NETMASK:=255.255.255.0
IPGW:=10.32.9.199
DNS_SERVER:=10.32.9.199
ALLOW_HTTPS:=2
ALLOW_SSH:=2
AC_DISCOVERY_TYPE:=0
AC_IPADDR_1:=192.168.1.1
AC_IPADDR_2:=
AC_IPADDR_3:=
AC_HOSTNAME_1:=_capwap-control._udp.example.com
AC_HOSTNAME_2:=
AC_HOSTNAME_3:=
AC_DISCOVERY_MC_ADDR:=224.0.1.140
AC_DISCOVERY_DHCP_OPTION_CODE:=138
AC_DISCOVERY_FCLD_APCTRL:=
AC_DISCOVERY_FCLD_ID:=
AC_DISCOVERY_FCLD_PASSWD_ENC:=
AC_CTL_PORT:=5246
AP_DATA_CHAN_SEC:=clear,dtls,ipsec
BONJOUR_GW:=2
MESH_AP_TYPE:=0
LED_STATE:=2
POE_MODE:=0
```

## FortiAP NAC Stuff

JSON NAC objects for policies: https://filestore.fortinet.com/product-downloads/fortilink/HTFO_list.json

Wireless nac support: https://docs.fortinet.com/document/fortigate/7.0.0/new-features/806701/wireless-nac-support

Example NAC to block mobile: https://community.fortinet.com/t5/FortiGate/Technical-Tip-Usage-of-NAC-Policies-to-block-traffic-from-Mobile/ta-p/282238

Example NAC Detect Huawei: https://community.fortinet.com/t5/Support-Forum/Detecting-Huawei-devices/m-p/6701

Example NAC policies for WLAN: https://community.fortinet.com/t5/FortiAP/Technical-Tip-How-to-configure-NAC-Policies-for-WLAN/ta-p/267603


## FortiAP OWE open wireless with encryption - captive portal with transition 
https://docs.fortinet.com/document/fortiap/7.4.4/fortiwifi-and-fortiap-configuration-guide/233803/wpa3-security

*Note: FortiOS 7.4.4 needed!*

*Note: CLI only*


Configure both OPEN and OWE wlans (owe->no broadcast) with captive portal 

Set owe-transition on both wlans: newer devices will transition to OWE, older will stay on OPEN

**Anomaly: very very important!**

FortiOS shows the `set captive-portal enable` directive last, AFTER the `set selected-usergroups "Guest-Group"`

But `selected-usergroups` isn't available if you aren't in captive portal mode... you need to `set captive-portal enable` first!


```
show wireless-controller vap
    edit "Guest-OPEN"
        set ssid "Guest-OPEN"
        set security open
        set 80211k disable
        set 80211v disable
        set owe-transition enable
        set owe-transition-ssid "Guest-OWE"
        set selected-usergroups "Guest-Group"
        set intra-vap-privacy enable
        set schedule "always"
        set captive-portal enable               <- paste this BEFORE set selected-usergroups !!
    next
    edit "Guest-OWE"
        set ssid "Guest-OWE"
        set broadcast-ssid disable
        set security owe
        set pmf enable
        set 80211k disable
        set 80211v disable
        set owe-transition enable
        set owe-transition-ssid "Guest-OPEN"
        set selected-usergroups "Guest-Group"
        set intra-vap-privacy enable
        set schedule "always"
        set captive-portal enable               <- paste this BEFORE set selected-usergroups !!
    next
end
```

Use the firewall as dhcp + dns with forwarding (otherwise captive won't work):
```
config system dhcp server
    edit XXX
        set dns-service local
        set default-gateway 192.168.100.254
        set netmask 255.255.255.0
        set interface "Guest-OPEN"
        config ip-range
            edit 1
                set start-ip 192.168.100.2
                set end-ip 192.168.100.250
            next
        end
    next
    edit XXX
        set dns-service local
        set default-gateway 192.168.101.254
        set netmask 255.255.255.0
        set interface "Guest-OWE"
        config ip-range
            edit 1
                set start-ip 192.168.101.2
                set end-ip 192.168.101.250
            next
        end
    next
end
```
```
config system dns-server
    edit "Guest-OPEN"
        set mode forward-only
    next
    edit "Guest-OWE"
        set mode forward-only
    next
end
```

Some simple policies:
```
config firewall policy
    edit 0
        set srcintf "Guest-OPEN"
        set dstintf "wan1"
        set action accept
        set srcaddr "Net-Guest-OPEN"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set ssl-ssh-profile "certificate-inspection"
        set logtraffic all
    next

	edit 0
        set srcintf "Guest-OWE"
        set dstintf "wan1"
        set action accept
        set srcaddr "Net-Guest-OWE"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set ssl-ssh-profile "certificate-inspection"
        set logtraffic all
    next
end
```

## FortiAP management - remote site through ipsec tunnel

It doesn't make sense, but enable Fabric connection on the ipsec interface as well as the real interface:


https://www.reddit.com/r/fortinet/comments/ng720j/remote_ipsec_vpn_site_fortiap_wont_connect_to/

>Our FortiGate has local CAPWAP VLAN interface. Local FortiAPs connect without any issue using L2. Remote FortiAPs receive IP address of CAPWAP VLAN interface via local DHCP Option 138. They connect through IPsec tunnel without any problem. They can be seen in the Managed FortiAPs grid as Unauthorized. Once authorized they are shown as Offline = same behaviour as yours.

> We have found that not only target CAPWAP VLAN interface has to have Security Fabric Connection enabled in Administrative Access, but this setting has to be enabled for IPsec interface too! For me it is not understandable (as the IPsec interface is not target interface, just forwarding interface), but we have verified it by trial and error method.


## FortiAP CAPWAP debug

https://community.fortinet.com/t5/FortiGate/Troubleshooting-Tip-Managed-FortiAP-Issues/ta-p/207852

Dump UDP/5246 packets
```
diag sniff packet portX “arp or udp port 5246 or udp port 67” 6 0
```

Diagnose log - almost unreadable:

```
diagnose debug reset
diag debug console timestamp enable
diag debug application cw_acd 0x7f
diag debug enable
```




## Guest with user limit

To limit guest voucher usage, for example to 2 concurrent session with the same users (ie: laptop and mobile)

```
config user group
    edit "your_guest_group"
        set auth-concurrent-override enable
        set auth-concurrent-value 2
    next
end
```     

## FortiAP channels, mhz and potential bandwidth issues

https://docs.fortinet.com/document/fortiap/7.0.0/secure-wireless-concept-guide/15862/channels-and-channel-planning


 For example, in a large conference room or auditorium, a single FortiAP can easily cover the room, but it cannot have 1000 devices connected to it. 20 MHz channels allow you to throw more APs at the capacity problem until you run out of channels. On the other hand, an office with 5 FortiAPs and a dozen devices each could consider 80 MHz wide channels.


 
