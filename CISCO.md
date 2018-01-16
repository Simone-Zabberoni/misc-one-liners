# ASA, CUCM, switch and router useful commands

Of course, all configuration commands must be entered afert a `conf term`


## Router DNS and NTP setup

```
ip domain-name mydomain.org
ip name-server 1.1.1.1
ip name-server 1.1.1.2

clock timezone CET +1
ntp server pool.ntp.org
```


## Default gw

Either one or the other:
```
ip default-gateway 1.1.1.1
ip route 0.0.0.0 0.0.0.0 1.1.1.1
```


## Local flash, tftp single and multiple file transfer 

List the whole html directory of a switch:

```
TEST#dir html
Directory of flash:/html/

    8  -rwx        3994   Mar 01 1993 00:03:19  homepage.htm
    9  -rwx        1392   Mar 01 1993 00:03:20  not_supported.html
   10  -rwx        9529   Mar 01 1993 00:03:20  common.js
   11  -rwx       22152   Mar 01 1993 00:03:20  cms_splash.gif
[...]
```

Available commands for flash management: `more`, `mkdir`, `rename`, `delete`

With the `archive` command we can transfer multiple files to a remote tftp server, creating a single .tar file

```
TEST#archive tar /create tftp://192.168.1.230/my_archive.tar flash:html
[...]
archiving redirect.htm (1018 bytes)
archiving sslhome.shtml (6143 bytes)!
archiving appsui.js (1389 bytes)!
archiving stylesheet.css (8273 bytes)!
[...]
```

Retrieve it and unpack it on the fly:

```
AnotherSwitch#archive tar /xtract tftp://192.168.1.230/my_archive.tar html
Loading my_archive.tar from 192.168.1.230 (via Vlan1): !
extracting redirect.htm (1018 bytes)
extracting sslhome.shtml (6143 bytes)!
extracting appsui.js (1389 bytes)!
[...]
```

Use `copy` for single files:

```
copy tftp://192.168.1.230/c2950-i6q4l2-mz.121-22.EA4a.bin flash:
Destination filename [c2950-i6q4l2-mz.121-22.EA4a.bin]?
Accessing tftp://192.168.1.230/c2950-i6q4l2-mz.121-22.EA4a.bin...
[...]
```


## CUCM - Call Manager

Create a phone number entry and bind it to a phone by mac address and model:

```
conf t

voice register dn  66
 number 1234
 allow watch
 name My Test Phone
 label My Test Phone
 mwi

voice register pool  66
 busy-trigger-per-button 2
 id mac ABCD.ABCD.ABCD
 type 7821
 number 1 dn 66
 template 1
 dtmf-relay rtp-nte
 username someuser password somepassword
 codec g711alaw
```

After that, we need to rebuild the configuration files which will be served via tftp:

```
voice register global
 create profile
```
This could take a while, then to check the MAC to config file mapping:

```
show voice register tftp-bind
[...]
tftp-server url flash:/its/SEPABCDABCDABCD.cnf.xml alias SEPSEPABCDABCDABCD.cnf.xml
[...]
```

Enable "term shell" to print the content of the file:
```
term shell
cat its/SEPABCDABCDABCD.cnf.xml
<device>
<fullConfig>true</fullConfig>
<deviceProtocol>SIP</deviceProtocol>
<devicePool>
<dateTimeSetting>
<dateTemplate>D/M/Y</dateTemplate>
<timeZone>E. Europe Standard/Daylight Time</timeZone>
```



## ASA ACLs

Show interface <-> ACL binding:
```
myAsaFw# show running-config access-group
access-group Server_access_in in interface Server
access-group Outside_access_in in interface Outside
access-group Mgmt_access_in in interface Mgmt
access-group Client_access_in in interface Client
```

Show a specific configured ACL:
```
myAsaFw# show running-config access-list Mgmt_access_in
access-list Mgmt_access_in extended permit ip object MY_LOCAL_NETWORK any
access-list Mgmt_access_in extended permit icmp any any
```

Show the ACL hit count and details:
```
myAsaFw# show access-list Mgmt_access_in
access-list Mgmt_access_in; 2 elements; name hash: 0x558eed49
access-list Mgmt_access_in line 1 extended permit ip object MY_LOCAL_NETWORK any (hitcnt=56937) 0xae44bd16
  access-list Mgmt_access_in line 1 extended permit ip 10.10.10.0 255.255.255.0 any (hitcnt=56937) 0xae44bd16
access-list Mgmt_access_in line 2 extended permit icmp any any (hitcnt=0) 0xf304e575
```

## ASA VPNs

Show crypto settings:

