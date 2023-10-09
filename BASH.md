# Bash one liners

## Yum

Search all version of a package:

```
yum --showduplicates list kibana
[cut]

Available Packages
kibana.x86_64                                                                           7.0.0-1                                                                           elastic-7
kibana.x86_64                                                                           7.0.1-1                                                                           elastic-7
kibana.x86_64                                                                           7.1.0-1                                                                           elastic-7

[cut]

kibana.x86_64                                                                           7.9.0-1                                                                           elastic-7
kibana.x86_64                                                                           7.9.1-1                                                                           elastic-7
kibana.x86_64                                                                           7.9.2-1
```

And install a specific one:

```
yum install kibana-7.8.0-1


```

## Find, sed and similar

Search for pattern in all php files, remove any file that matches:

```
find /var/www -name '*.php*' -exec grep -l '$GLOBALS.*="\\x' {} \; -exec rm -f {} \;
```

Search for pattern in all php files, remove only the matching line from the files:

```
find /var/www -name '*.php*' -exec grep -l '\@assert(base64_decode(\$_REQUEST\["array"\]' {} \; -exec sed -i '/\@assert(base64_decode(\$_REQUEST\["array"\]/d' {} \;
```

Add chars at beginning and end of line (ie: creating wildcards):
```
sort somedomains  | uniq | sed 's/\(^\|$\)/*/g'
*ancillarycheese.com*
*auth-verify.com*
*bloemlight.com*
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

Create a self signed key and cert:
```
openssl req -new -x509 -newkey rsa:2048 -out selfcert.pem -days 3650
```

Create a password protected PFX package (key+certfile+chain), usable for IIS, Sophos UTM etc. :

```
openssl pkcs12 -export -out somedomain_it.pfx -inkey wildcard_somedomain_it.key -in wildcard_somedomain_it.crt -certfile intermediate_chain.crt
```

Convert base64 PFX:
```
openssl enc -base64 -d -in somedomain_it_base64.pfx -out somedomain_it.pfx
```

Extract key and cert from PFX:

```
openssl pkcs12 -in somedomain_it.pfx -nocerts -nodes -out somedomain_it.key
openssl pkcs12 -in somedomain_it.pfx -nokeys -out somedomain_it.crt
```

Check a Certificate Signing Request (CSR)

```
openssl req -text -noout -verify -in CSR.csr
```

Create a Certificate Signing Request (CSR) from existing key
```
openssl req -new -key somedomain_it.key -out somedomain_it.csr
```

Create a signed CRT from CSR and key:
```
openssl x509 -signkey somedomain_it.key  -days 1095  -req -in somedomain_it.csr -out somedomain_it.crt -sha256
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

Match certificate and CA
```
openssl verify -verbose -CAfile ca.pem  client.pem
client.pem: OK
```


