# ASA, CUCM, switch and router useful commands

Of course, all configuration commands must be entered afert a `conf term`

## Router DNS

Enable ip domain lookup, domain name search and dns servers

```
ip domain lookup
ip domain-name mydomain.org
ip name-server 1.1.1.1
ip name-server 1.1.1.2
```

## NTP setup

Setup timezone, summer time and ntp server

```
clock timezone CET +1
clock summer-time CET recurring last Sun Mar 2:00 last Sun Oct 3:00
ntp server pool.ntp.org
```

Check the current time:

```
my_router# show clock
09:31:16.613 CET Wed Oct 24 2018
```

## Default gw

On a layer2 device:

```
ip default-gateway 1.1.1.1
```

On a layer3 device with ip routing enabled:

```
ip route 0.0.0.0 0.0.0.0 1.1.1.1
```

## Switch and SFP / GBIC informations

```
SomeSwitch# show inventory
NAME: "1", DESCR: "IE-3010-16S-8PC"
PID: IE-3010-16S-8PC   , VID: V02  , SN: xxxxxxxxx

NAME: "Power Supply 1", DESCR: "FRU Power Supply"
PID: PWR-RGD-AC-DC     , VID: V02  , SN: xxxxxxxxx

NAME: "GigabitEthernet0/1", DESCR: "1000BaseSX SFP"
PID: GLC-SX-MM-RGD       , VID: V02  , SN: xxxxxxxxx

NAME: "FastEthernet0/1", DESCR: "100BaseFX-FE SFP"
PID: GLC-FE-100FX        , VID: V02  , SN: xxxxxxxxx
```

## Vlan interfaces

**Important** : all VLAN interfaces other than the default are in shutdown state when created

```
interface Vlan1
 ip address 10.10.1.1 255.255.255.0
!
interface Vlan10
 ip address 10.10.10.1 255.255.255.0
 no shutdown
!
interface Vlan20
 ip address 10.10.20.1 255.255.255.0
 no shutdown
```

## Telnet/SSH authentication with local accounts

Create the account:

```
username myAdmin privilege 15 password 0 somePassword
```

Bind the VTYs to the local accounting:

```
line vty 0 4
 login local
line vty 5 15
 login local
```

## Full access port sample - access vlan with portfast and voice vlan

```
interface FastEthernet0/2
 switchport access vlan 22
 switchport mode access
 switchport voice vlan 21
 spanning-tree portfast
 spanning-tree bpduguard enable
!
```

## DHCP Setup

**Important** : configure a VLAN interface with a matching ip address to enable the scope!

```
ip dhcp excluded-address 10.10.0.1 10.10.0.20
ip dhcp excluded-address 10.10.20.1 10.10.20.20
ip dhcp excluded-address 10.10.30.1 10.10.30.20
!
ip dhcp pool 0-dhcp
 network 10.10.0.0 255.255.255.0
 default-router 10.10.0.10
 dns-server 8.8.8.8
!
ip dhcp pool 20-dhcp
 network 10.10.20.0 255.255.255.0
 default-router 10.10.20.10
 dns-server 8.8.8.8
!
ip dhcp pool 30-dhcp
 network 10.10.30.0 255.255.255.0
 default-router 10.10.30.10
 dns-server 8.8.8.8
```

## Spanning tree stuff

STP engine

```
spanning-tree mode { pvst | mst | rapid-pvst }
```

Root and priority

```
spanning-tree vlan 1-4094 root  primary
spanning-tree vlan 1-4094 priority 4096
```

Show

```
show spanning-tree summary
show spanning-tree interface interface-id
```

Disable on specific vlan

```
no spanning-tree vlan 1
```

Portfast - use on access port pnly

```
interface FastEthernet0/1
 spanning-tree portfast
```

## LACP

Configure an access port:

```
Switch(config)# interface range gigabitethernet0/1 -2
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
Switch(config-if-range)# channel-group 5 mode active
Switch(config-if-range)# end
```

Configure a trunk port

```
Switch(config)# interface range gigabitethernet0/1 -2
Switch(config-if-range)# switchport mode trunk
Switch(config-if-range)# channel-group 10 mode active
Switch(config-if-range)# end


interface Port-channel10
 switchport mode trunk

```

Balancing engine:

```
port-channel load-balance { dst-ip | dst-mac | src-dst-ip | src-dst-mac | src-ip | src-mac }
```

Status

```
show etherchannel [ channel-group-number { detail | port | port-channel | protocol | summary }] { detail | load-balance | port | port-channel | protocol | summary }

show lacp [channel-group-number] {counters | internal | neighbor}
```

## GBIC compatibiliy bypass - warranty breaker!

Using old/unsupported/chinese GBICs could yeald:

