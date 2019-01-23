# Sophos XG Firewall - Device Console


## Tcpdump

XG supports the standard tcpdump syntax, but the options need to be enclosed in single quotes.

Dump on all interfaces:

```
console> tcpdump '-i any host 10.1.1.10 and icmp'
tcpdump: Starting Packet Dump

11:15:40.963436 Port1, IN: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 452, length 40
11:15:43.332936 Port8, OUT: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 452, length 40
11:15:40.963436 Port1, IN: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 453, length 40
11:15:43.332936 Port8, OUT: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 453, length 40
[...]
```

Single interface (Port) tcpdump:

```
console> tcpdump '-i Port1 host 10.1.1.10 and icmp'
tcpdump: Starting Packet Dump

11:15:40.963436 Port1, IN: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 1, length 40
11:15:40.963436 Port1, IN: IP 10.1.1.10 > 192.168.1.1: ICMP echo request, id 1, seq 2, length 40
[...]
```



## Packet drop reason

To debug why a packet is being dropped by the firewall, use `drop-packet-capture` with tcpdump syntax:

```
Console> drop-packet-capture 'host 10.1.1.10'

2017-06-23 13:01:26 0101021 IP  10.1.1.10 > 192.168.1.1. :proto ICMP: echo request seq 1721
0x0000:  4500 003c 7c48 0000 7e01 f1aa 0a03 030a  E..<|H..~.......
0x0010:  c0a8 0119 0800 46a2 0001 06b9 6162 6364  ......F.....abcd
0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374  efghijklmnopqrst
0x0030:  7576 7761 6263 6465 6667 6869            uvwabcdefghi

Date=2017-06-23 Time=13:01:26 log_id=0101021 log_type=Firewall log_component=Firewall_Rule log_subtype=Denied log_status=N/A log_priority=Alert duration=N/A in_dev=Port1 out_dev=Port6 inzone_id=1 outzone_id=2 source_mac=xx:xx:xx:xx:xx:xx dest_mac=yy:yy:yy:yy:yy:yy l3_protocol=IP source_ip=10.1.1.10 dest_ip=192.168.1.1 l4_protocol=ICMP icmp_type=8 icmp_code=0 fw_rule_id=27 policytype=0 live_userid=0 userid=0 user_gp=0 ips_id=0 sslvpn_id=0 web_filter_id=0 hotspot_id=0 hotspotuser_id=0 hb_src=0 hb_dst=0 dnat_done=0 proxy_flags=0 icap_id=0 app_filter_id=0 app_category_id=0 app_id=0 category_id=0 bandwidth_id=0 up_classid=0 dn_classid=0 source_nat_id=0 cluster_node=0 inmark=0x0 nfqueue=0 scanflags=0 gateway_offset=0 max_session_bytes=0 drop_fix=0 ctflags=0 connid=682641856 masterid=0 status=256 state=0 sent_pkts=N/A recv_pkts=N/A sent_bytes=N/A recv_bytes=N/A tran_src_ip=N/A tran_src_port=N/A tran_dst_ip=N/A tran_dst_port=N/A
```


## Ping with a specific source ip

Useful to ping across the VPN directly from XG:

```
console> ping sourceip 10.1.1.254 192.168.1.1
PING 192.168.1.1 (192.168.1.1) from 10.1.1.254: 56 data bytes
64 bytes from 192.168.1.1: seq=0 ttl=255 time=16.034 ms
64 bytes from 192.168.1.1: seq=1 ttl=255 time=15.452 ms
```


## VPN Status

The equivalent of `ipsec auto --status` on a linux machine:

