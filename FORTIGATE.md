# Fortigate useful commands


## Performance troubleshooting

Equivalent procinfo and cpuinfo 
Reference: http://kb.fortinet.com/kb/viewContent.do?externalId=FD30084

```
fw # get system performance status
CPU states: 32% user 67% system 0% nice 1% idle
CPU0 states: 32% user 67% system 0% nice 1% idle
Memory states: 33% used
Average network usage: 5898 / 5810 kbps in 1 minute, 7604 / 7636 kbps in 10 minutes, 5279 / 5258 kbps in 30 minutes
Average sessions: 2571 sessions in 1 minute, 2670 sessions in 10 minutes, 2305 sessions in 30 minutes
Average session setup rate: 19 sessions per second in last 1 minute, 18 sessions per second in last 10 minutes, 15 sessions per second in last 30 minutes
Virus caught: 0 total in 1 minute
IPS attacks blocked: 0 total in 1 minute
Uptime: 176 days,  1 hours,  10 minutes
```

```
fw # diagnose hardware sysinfo memory
        total:    used:    free:  shared: buffers:  cached: shm:
Mem:  1928798208 646651904 1282146304        0  1753088 201564160 153124864
Swap:        0        0        0
MemTotal:      1883592 kB
MemFree:       1252096 kB
MemShared:           0 kB
Buffers:          1712 kB
Cached:         196840 kB
SwapCached:          0 kB
Active:         102560 kB
Inactive:        96128 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      1883592 kB
LowFree:       1252096 kB
SwapTotal:           0 kB
SwapFree:            0 kB
```


Equivalent top
Reference: http://kb.fortinet.com/kb/documentLink.do?externalID=FD30531

```
diagnose sys top 2 20

Run Time:  176 days, 1 hours and 22 minutes
80U, 19N, 0S, 1I; 1839T, 1213F
         sslvpnd       71      R      90.1     1.3
             wad       86      S       7.3     3.3
          newcli    32290      R       1.4     0.8
          httpsd    32278      S       0.4     1.2
        dnsproxy       95      S       0.0     3.0
       scanunitd    32178      S <     0.0     2.0
       scanunitd    32172      S <     0.0     2.0
       scanunitd     7249      S <     0.0     2.0
         cmdbsvr       35      S       0.0     1.7
         pyfcgid    32088      S       0.0     1.6
         pyfcgid    32090      S       0.0     1.6
         pyfcgid    32089      S       0.0     1.6
         pyfcgid    32086      S       0.0     1.4
         miglogd       54      S       0.0     1.4
          httpsd    29716      S       0.0     1.3
       forticron       65      R       0.0     1.3
          httpsd    29757      S       0.0     1.3
       ipshelper    16913      S <     0.0     1.2
          httpsd       56      S       0.0     1.1
          httpsd      108      S       0.0     1.0
```

Table reference:

```
The meaning of the letters on the second line of the output is given in the following table.
 
U  - User cpu usage (%)
S  - System cpu usage (%)
I  - dle cpu usage (%)
T  - Total memory
F  - Free memory
KF - Kernel free memory

The following table describes the output format of the others lines. 

Column #1 - Process name
Column #2 - Process identification (PID)
Column #3 - One letter process status
				S: sleeping process
				R: running process
				<: high priority
Column #4 - CPU usage (%)
Column #5 - Memory usage (%)
```

