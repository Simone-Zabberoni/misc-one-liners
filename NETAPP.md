# Netapp command line


## Cluster mode

### Add an account with ssh access with an existing public key

```
FASCLUSTER::security login publickey> security login create -user-or-group-name someUser -application ssh -authmethod publickey -role admin
Warning: To use public-key authentication, you must create a public key for user "someUser".

FASCLUSTER::security login publickey> security login publickey load-from-uri -username someUser -uri https://someServer/distrib/id_rsa.pub

Enter User: someUser
Enter Password: <vuota>
```
And you can `ssh someUser@FASCLUSTER` directly by providing the matching `id_rsa.key`

### Remote shutdown via ssh with public key authentication
```
echo "y\n" | ssh someUser@FASCLUSTER system halt -node NODE-02 -f -skip-lif-migration-before
echo "y\n" | ssh someUser@FASCLUSTER system halt -node NODE-01 -f -skip-lif-migration-before
```

The `-skip-lif-migration-before` inhibits the cluster migration.

### NFS export with rw policy

Sometimes via web interface the `export-policy` will not grant write access, try via console instead:
```
vserver export-policy rule create -vserver SVM0 -policyname default -protocol nfs -clientmatch 192.168.1.241 -rorule any -rwrule any -superuser any -ruleindex 2
```

## Seven mode

### Volume space usage

```
SOMEFAS> df -h
Filesystem               total       used      avail capacity  Mounted on
/vol/h1_iscsi_logs/      450GB      341GB      108GB      76%  /vol/h1_iscsi_logs/
/vol/vol0/               171GB     5997MB      165GB       3%  /vol/vol0/
/vol/h1_iscsi_vm/       1536GB     1508GB       27GB      98%  /vol/h1_iscsi_vm/
/vol/h1_cifs_01/        1499GB      894GB      605GB      60%  /vol/h1_cifs_01/
```

### Aggregate space usage
```
SOMEFAS> df -Ah
Aggregate                total       used      avail capacity
aggr0                   3445GB     2668GB      776GB      77%
aggr0/.snapshot            0TB        0TB        0TB       0%
aggr1_r4                 492GB      452GB       39GB      92%
aggr1_r4/.snapshot         0TB        0TB        0TB       0%
```