```
console> show vpn connection status
interface lo/lo ::1
interface Port8/Port8 1.1.1.1
%myid = (none)
debug none

algorithm ESP encrypt: id=2, name=ESP_DES, ivlen=8, keysizemin=64, keysizemax=64
algorithm ESP encrypt: id=3, name=ESP_3DES, ivlen=8, keysizemin=192, keysizemax=192
algorithm ESP encrypt: id=6, name=ESP_CAST, ivlen=8, keysizemin=40, keysizemax=128
algorithm ESP encrypt: id=7, name=ESP_BLOWFISH, ivlen=8, keysizemin=40, keysizemax=448
algorithm ESP encrypt: id=11, name=ESP_NULL, ivlen=0, keysizemin=0, keysizemax=0
algorithm ESP encrypt: id=12, name=ESP_AES, ivlen=8, keysizemin=128, keysizemax=256
algorithm ESP encrypt: id=13, name=(null), ivlen=8, keysizemin=160, keysizemax=288
algorithm ESP encrypt: id=252, name=ESP_SERPENT, ivlen=8, keysizemin=128, keysizemax=256
algorithm ESP encrypt: id=253, name=ESP_TWOFISH, ivlen=8, keysizemin=128, keysizemax=256
algorithm ESP auth attr: id=1, name=AUTH_ALGORITHM_HMAC_MD5, keysizemin=128, keysizemax=128
algorithm ESP auth attr: id=2, name=AUTH_ALGORITHM_HMAC_SHA1, keysizemin=160, keysizemax=160
algorithm ESP auth attr: id=5, name=AUTH_ALGORITHM_HMAC_SHA2_256, keysizemin=256, keysizemax=256
algorithm ESP auth attr: id=6, name=AUTH_ALGORITHM_HMAC_SHA2_384, keysizemin=384, keysizemax=384
algorithm ESP auth attr: id=7, name=AUTH_ALGORITHM_HMAC_SHA2_512, keysizemin=512, keysizemax=512
algorithm ESP auth attr: id=251, name=(null), keysizemin=0, keysizemax=0

algorithm IKE encrypt: id=1, name=OAKLEY_DES_CBC, blocksize=8, keydeflen=64
algorithm IKE encrypt: id=3, name=OAKLEY_BLOWFISH_CBC, blocksize=8, keydeflen=128
algorithm IKE encrypt: id=5, name=OAKLEY_3DES_CBC, blocksize=8, keydeflen=192
algorithm IKE encrypt: id=7, name=OAKLEY_AES_CBC, blocksize=16, keydeflen=128
algorithm IKE encrypt: id=65004, name=OAKLEY_SERPENT_CBC, blocksize=16, keydeflen=128
algorithm IKE encrypt: id=65005, name=OAKLEY_TWOFISH_CBC, blocksize=16, keydeflen=128
algorithm IKE encrypt: id=65289, name=OAKLEY_TWOFISH_CBC_SSH, blocksize=16, keydeflen=128
algorithm IKE hash: id=1, name=OAKLEY_MD5, hashsize=16
algorithm IKE hash: id=2, name=OAKLEY_SHA1, hashsize=20
algorithm IKE hash: id=4, name=OAKLEY_SHA2_256, hashsize=32
algorithm IKE dh group: id=1, name=OAKLEY_GROUP_MODP768, bits=768
algorithm IKE dh group: id=2, name=OAKLEY_GROUP_MODP1024, bits=1024
algorithm IKE dh group: id=5, name=OAKLEY_GROUP_MODP1536, bits=1536
algorithm IKE dh group: id=14, name=OAKLEY_GROUP_MODP2048, bits=2048
algorithm IKE dh group: id=15, name=OAKLEY_GROUP_MODP3072, bits=3072
algorithm IKE dh group: id=16, name=OAKLEY_GROUP_MODP4096, bits=4096
algorithm IKE dh group: id=17, name=OAKLEY_GROUP_MODP6144, bits=6144
algorithm IKE dh group: id=18, name=OAKLEY_GROUP_MODP8192, bits=8192

stats db_ops.c: {curr_cnt, total_cnt, maxsz} :context={0,5,64} trans={0,5,1296} attrs={0,5,432}

"MyVpnTunnel": 10.1.1.0/24===1.1.1.1---1.1.1.254...2.2.2.2===192.168.1.0/24; erouted; eroute owner: #20
"MyVpnTunnel":     srcip=unset; dstip=unset;
"MyVpnTunnel":   ike_life: 28800s; ipsec_life: 3600s; rekey_margin: 120s; rekey_fuzz: 0%; keyingtries: 0
"MyVpnTunnel":   policy: PSK+ENCRYPT+TUNNEL+failureDROP; prio: 24,24; interface: Port8; encap: esp;
"MyVpnTunnel":   dpd: action:restart; delay:60; timeout:10;
"MyVpnTunnel":   newest ISAKMP SA: #18; newest IPsec SA: #20;
"MyVpnTunnel":   IKE algorithms wanted: DES_CBC(1)_000-MD5(1)-MODP768(1); flags=strict
"MyVpnTunnel":   IKE algorithms found: DES_CBC(1)_064-MD5(1)_128-MODP768(1)
"MyVpnTunnel":   IKE algorithm newest: DES_CBC_64-MD5-MODP768
"MyVpnTunnel":   ESP algorithms wanted: DES(2)_000-MD5(1); flags=strict
"MyVpnTunnel":   ESP algorithms loaded: DES(2)_000-MD5(1); flags=strict
"MyVpnTunnel":   ESP algorithm newest: DES_0-HMAC_MD5; pfsgroup=<N/A>

#20: "MyVpnTunnel":500 STATE_QUICK_I2 (sent QI2, IPsec SA established); EVENT_SA_REPLACE in 3322s; newest IPSEC; eroute owner
#20: "MyVpnTunnel" esp.983c7b5@2.2.2.2 esp.b2eed2b6@1.1.1.1 tun.0@2.2.2.2 tun.0@1.1.1.1
#18: "MyVpnTunnel":500 STATE_MAIN_R3 (sent MR3, ISAKMP SA established); EVENT_SA_REPLACE in 25042s; newest ISAKMP; lastdpd=3s(seq in:0 out:0)
```



