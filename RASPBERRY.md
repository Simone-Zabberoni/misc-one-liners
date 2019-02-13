# Raspberry configurations


## Dhcp Wifi + static ethernet with vlan interfaces

Define vlan interface binding in `/etc/network/interfaces`:
```
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d


auto eth0.20
iface eth0.20 inet manual
        vlan-raw-device eth0

auto eth0.30
iface eth0.30 inet manual
        vlan-raw-device eth0
```

Define the static ip addresses in `/etc/dhcpcd.conf`:

```
[...]

interface eth0
static ip_address=10.10.0.10/24

interface eth0.20
static ip_address=10.10.20.10/24

interface eth0.30
static ip_address=10.10.30.10/24

[...]
```