```
myAsaFw# show running-config crypto
crypto ipsec ikev1 transform-set ESP-3DES-MD5 esp-3des esp-md5-hmac

crypto map outside_map 20 match address outside_cryptomap_1
crypto map outside_map 20 set peer 1.2.3.4
crypto map outside_map 20 set ikev1 transform-set ESP-3DES-MD5
crypto map outside_map 20 set nat-t-disable
crypto map outside_map interface Outside

crypto ikev1 enable Outside

crypto ikev1 policy 10
 authentication pre-share
 encryption des
 hash md5
 group 2
 lifetime 86400
crypto ikev1 policy 20
 authentication pre-share
 encryption des
 hash sha
 group 2
 lifetime 86400
```

In detail:
 * `crypto ipsec ikev1 transform-set` : creates a transform set for encryption, referenced in the crypto map (phase 2)
 * `crypto map` : glue toghether all the vpn settings:
    * `outside_map` : crypto map name
    * `20` : sequence ID, must be different for each VPN tunnel bound to the same map
    * `match address outside_cryptomap_1` : ACL for VPN traffic match (LOCAL_NET <-> REMOTE_NET)
    * `set peer 1.2.3.4` : remote VPN server
    * `set ikev1 transform-set` : reference the correct transport set
    * `set nat-t-disable` : disable NAT traversal (4500/UDP encapsulation), force 500/UDP and protocol 50
    * `interface Outside` : binds the crypto map to a specific interface
 * `crypto ikev1 enable Outside` : enable ikev1 on the specified interface (see nameif in `show running interfaces`)
 * `crypto ikev1 policy` : list of phase 1 policies which will be proposed during IKE

Show the VPN Acl:
```
myAsaFw# show running-config access-list outside_cryptomap_1
access-list outside_cryptomap_1 extended permit ip object MY_LOCAL_NETWORK object-group REMOTE_NETWORKS
```

Show group policy and tunnel group config:

```
myAsaFw# show running-config group-policy
group-policy GroupPolicy_1.2.3.4 internal
group-policy GroupPolicy_1.2.3.4 attributes
 my-vpn-acl-protocol ikev1

myAsaFw# show running-config tunnel-group
tunnel-group 1.2.3.4 type ipsec-l2l
tunnel-group 1.2.3.4 general-attributes
 default-group-policy GroupPolicy_1.2.3.4
tunnel-group 1.2.3.4 ipsec-attributes
 ikev1 pre-shared-key SomeStrongPSK
 isakmp keepalive disable
```

The tunnel group name is set to the remote peer ip address.
When negotiating a L2L each peer sends its ISAKMP identity to the remote  peer. It sends either its IP address or host name dependent upon how  each has its ISAKMP identity set.
By default, the ISAKMP identity of the ASA is set to the IP address.


## ASA SSH

Create a user and configure local authentication:

```
username my_user password xxxxxxxxxxxxx encrypted privilege 15
aaa authentication ssh console LOCAL
```

Create keys, enable ssh and enable ssh access on Internal interface only from the specified network:

```
crypto key generate rsa general-keys modulus 2048
ssh scopy enable
ssh 10.0.0.0 255.0.0.0 Internal
```


## IOS XE

### SSH on non-standard port

```
ip ssh port 8443 rotary 1
line vty 0 15
 rotary 1
```


### IpSec VPN using HSRP for resiliency

Let's consider 2 router, with ip address 1.1.1.1 and 1.1.1.2 with HSRP ip 1.1.1.3, internal network 192.168.1.0/24
Remote peer's ip address is 1.2.3.4, internal network 192.168.2.0/24

Set the preshared key and the transform set:
```
crypto isakmp key my_preshared_key address 1.2.3.4

crypto ipsec transform-set my-vpn-transformset esp-aes 256 esp-sha-hmac
 mode transport
```


Create the vpn access list matching the local and the remote network:
```
ip access-list extended my-vpn-acl
 permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255 
```

Create crypto map to bind peer-acl-transformset:
```
crypto map my-crypto-map 1 ipsec-isakmp
 set peer 1.2.3.4
 set transform-set my-vpn-transformset
 match address my-vpn-acl
```

**Important**: don't apply NAT on vpn packets:
```
ip access-list extended NAT_INSIDE_NETWORKS
 deny   ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255 
 permit ip 192.168.1.0 0.0.0.255 any

ip nat inside source list NAT_INSIDE_NETWORKS interface GigabitEthernet0/0/0 overload
```

Bind the crypto map to the WAN interface, using the HSRP ip address:

```
interface GigabitEthernet0/0/0
 description WAN
 ip address 1.1.1.1 255.255.255.248
 ip nat outside
 standby delay minimum 30 reload 60
 standby 0 ip 1.1.1.3
 standby 0 priority 110
 standby 0 preempt
 standby 0 name WAN-HSRP
 negotiation auto
 crypto map my-crypto-map redundancy WAN-HSRP
```


### Snmp with simple ACL

Allow snmp RO access only from a specific network or host:

```
access-list 99 permit 192.168.1.0 0.0.0.255
snmp-server community public RO 99
```

