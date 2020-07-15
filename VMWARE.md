# ESXCLI / LOCALCLI

## Management interface setup

```
esxcli storage core path list
```

```
[root@someEsx:/var/log] localcli storage core device list   | head

naa.xxxxxxxxxxxxxxxx:
   Display Name: Local LSI Enclosure Svc Dev (naa.xxxxxxxxxxxxxxxx)
   Has Settable Display Name: true
   Size: 0
   Device Type: Enclosure Svc Dev
   Multipath Plugin: NMP
   Devfs Path: /vmfs/devices/genscsi/naa.xxxxxxxxxxxxxxxx
   Vendor: LSI
```

```
[root@someEsx:/var/log] localcli network ip interface ipv4 get
Name  IPv4 Address   IPv4 Netmask   IPv4 Broadcast  Address Type  Gateway      DHCP DNS
---------------------------------------------------------------------------------------
vmk0  1.1.1.1  255.255.0.0    172.16.255.255  STATIC        172.16.11.3  false
vmk1  1.2.1.1  255.255.255.0  10.251.251.255  STATIC        0.0.0.0      false
vmk2  1.2.1.1  255.255.255.0  10.252.252.255  STATIC        0.0.0.0      false
```

```
[root@someEsx:/var/log] vmkping -I vmk1 1.1.1.10
```

```
[root@someEsx:/var/log] vmkping -I vmk2 1.2.1.1
```
