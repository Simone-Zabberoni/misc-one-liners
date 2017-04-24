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
