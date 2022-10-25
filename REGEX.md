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

Better approach, with 3 capturing groups to exclude multiple delimiters (, and space in the example):

```
String:	HP J9148A 2910al-48G-PoE Switch, revision W.15.12.0011, ROM W.14.06  (Formerly ProCurve)

Regex:              ((.+?)([, ]+|$)){6}.*
Capturing Group 1:  `W.15.12.0011, `        <- mind the , and the space
Capturing Group 2:  `W.15.12.0011`          <- that's good!

Regex:              ((.+?)([, ]+|$)){3}.*
Capturing Group 1:  `2910al-48G-PoE, `      <- mind the , and the space
Capturing Group 2:  `2910al-48G-PoE`        <- that's good!
```

An even better approach, with a single capturing group for our target and the other 2 groups are non-capturing:

```
String: HP J9148A 2910al-48G-PoE Switch, revision W.15.12.0011, ROM W.14.06  (Formerly ProCurve)

Regex:              (?:(.+?)(?:[, ]+|$)){3}.*
Capturing Group 1:  `2910al-48G-PoE`

Regex:              (?:(.+?)(?:[, ]+|$)){6}.*
Capturing Group 1:  `W.15.12.0011`
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

Extract ip address from file, possible false positives:

ls

```

cat somefile.txt | egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
```

## Misc

Grep PCRE with non capturing head and tail:

```
echo "<bah>6767</bah>" |  grep -oP  "<bah>\K([0-9]+)(?=<\/bah>)"
6767
```

Perl capture last token between {}:

```
# echo '{EF}{04}{04}{01}' | perl -lne 'print $1 if /(?:{\w\w}){3}{(\w\w)}/'
01
```

Same stuff, capture first and second:
```
echo '{EF}{04}{04}{01}' | perl -lne 'print $1 if /(?:{\w\w}){0}{(\w\w)}/'
EF
echo '{EF}{04}{04}{01}' | perl -lne 'print $1 if /(?:{\w\w}){1}{(\w\w)}/'
04
```


