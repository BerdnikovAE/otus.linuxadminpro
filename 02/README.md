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