```
%PLATFORM_PM-6-MODULE_ERRDISABLE: The inserted SFP module with interface name Gix/y/z is not supported
%PM-4-ERR_DISABLE: gbic-invalid error detected on Gix/y/z, putting Gix/y/z in err-disable state
```

Use the hidden command to bypass the check, but also voids any support/maintenance

```
service unsupported-transceiver
no errdisable detect cause gbic-invalid
no errdisable detect cause all
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

## Update image

Use the already mentioned `archive` command:

```
archive download-sw  /overwrite /reload tftp://1.2.3.4/c2960-lanbasek9-tar.150-2.SE11.tar
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

- `crypto ipsec ikev1 transform-set` : creates a transform set for encryption, referenced in the crypto map (phase 2)
- `crypto map` : glue toghether all the vpn settings:
  - `outside_map` : crypto map name
  - `20` : sequence ID, must be different for each VPN tunnel bound to the same map
  - `match address outside_cryptomap_1` : ACL for VPN traffic match (LOCAL_NET <-> REMOTE_NET)
  - `set peer 1.2.3.4` : remote VPN server
  - `set ikev1 transform-set` : reference the correct transport set
  - `set nat-t-disable` : disable NAT traversal (4500/UDP encapsulation), force 500/UDP and protocol 50
  - `interface Outside` : binds the crypto map to a specific interface
- `crypto ikev1 enable Outside` : enable ikev1 on the specified interface (see nameif in `show running interfaces`)
- `crypto ikev1 policy` : list of phase 1 policies which will be proposed during IKE

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
When negotiating a L2L each peer sends its ISAKMP identity to the remote peer. It sends either its IP address or host name dependent upon how each has its ISAKMP identity set.
By default, the ISAKMP identity of the ASA is set to the IP address.

## ASA VPN DEBUG
```
debug crypto isakmp
debug crypto ipsec
debug crypto condition peer 1.2.3.4

show crypto ipsec sa peer 1.2.3.4
```


## ASA Packet capture
```
cap capin interface inside match ip 192.168.1.3 255.255.255.255 any
show cap capin
```

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

## ASA DHCPRELAY

Setup dhcp relay and interface bindings:
```
dhcprelay server 1.2.3.4 someinterface
dhcprelay enable inside
dhcprelay enable anotherinterface
dhcprelay timeout 60
```

## ASA Radius server

Multiple radius servers for a single service:
```
aaa-server SOME-NAME (someinterface) host 1.2.3.10
 key astrongpassword
exit

aaa-server SOME-NAME (someinterface) host 1.2.3.11
 key anotherstrongpassword
exit

```


## ASA SSL Certificate for SSL VPN

Prepare the password protected PFX from key, certificate and intermediate:

```
openssl pkcs12 -export -out mydomain.pfx -inkey mydomain.key -in mydomain.crt -certfile intermediate.pem
password: 123123

```

Convert the binary pfx into base64:

```
openssl base64 -in mydomain.pfx

```

Paste the output between the headers (ASA expects them!):

```
-----BEGIN PKCS12-----
[paste base64 pfx here]
-----END PKCS12----
```

On the ASA, define a new trustpoint with a significative name: 

```
crypto ca trustpoint TRUSTPOINT-SSLVPN-2022
 fqdn sslvpn.mydomain.com
 validation-usage ssl-server
 crl configure
exit
enrollment terminal
exit

```

Enroll the certificate by providing the trustpoint name, the pkcs12 type and the import password, then paste the base64 encoded pfx:
```
crypto ca import TRUSTPOINT-SSLVPN-2022 pkcs12 123123
Enter the base 64 encoded pkcs12.
End with the word "quit" on a line by itself:
[paste here]
```

Activate the new trustpoint:

```
crypto ikev2 remote-access trustpoint TRUSTPOINT-SSLVPN-2022
ssl trust-point TRUSTPOINT-SSLVPN-2022 outside
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

## Cisco 9200/9300

### Recovery from usb after factory reset

From bios boot via USB:

```
switch: set BOOT=usbflash0:/cat9k_lite_iosxe.16.10.01.SPA.bin
switch: boot
boot: attempting to boot from [usbflash0:/cat9k_lite_iosxe.16.10.01.SPA.bin]
boot: reading file /cat9k_lite_iosxe.16.10.01.SPA.bin
##############################################################################################################
```

Copy the OS on flash and set it as boot image:

```
copy usbflash0:/cat9k_lite_iosxe.16.10.01.SPA.bin flash:

