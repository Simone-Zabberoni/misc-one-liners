# Bash one liners

## Find, sed and similar

Search for pattern in all php files, remove any file that matches:
```
find /var/www -name '*.php*' -exec grep -l '$GLOBALS.*="\\x' {} \; -exec rm -f {} \;
```

Search for pattern in all php files, remove only the matching line from the files:
```
find /var/www -name '*.php*' -exec grep -l '\@assert(base64_decode(\$_REQUEST\["array"\]' {} \; -exec sed -i '/\@assert(base64_decode(\$_REQUEST\["array"\]/d' {} \;
```


## Curl

Curl to a website using a specific host header - check if the virtualhost is configured:
```
curl --verbose --header 'Host: www.domain.tld' 'http://www.some-hosting-server.tld'
```

Curl with proxy, check only for header:
```
curl -x proxy_ip:8080 -Is https://www.google.com
HTTP/1.1 200 Connection established
[...]
```

Send a UPnP SOAP request:

```
curl 'http://192.168.40.1:1990/control?WFAWLANConfig' \
  -X 'POST' \
  -H 'Content-Type: text/xml; charset="utf-8"' \
  -H 'Connection: close' \
  -H 'SOAPAction: "urn:schemas-wifialliance-org:service:WFAWLANConfig:1#GetDeviceInfo"' \
  -d '<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<s:Body>
<u:GetDeviceInfo xmlns:u="urn:schemas-wifialliance-org:service:WFAWLANConfig:1">

</u:GetDeviceInfo>
</s:Body>
</s:Envelope>'
```

```
curl 'http://192.168.40.1:1990/control?WFAWLANConfig' \
  -X 'POST' \
  -H 'Content-Type: text/xml; charset="utf-8"' \
  -H 'Connection: close' \
  -H 'SOAPAction: "urn:schemas-wifialliance-org:service:WFAWLANConfig:1#GetAPSettings"' \
  -d '<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<s:Body>
<u:GetAPSettings xmlns:u="urn:schemas-wifialliance-org:service:WFAWLANConfig:1">
<NewMessage>GetAPSettings</NewMessage>
</u:GetAPSettings>
</s:Body>
</s:Envelope>'
```


## SSL

https://www.sslshopper.com/article-most-common-openssl-commands.html

Create a CSR for a wildcard cert:
```
openssl req -new -newkey rsa:2048 -nodes -out wildcard_somedomain_it.csr -keyout wildcard_somedomain_it.key -subj "/C=IT/ST=IT/L=MyCity/O=MyBusiness/CN=*.somedomain.it"
```

Create a password protected PFX package (key+certfile+chain), usable for IIS, Sophos UTM etc. :
```
openssl pkcs12 -export -out somedomain_it.pfx -inkey wildcard_somedomain_it.key -in wildcard_somedomain_it.crt -certfile intermediate_chain.crt
```

## Samba

Create an account file for smbclient (awful plaintext):
```
cat .smbaccess
username=test
password=someTestPassword
domain=my_domain
```

Copy some local files to a specific remote directory:
```
/usr/bin/smbclient //my_file_server/backups$ -A .smbaccess -c "lcd /some/local/dir/; cd RemoteDirectory; prompt; mput *"

```

## Brutal FTP Upload

```
#!/bin/sh

HOST='some-ftp-server'
USER='my-username'
PASSWD='uberpassword'


ftp -n -v $HOST << EOT
ascii
user $USER $PASSWD
prompt
cd some-remote-directory
lcd /my/local/backup/
put backup.tar.gz
ls -la
bye
EOT
```

## SCSI Rescan, lvm and stuff

Rescan drives after resize (ie: Vmware disk extend)
```
echo "- - -" > /sys/class/scsi_host/host0/scan
echo "- - -" > /sys/class/scsi_host/host1/scan	
echo "- - -" > /sys/class/scsi_host/host2/scan
```

Extend a LV to 100% of the available space:
```
lvresize -l +100%FREE /dev/mysql/lv_mysql
```




