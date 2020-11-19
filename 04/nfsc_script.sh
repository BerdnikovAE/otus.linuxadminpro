#!/bin/bash

# куда будем маунтить
mkdir -p /mnt/10_share

# правим fstab
echo "192.168.50.10:/mnt/nfs_share /mnt/10_share nfs noauto,x-systemd.automount,proto=udp,vers=3 0 0" >> /etc/fstab

reboot
