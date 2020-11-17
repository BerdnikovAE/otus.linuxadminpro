# ДЗ 02

VM провижинится скриптом [`create_destroy_raid.sh`](create_destroy_raid.sh).


Логи выполнения скрипта
```
==> otuslinux: Running provisioner: shell...

...
otuslinux: md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
otuslinux:       761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
...
otuslinux: md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
otuslinux:       761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
...
otuslinux: md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
otuslinux:       761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

```

Подключаемся по ssh 

```
> vagrant ssh
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Nov 17 11:20:36 2020
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue Nov 17 11:23:19 2020
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 03d2832d:ac8dfa47:865a9e1a:db0627fe
            Events : 41

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       5       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf

[vagrant@otuslinux ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        489M     0  489M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6.8M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
/dev/sda1        40G  4.3G   36G  11% /
/dev/md0p3      142M  1.6M  130M   2% /raid/part3
/dev/md0p1      139M  1.6M  127M   2% /raid/part1
/dev/md0p2      140M  1.6M  128M   2% /raid/part2
/dev/md0p5      139M  1.6M  127M   2% /raid/part5
/dev/md0p4      140M  1.6M  128M   2% /raid/part4
tmpfs           100M     0  100M   0% /run/user/1000