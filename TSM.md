# TSM command line


First session, "join" the TSM server:
```
dsmc q sess
```
Show backup schedule:
```
dsmc q sched
```

Restore examples:

```
dsmc restore /var/www/www.somedomain.it/ /tmp/www.somedomain.it/ -subdir=yes
dsmc restore /var/www/www.somedomain.it/ /tmp/www.somedomain.it/ -subdir=yes -pitd=7/18/2016 -pitt=13:00:00
```
**Do not forget the trailing "/" in the directory names!**
