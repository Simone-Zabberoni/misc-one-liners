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

---

## Raspicam with python PiCamera

Documentation: 
- https://picamera.readthedocs.io/en/release-1.10/api_camera.html
- https://www.raspberrypi.org/documentation/raspbian/applications/camera.md
- https://www.raspberrypi.org/documentation/hardware/camera/README.md
- https://www.raspberrypi.org/documentation/configuration/camera.md


### Sample live preview 

```
from picamera import PiCamera
from time import sleep

camera = PiCamera()

camera.start_preview(fullscreen=False,window=(0,0,600,800))

camera.exposure_compensation = 10
camera.brightness = 50
camera.contrast = 50

camera.zoom= (0.15, 0.40, 0.5, 0.5)

camera.image_effect = 'watercolor'
#camera.image_effect = 'oilpaint'
```