Simple CA and client certificate (https://support.huawei.com/enterprise/en/doc/EDOC1000178174/b81cd830/why-the-lldp-neighbor-information-cannot-be-obtained-through-snmp-or-the-operations-performed-on-lldp-mib-objects-do-not-take-effect)

```
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 1000 -key ca-key.pem > ca-cert.pem
openssl req -newkey rsa:2048 -days 1000 -nodes -keyout client-key1.pem > client-req.pem
openssl x509 -req -in client-req.pem -days 1000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > client-cert1.pem
openssl pkcs12 -export -in client-cert1.pem -inkey client-key1.pem -out client-cert1.pfx
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

AWS Polly SSML - read as single digit ( `.` are used for a better pause):

```
<speak>
Per urgenze potete chiamare i seguenti numeri. <say-as interpret-as="digit">334654365442</say-as>.
oppure <say-as interpret-as="digit">338543534534534</say-as>
</speak>
```

Useful sql queries - pickupgroup report:

```
mysql> select sip.id as 'Interno', users.name as 'Utente', sip.data as 'Pickup Group' from sip,users where sip.keyword='pickupgroup' and sip.id = users.extension order by sip.data;
+---------+-------------------------+--------------+
| Interno | Utente                  | Pickup Group |
+---------+-------------------------+--------------+
| 405     | xxxxxxxxxxxx            | 1            |
| 416     | xxxxxxxxxxxxxxx         | 1            |
| 475     | xxxxxxxxxxxxxxx         | 1            |
| 431     | xxxxxxxx                | 12           |
| 434     | xxxxxxxxxxxxxxxxx       | 12           |
| 441     | xxxxxxxxxxxxxxxx        | 13           |
| 433     | xxxxxxxxxxxxx           | 13           |
| 438     | xxxxxxx                 | 13           |
| 446     | xxxxxxxxxxxxxxx         | 13           |
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

### Misc mysql utils

Scheduled tasks:

```
show events;
```

Current processes:

```
show processlist;
```

Table creation and partitioning stuff (example: zabbix history with partitioning):

```
show create table history;

'CREATE TABLE `history` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT 0,
  `value` double(16,4) NOT NULL DEFAULT 0.0000,
  `ns` int(11) NOT NULL DEFAULT 0,
  KEY `history_1` (`itemid`,`clock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
 PARTITION BY RANGE (`clock`)
(PARTITION `p202008070000` VALUES LESS THAN (1596844800) ENGINE = InnoDB,
 PARTITION `p202008080000` VALUES LESS THAN (1596931200) ENGINE = InnoDB,
 PARTITION `p202008090000` VALUES LESS THAN (1597017600) ENGINE = InnoDB,
 PARTITION `p202008100000` VALUES LESS THAN (1597104000) ENGINE = InnoDB,
 PARTITION `p202008110000` VALUES LESS THAN (1597190400) ENGINE = InnoDB,
 PARTITION `p202008120000` VALUES LESS THAN (1597276800) ENGINE = InnoDB,
 PARTITION `p202008130000` VALUES LESS THAN (1597363200) ENGINE = InnoDB,
 PARTITION `p202008140000` VALUES LESS THAN (1597449600) ENGINE = InnoDB,
 PARTITION `p202008150000` VALUES LESS THAN (1597536000) ENGINE = InnoDB,
 PARTITION `p202008160000` VALUES LESS THAN (1597622400) ENGINE = InnoDB,
 PARTITION `p202008170000` VALUES LESS THAN (1597708800) ENGINE = InnoDB,
 PARTITION `p202008180000` VALUES LESS THAN (1597795200) ENGINE = InnoDB,
 PARTITION `p202008190000` VALUES LESS THAN (1597881600) ENGINE = InnoDB,
 PARTITION `p202008200000` VALUES LESS THAN (1597968000) ENGINE = InnoDB,
 PARTITION `p202008210000` VALUES LESS THAN (1598054400) ENGINE = InnoDB,
 PARTITION `p202008220000` VALUES LESS THAN (1598140800) ENGINE = InnoDB,
 PARTITION `p202008230000` VALUES LESS THAN (1598227200) ENGINE = InnoDB,
 PARTITION `p202008240000` VALUES LESS THAN (1598313600) ENGINE = InnoDB)'

```

Manual partition remove

```
ALTER TABLE history DROP PARTITION p202008210000;
```

## Zabbix Mysql stuff

### Reset admin password:

```
update users set passwd=md5('zabbix') where alias='Admin';
```

### Zabbix 5.0 update DB conversions (thanks to @riogezz - https://github.com/riogezz)

Addition to /etc/my.cnf

```
    [client]
    user=zabbix
    password=YourZabbixUserPassword
```

**Important**: `ALTER TABLE` makes a FULL copy of the table, make sure to have enough time and storage

```
systemctl stop zabbix-server

mysql --database=zabbix -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin; SET foreign_key_checks = 1; "}' | mysql --database=zabbix

    mysql -e "ALTER DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;"
```

### Double precision value:

```
    wget https://git.zabbix.com/projects/ZBX/repos/zabbix/raw/database/mysql/double.sql
    mysql zabbix < double.sql
```

Addition to `/etc/zabbix/web/zabbix.conf.php`:

```

    $DB['DOUBLE_IEEE754'] = 'true';
```

**Important**: Restart apache2/nginx and php-fpm

### Zabbix 5.0 collation conversion status:

Current processes:

```
MariaDB [zabbixdb]> SHOW PROCESSLIST
    -> ;
+-----+------------+-----------+----------+---------+------+-------------------+------------------------------------------------------------------------+----------+
| Id  | User       | Host      | db       | Command | Time | State             | Info                                                                   | Progress |
+-----+------------+-----------+----------+---------+------+-------------------+------------------------------------------------------------------------+----------+
|  52 | zabbixuser | localhost | zabbixdb | Query   |    2 | copy to tmp table | ALTER TABLE history_str CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin |    1.399 |
| 347 | zabbixuser | localhost | zabbixdb | Query   |    0 | NULL              | SHOW PROCESSLIST                                                       |    0.000 |
+-----+------------+-----------+----------+---------+------+-------------------+------------------------------------------------------------------------+----------+
2 rows in set (0.00 sec)
```

Show tables to convert:

```
MariaDB [zabbixdb]> show table status where collation not like 'utf8_bin';
+---------------------+--------+---------+------------+-----------+----------------+-------------+-----------------+--------------+------------+----------------+-----  ----------------+-------------+------------+-----------------+----------+----------------+---------+
| Name                | Engine | Version | Row_format | Rows      | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free  | Auto_increment | Crea  te_time         | Update_time | Check_time | Collation       | Checksum | Create_options | Comment |
+---------------------+--------+---------+------------+-----------+----------------+-------------+-----------------+--------------+------------+----------------+-----  ----------------+-------------+------------+-----------------+----------+----------------+---------+
| history_uint        | InnoDB |      10 | Compact    | 252884126 |             52 | 13354647552 |               0 |  10553049088 |   93323264 |           NULL | 2020  -06-17 02:04:34 | NULL        | NULL       | utf8_general_ci |     NULL | partitioned    |         |
| task_check_now      | InnoDB |      10 | Compact    |         0 |              0 |       16384 |               0 |            0 |          0 |           NULL | 2018  -11-20 10:03:19 | NULL        | NULL       | utf8_general_ci |     NULL |                |         |
| task_remote_command | InnoDB |      10 | Compact    |         0 |              0 |       16384 |               0 |            0 |          0 |           NULL | 2017  -10-03 10:18:32 | NULL        | NULL       | utf8_general_ci |     NULL |                |         |
| trends              | InnoDB |      10 | Compact    |  45450154 |            105 |  4812013568 |               0 |            0 | 1525678080 |           NULL | 2020  -06-17 02:12:27 | NULL        | NULL       | utf8_general_ci |     NULL | partitioned    |         |
| trends_uint         | InnoDB |      10 | Compact    |  91883023 |            102 |  9422929920 |               0 |            0 | 1902116864 |           NULL | 2020  -06-17 02:18:44 | NULL        | NULL       | utf8_general_ci |     NULL | partitioned    |         |
+---------------------+--------+---------+------------+-----------+----------------+-------------+-----------------+--------------+------------+----------------+-----  ----------------+-------------+------------+-----------------+----------+----------------+---------+
5 rows in set (1 min 31.85 sec)
```

## NETPLAN
Static IP configuration
```
cat /etc/netplan/99_config.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    ens32:
     dhcp4: no
     addresses: [192.168.238.30/24]
     gateway4: 192.168.238.2
     nameservers:
       addresses: [192.168.238.2]
```


## NOIP


### Modified systemd startup script - works on debian/raspbian

Created as `/etc/init.d/noip2.sh`:

```
#! /bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description:
### END INIT INFO

# /etc/init.d/noip2.sh

# Supplied by no-ip.com
# Modified for Debian GNU/Linux by Eivind L. Rygge <eivind@rygge.org>
# corrected 1-17-2004 by Alex Docauer <alex@docauer.net>

# . /etc/rc.d/init.d/functions  # uncomment/modify for your killproc

DAEMON=/usr/local/bin/noip2
NAME=noip2

test -x $DAEMON || exit 0

case "$1" in
    start)
    echo -n "Starting dynamic address update: "
    start-stop-daemon --start --exec $DAEMON
    echo "noip2."
    ;;
    stop)
    echo -n "Shutting down dynamic address update:"
    start-stop-daemon --stop --oknodo --retry 30 --exec $DAEMON
    echo "noip2."
    ;;

    restart)
    echo -n "Restarting dynamic address update: "
    start-stop-daemon --stop --oknodo --retry 30 --exec $DAEMON
    start-stop-daemon --start --exec $DAEMON
    echo "noip2."
    ;;

    *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac
exit 0
```

Followed by

```
systemctl enable noip2
systemctl start noip2
```


