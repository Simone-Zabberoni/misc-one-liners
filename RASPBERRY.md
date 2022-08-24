# Raspberry configurations


## Headless basic stuff
Place these files on the boot directory:

File `ssh` with nothing inside

File `wpa_supplicant.conf` with wireless settings:
```
country=IT # Your 2-digit country code
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev # Include this line for Stretch
network={
    ssid="yourWifiNet"
    psk="yourWifipass"
    key_mgmt=WPA-PSK
}
```

File `userconf` with standard pi:raspberry password
```
pi:$6$/4.VdYgDm7RJ0qM1$FwXCeQgDKkqrOU3RIRuDSKpauAbBvP11msq9X58c8Que2l1Dwq3vdJMgiZlQSbEXGaY5esVHGBNbCxKLVNqZW1
```


## Troubleshoot 

Hdmi safe mode - https://elinux.org/R-Pi_Troubleshooting#No_HDMI_output_at_all

In config.txt uncomment:
```
hdmi_safe=1
```

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

---

## OpenCV

Setup documentation:
- https://www.pyimagesearch.com/2018/09/26/install-opencv-4-on-your-raspberry-pi/

Surveillance sample:
- https://www.pyimagesearch.com/2015/05/25/basic-motion-detection-and-tracking-with-python-and-opencv/
- https://www.pyimagesearch.com/2018/09/26/install-opencv-4-on-your-raspberry-pi/

Launch sample from virtual env:
```
source /usr/local/bin/virtualenvwrapper.sh
workon cv
python pi_surveillance.py -c conf.json
```

