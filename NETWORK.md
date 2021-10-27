# Generic Network Scripts


## hlogin/rancid stuff

### Minimal setup
```
cat /root/.cloginrc

add user your_admin_user
add password \* some_pass some_enable_pass
add autoenable * 0
add method \* ssh
```

### Run a command
```
hlogin -u your_admin_user -c 'wri mem' 1.2.3.4
```

### Run commands from file:
```
cat fixDNS.cmd

conf term
ip dns server-address 8.8.8.8
exit
wri mem


hlogin -u your_admin_user -x fixDNS.cmd 1.2.3.4
```

---

## Multiswitch backup via hlogin

To be refined... but it works: no error checking, be careful.
It works with hlogin, tested with HP os-cx and s devices.

Files can be found [here](https://github.com/Simone-Zabberoni/misc-one-liners/blob/master/NETWORK). 

Edit `switchList.conf` with the names and addresses of your switch:

```
SW-CORE01      192.168.100.1
SW-CORE02      192.168.100.2
SW-ACCESS01    192.168.100.11
```

The `backupSwitch.sh` script will create a new folder and backup the conf
The `backupAll.sh` script spawns in parallel one `backupSwitch.sh` process per device, al the files in the same directory




