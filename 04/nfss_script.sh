# #!/bin/bash

# #Создаем папки и раздаем права
mkdir -p /mnt/nfs_share
mkdir -p /mnt/nfs_share/upload
chmod  555 /mnt/nfs_share
chmod  777 /mnt/nfs_share/upload/

# #Создаем шару 
echo "mnt/nfs_share    *(rw,nohide,sync,root_squash)" >> /etc/exports

# #Открываем порты
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=nfs3
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

#Запускаем сервисы 
systemctl enable nfs-server 
systemctl start nfs-server 
