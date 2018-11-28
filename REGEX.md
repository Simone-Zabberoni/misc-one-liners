# Regular expressions


 ## Positional matching

Simple positional extraction, a little crude:

```
String:	HP J9148A 2910al-48G-PoE Switch, revision W.15.12.0011, ROM W.14.06  (Formerly ProCurve)

Regex:	([^ ]+ +){2}.*
Match:	`J9148A `

Regex:	([^ ]+ +){6}.*
Match:	`W.15.12.0011, `
```

Better approach, with 2 capturing groups (lazy) to exclude multiple delimiters (, and space in the example):
```
String:	HP J9148A 2910al-48G-PoE Switch, revision W.15.12.0011, ROM W.14.06  (Formerly ProCurve)

Regex:              ((.+?)([, ]+|$)){6}.*
Capturing Group 1:  `W.15.12.0011, `        <- mind the , and the space
Capturing Group 1:  `W.15.12.0011`          <- that's good!

Regex:              ((.+?)([, ]+|$)){3}.*
Capturing Group 1:  `2910al-48G-PoE, `      <- mind the , and the space
Capturing Group 1:  `2910al-48G-PoE`        <- that's good!
```


## IP address filtering

Example: get all Asterisk peers from hosts 192.168.25.10 to .15

```
Regex: 192\.168\.25\.1[0-5]

# asterisk -r -x  'sip show peers' | grep '192\.168\.25\.1[0-5]'
400/400       192.168.25.12       D     A  4038  OK (5 ms)
401/401       192.168.25.13       D     A  2447  OK (4 ms)
403/403       192.168.25.12       D     A  4038  OK (4 ms)
404/404       192.168.25.12       D     A  4038  OK (4 ms)
408/408       192.168.25.10       D     A  5060  OK (41 ms)
410/410       192.168.25.13       D     A  2447  OK (4 ms)
```