conf t
boot system flash:cat9k_lite_iosxe.16.10.01.SPA.bin
reload
```

## Cisco 887 VAG with SIM card


Check network:
```
Router#show cellular 0 network
Current Service Status = Normal, Service Error = None
Current Service = Combined
Packet Service = HSPA (Attached)
Packet Session Status = Inactive
Current Roaming Status = Home
Network Selection Mode = Manual
Country = ITA, Network = TIM
Mobile Country Code (MCC) = 222
Mobile Network Code (MNC) = 1
Location Area Code (LAC) = 61448
Routing Area Code (RAC) = 0
Cell ID = xxxxx
Primary Scrambling Code = xxx
PLMN Selection = Manual
Registered PLMN = I TIM , Abbreviated = TIM
Service Provider =
```

Check for unlocked sim:
```
show cellular 0 security
Active SIM = 0
SIM switchover attempts = 0
Card Holder Verification (CHV1) = Disabled
SIM Status = OK
SIM User Operation Required = None
Number of CHV1 Retries remaining = 3
```

Check profile:
```
Router#show cellular 0 profile 1
Profile 1 = INACTIVE*
--------
PDP Type = IPv4
Access Point Name (APN) = a_wrong_apn
Authentication = PAP
Username: a_wrong_username, Password: some_pass

 * - Default profile
```

Set the correct apn to the profile (example for TIM):
```
cellular 0 gsm profile create 1 ibox.tim.it
Profile 1 already exists. Do you want to overwrite? [confirm]
Profile 1 will be overwritten with the following values:
PDP type = IPv4
APN = ibox.tim.it
Are you sure? [confirm]
Profile 1 written to modem
```


Minimal configuration:

```
chat-script hspa-R7 "" "AT!SCACT=1,1" TIMEOUT 60 "OK"

interface Cellular0
 ip address negotiated
 no ip redirects
 no ip unreachables
 no ip proxy-arp
 no ip mfib forwarding input
 no ip mfib forwarding output
 no ip mfib cef input
 no ip mfib cef output
 ip nat outside
 ip virtual-reassembly in
 encapsulation slip
 no ip route-cache
 dialer in-band
 dialer string hspa-R7
 dialer-group 1
 async mode interactive
!

interface Vlan1
 ip address 192.168.1.1 255.255.255.0
 ip nat inside

ip nat inside source list ACL_NAT interface Cellular0 overload
ip route 0.0.0.0 0.0.0.0 Cellular0
!
ip access-list extended ACL_NAT
 permit ip 192.168.0.0 0.0.0.255 any

dialer-list 1 protocol ip permit

line 3
 script dialer hspa-R7
 modem InOut
 no exec
 transport output none
```

Debug connection:
```
debug dialer events
Dial on demand events debugging is on

terminal monitor
% Console already monitors

ping 8.8.8.8
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 8.8.8.8, timeout is 2 seconds:

Apr 16 13:00:49.995: Ce0 DDR: place call
Apr 16 13:00:49.995: Ce0 DDR: Dialing cause ip (s=192.168.1.1, d=8.8.8.8)
Apr 16 13:00:49.995: Ce0 DDR: Attempting to dial hspa-R7
Apr 16 13:00:49.995: CHAT3: Attempting async line dialer script
Apr 16 13:00:49.995: CHAT3: Dialing using Modem script: hspa-R7 & System script: none
Apr 16 13:00:49.995: CHAT3: process started
Apr 16 13:00:49.995: CHAT3: Asserting DTR
Apr 16 13:00:49.995: CHAT3: Chat script hspa-R7 started.
Apr 16 13:00:51.531: CHAT3: Chat script hspa-R7 finished, status = Success
Apr 16 13:00:53.531: %LINK-3-UPDOWN: Interface Cellular0, changed state to up.
Apr 16 13:00:53.531: Ce0 DDR: Dialer statechange to up
Apr 16 13:00:53.531: Ce0 DDR: Dialer call has been placed
Apr 16 13:00:53.531: Ce0 DDR: dialer protocol up
Apr 16 13:00:54.531: %LINEPROTO-5-UPDOWN: Line protocol on Interface Cellular0, changed state to up!!!

Success rate is 60 percent (3/5), round-trip min/avg/max = 40/406/1132 ms
```

---


## Firepower

### Packet capture

```
capture testcap interface outside match ip 1.2.3.4 255.255.255.255 any
show capture testcap
```

## SG300 / 500 line - slighlty different syntax....

### Portchannel/LACP - switchport mode trunk is default

```
SG300#show running-config interface Port-Channel 1
interface Port-channel1
 description test97
 macro description no_switch
 switchport trunk allowed vlan add 2-16,18,22
 no macro auto smartport
!
SG300#show running-config interface GigabitEthernet 19
interface gigabitethernet19
 description CoreNode1
 channel-group 1 mode auto
 macro description no_switch
 no macro auto smartport
!
SG300#show running-config interface GigabitEthernet 20
interface gigabitethernet20
 description CoreNode2
 channel-group 1 mode auto
 macro description no_switch
 no macro auto smartport
!
```
