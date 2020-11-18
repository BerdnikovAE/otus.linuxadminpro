
# ДЗ 03. Файловые системы и LVM


## 1. Уменьшим директорию **/**  до 8 Gb. 

Ставим пакет для дампа xfs
```sh
03> vagrant ssh
...
[vagrant@lvm ~]$ sudo su

[root@lvm vagrant]# yum install -y xfsdump
...
```
Посмотрим что есть в начале:
```sh
[root@lvm vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk
sdc                       8:32   0    2G  0 disk
sdd                       8:48   0    1G  0 disk
sde                       8:64   0    1G  0 disk

[root@lvm vagrant]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  733M   37G   2% /
devtmpfs                         109M     0  109M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                             24M     0   24M   0% /run/user/1000
```
Создаем временный Logical Volume для переноса /
```
[root@lvm vagrant]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

[root@lvm vagrant]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created

[root@lvm vagrant]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
```
Создаем файловую систему, монтируем и копируем на нее корень
```
[root@lvm vagrant]# mkfs.xfs /dev/vg_root/lv_root
[root@lvm vagrant]# mount /dev/vg_root/lv_root /mnt
```
копируем данные /
```
[root@lvm vagrant]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```

перемаунчиваем, делаем chroot и обновляем grub
```
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm ~]# grub2-mkconfig -o /boot/grub2/grub.cfg

```
какая-то магия с initrd...
```
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
правим новый grub
```
[root@lvm boot]# sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/g' /boot/grub2/grub.cfg

[root@lvm boot]# exit
[root@lvm vagrant]# reboot
```

После ребута подключаемся и видим перенесннный /
```
03> vagrant ssh
...
[vagrant@lvm ~]$ sudo su
[root@lvm vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm
sdb                       8:16   0   10G  0 disk
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk
sdd                       8:48   0    1G  0 disk
sde                       8:64   0    1G  0 disk
```
Убиваем старый LV
```
[root@lvm vagrant]# lvremove /dev/VolGroup00/LogVol00
[root@lvm vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```
и снова проделываем этот фокус обратно 
```
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol00
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol00 /mnt
[root@lvm vagrant]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
[root@lvm vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm vagrant]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
```
## 2. выделить том под /var
теперь до ребута можно перенести var
```
[root@lvm /]# pvcreate /dev/sdc /dev/sdd
[root@lvm /]# vgcreate vg_var /dev/sdc /dev/sdd
[root@lvm /]# lvcreate -L 950M -m1 -n lv_var vg_var
[root@lvm /]# mkfs.ext4 /dev/vg_var/lv_var
[root@lvm /]# mount /dev/vg_var/lv_var /mnt
[root@lvm /]# cp -aR /var/* /mnt/
[root@lvm /]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
[root@lvm /]# umount /mnt
[root@lvm /]# mount /dev/vg_var/lv_var /var
[root@lvm /]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
[root@lvm /]# exit
[root@lvm vagrant]# reboot
```

```
03> vagrant ssh
Last login: Wed Nov 18 15:28:21 2020 from 10.0.2.2
[vagrant@lvm ~]$ sudo su




[root@lvm vagrant]#
[root@lvm vagrant]#
[root@lvm vagrant]#
[root@lvm vagrant]#
[root@lvm vagrant]# lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk
├─sda1                     8:1    0    1M  0 part
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk
└─vg_root-lv_root        253:2    0   10G  0 lvm
sdc                        8:32   0    2G  0 disk
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
sdd                        8:48   0    1G  0 disk
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
sde                        8:64   0    1G  0 disk
[root@lvm vagrant]#
[root@lvm vagrant]# lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@lvm vagrant]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@lvm vagrant]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
```
## 3. /home - сделать том для снэпшотов

снова как обычно делаем LV, копируем данные, перемоунчиваем
```
[root@lvm vagrant]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol_Home
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /mnt/
[root@lvm vagrant]# cp -aR /home/* /mnt/
[root@lvm vagrant]# rm -rf /home/*
[root@lvm vagrant]# umount /mnt
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /home/
```
правим fstab чтоб автомаунт был
```
[root@lvm vagrant]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```
делаем кучу файликов
```
[root@lvm vagrant]# touch /home/file{1..20}
```
снимаем снэпшот, удалем файлы
```
[root@lvm vagrant]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
[root@lvm vagrant]# rm -f /home/file{11..20}
```
мержим
```
[root@lvm vagrant]# umount /home
[root@lvm vagrant]# lvconvert --merge /dev/VolGroup00/home_snap
[root@lvm vagrant]# mount /home
```
проверяем, файлы на месте
```
[root@lvm vagrant]# ls -la /home
total 0
drwxr-xr-x.  3 root    root    292 Nov 18 15:38 .
drwxr-xr-x. 18 root    root    239 Nov 18 15:29 ..
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file1
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file10
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file11
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file12
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file13
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file14
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file15
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file16
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file17
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file18
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file19
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file2
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file20
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file3
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file4
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file5
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file6
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file7
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file8
-rw-r--r--.  1 root    root      0 Nov 18 15:38 file9
drwx------.  3 vagrant vagrant  74 May 12  2018 vagrant
```