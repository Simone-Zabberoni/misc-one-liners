# Security Stuff



## VPNs

### Ike Scan

Good ref with scripts and most common params for transform: https://book.hacktricks.xyz/pentesting/ipsec-ike-vpn-pentesting

```
AES256, SHA, PSK, DH2
ike-scan -vv  1.2.3.4  -A --id VPN-ID --trans 7/256,2,1,2

AES256, SHA256, PSK, DH14
ike-scan -vv  1.2.3.4  -A --id VPN-ID --trans 7/256,4,1,14
```


### 

