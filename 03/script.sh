#/bin/bash

df -h
lsblk
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -L 8G -n lv_root /dev/vg_root

