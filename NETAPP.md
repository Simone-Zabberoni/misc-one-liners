# Netapp command line


## Cluster mode



## Seven mode

### Volume space usage

SOMEFAS> df -h
Filesystem               total       used      avail capacity  Mounted on
/vol/h1_iscsi_logs/      450GB      341GB      108GB      76%  /vol/h1_iscsi_logs/
/vol/vol0/               171GB     5997MB      165GB       3%  /vol/vol0/
/vol/h1_iscsi_vm/       1536GB     1508GB       27GB      98%  /vol/h1_iscsi_vm/
/vol/h1_cifs_01/        1499GB      894GB      605GB      60%  /vol/h1_cifs_01/

### Aggregate space usage
SOMEFAS> df -Ah
Aggregate                total       used      avail capacity
aggr0                   3445GB     2668GB      776GB      77%
aggr0/.snapshot            0TB        0TB        0TB       0%
aggr1_r4                 492GB      452GB       39GB      92%
aggr1_r4/.snapshot         0TB        0TB        0TB       0%