## VPN Routing debug

Static routes and VPN routes can overlap, for example
- 192.168.1.0/24 -> vpn tunnel
- 192.168.0.0/16 -> static route to MPLS router

To show the curret priority order:

```
console> system route_precedence show
Default routing Precedence:
1.  Policy routes
2.  VPN routes
3.  Static routes
```

**However**, depending on the configuration order (first the vpn, then the static route), the vpn route can vanish (**BUG**, confirmed by Sophos) and:
- no traffic from the local network will be tunneled across the vpn
- traffic from the remote network will work, because it enters the vpn and hits the conntrack

Check for empty ipsec route:

```
console> system ipsec_route show
tunnelname              host/network        netmask
```

Force add the vpn route and check:

```
console> system ipsec_route add net 192.168.1.0/255.255.255.0 tunnelname MyVpnTunnel
console> system ipsec_route show
tunnelname              host/network        netmask
MyVpnTunnel           192.168.1.0         255.255.255.0
```

And now the traffic will work on both directions.
As of June 2017 there is no way to debug and fix this through the web interface

## SSL VPN restart

The `Restart VPN Service` menu voice does restart IPSEC but not SSL VPNs, use:

```
service -ds nosync sslvpn:restart
```

## HA commands

Check details:
```
console> system ha show details
 HA status              : Enabled
 Current Appliance Key  : xxxxxxxxxxxxxxx
 Peer Appliance Key     : xxxxxxxxxxxxxxx
 Current HA state       : Primary
 Peer HA state          : Auxiliary
 HA Config Mode         : Active-Passive
 Load Balancing         : Not Applicable
 Dedicated Port         : Port6
 Current Dedicated IP   : 172.16.253.253
 Peer Dedicated IP      : 172.16.253.254
 Monitoring Port        : Port1
 Auxiliary Admin Port   : Port1
 Auxiliary Admin IP     : 172.17.4.253
 Auxiliary Admin IPv6   :
```

