#!/bin/bash

echo "Создадим RAID..."
    mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
    mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
    
echo "Сохраним RAID..."
    echo "DEVICE partitions" > /etc/mdadm.conf
    mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf
    mdadm -W /dev/md0

echo "Проверим RAID Ok:"
    cat /proc/mdstat

    mdadm /dev/md0 --fail /dev/sde
    mdadm /dev/md0 --remove /dev/sde

echo "Проверим RAID без диска dev/sde:"
    cat /proc/mdstat
    mdadm /dev/md0 --add /dev/sde

echo "Перестройка RAID:"
    cat /proc/mdstat
    mdadm -W /dev/md0

echo "Проверим RAID Ok:"
    cat /proc/mdstat


echo "Создадим GPT..."
    parted /dev/md0 mklabel gpt

    parted /dev/md0 mkpart primary ext4 0% 20%
    parted /dev/md0 mkpart primary ext4 20% 40%
    parted /dev/md0 mkpart primary ext4 40% 60%
    parted /dev/md0 mkpart primary ext4 60% 80%
    parted /dev/md0 mkpart primary ext4 80% 100%

echo "Создадим FS и mount..."
    for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
    mkdir -p /raid/part{1,2,3,4,5}
    for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

echo "Запишем mount в fstab на будущее"
    cat /etc/mtab | grep raid >> /etc/fstab

