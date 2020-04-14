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

Whatsmyip:

```
# curl https://ipinfo.io/ip
1.2.3.4
```

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

Curl to Zabbix API with JSON post:

```
curl -i -X POST -H 'Content-type:application/json' \
   -d '{"jsonrpc":"2.0","method":"user.login", \
   "params":{ "user":"youruser","password":"somepassword"},"auth":null,"id":0}' \
   http://some-zabbix-server/api_jsonrpc.php

HTTP/1.1 200 OK
Server: nginx
Date: Mon, 21 Jan 2019 19:17:55 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
Keep-Alive: timeout=20
X-Powered-By: PHP/7.1.17
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Content-Type
Access-Control-Allow-Methods: POST
Access-Control-Max-Age: 1000

{"jsonrpc":"2.0","result":"xxxxxxxxxxxxxxxxx","id":0}
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

Check a Certificate Signing Request (CSR)

```
openssl req -text -noout -verify -in CSR.csr
```

Check a private key

```
openssl rsa -in privateKey.key -check
```

Check a certificate

```
openssl x509 -in certificate.crt -text -noout
```

Check a PKCS#12 file (.pfx or .p12)

```
openssl pkcs12 -info -in keyStore.p12
```

Certificate Key Matcher (from SSL Shopper)

```
openssl pkey -in privateKey.key -pubout -outform pem | sha256sum
openssl x509 -in certificate.crt -pubkey -noout -outform pem | sha256sum
openssl req -in CSR.csr -pubkey -noout -outform pem | sha256sum
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

or (use the correct bus id):

```
echo 1 > /sys/class/scsi_device/0\:0\:0\:0/device/rescan
```

Extend the PV to "see" the new available space:

```
pvresize /dev/sdb
```

Extend a LV to 100% of the available space:

```
lvresize -l +100%FREE /dev/mysql/lv_mysql
```

## SNMP useful stuff

Simple snmp scanner with custom range:

```
#!/bin/bash

COMMUNITY="public"
HOSTNAME_OID=".1.3.6.1.2.1.1.5.0"
SNMP_VERSION="2c"

# Set scanning range
for ip in 172.16.{1..10}.{1..254}
do
    HOSTNAME="$(snmpget -v $SNMP_VERSION -c $COMMUNITY ${ip} $HOSTNAME_OID -r 2 -t 1 2>/dev/null | cut -d '=' -f 2 | cut -d ':' -f 2 | tr -d ' ')"

    if [ ! -z $HOSTNAME ]; then
        echo "${ip} $HOSTNAME"
    fi

done
```

Snmp route analysis:

```
# snmpwalk -c public -v2c 172.16.0.254 RFC1213-MIB::ipRouteNextHop | cut -d ' ' -f 4 | sort | uniq -c | sort
1 172.16.0.1 SomeGW
2 172.16.0.10 some other GW with 2 network behind
6 172.16.0.20 MplsRouter
```

## Zimbra commandline management

Fast domain deletion: get all accounts and delete them, then delete the domain

```
zmprov -l getAllAccounts somedomain.it  | xargs -I {} zmprov da {};
zmprov dd somedomain
```

## Git

Search for deletions:

```
git log --diff-filter=D --summary
```

## Asterisknow

Wav conversion for announcements:

```
sox some.wav -c1 -r 8000 good.wav
```

AWS Polly SSML for mixed language messages:

```
<speak>
Buongiorno! siete in linea con gli uffici di <lang xml:lang="en-US">Something in english</lang>.
Premete uno per amministrazione, due per ufficio tecnico, nove per riascoltare il messaggio.
<lang xml:lang="en-US">This is another message in english</lang>
</speak>
```

## MySQL

Backup script with some features:

- one directory per DB
- one file per table
- non locking (InnoDB)
- throughput throttling (with `pv`)

```
#!/bin/sh

MYSQL_USER="root"
MYSQL_PASS="somePassword"
MYSQL_HOST="127.0.0.1"
BACKUP_DIR=/backup/mysql;

test -d "$BACKUP_DIR" || mkdir -p "$BACKUP_DIR"

# Elenco db
for db in $(mysql -B -s -u $MYSQL_USER --password=$MYSQL_PASS -h $MYSQL_HOST -e 'show databases' | grep -v information_schema)
do
        echo "Backing up db '$db'..."
        for table in `mysql -u $MYSQL_USER -p$MYSQL_PASS $db -h $MYSQL_HOST  -N -B -e "show tables;"`;
        do
                echo " - $table"
                mkdir -p "$BACKUP_DIR/$db"
                mysqldump -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST --routines --opt --single-transaction --skip-lock-tables  $db $table| pv -q -L 10m | gzip > $BACKUP_DIR/$db/$table.sql.gz;
        done

        echo "Done '$db'"
        echo "---------------------------------------------------------------------------------"
done
```

## Zabbix Mysql stuff

Reset admin password:

```
update users set passwd=md5('zabbix') where alias='Admin';
```
