# ДЗ 08. ZFS

## 0.Установим ZFS 

```sh
sudo su
# смотрим нашу версию 
cat /etc/redhat-release
# качаем версию для нашего ядра 
yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
#  выбираем режим установки kABI-tracking kmod
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
# ставим
yum install -y zfs
# загружаем
/sbin/modprobe zfs
```

## 1. Определить алгоритм с наилучшим сжатием

ZFS умеет сжатие ```lzjb | gzip | gzip-[1-9] | zle | lz4```

```sh
zpool create zfs_001 mirror sdb sdc
zfs list

zfs create zfs_001/zfs_fs_001
zfs create zfs_001/zfs_fs_002
zfs create zfs_001/zfs_fs_003
zfs create zfs_001/zfs_fs_004

zfs set compression=lzjb zfs_001/zfs_fs_001
zfs set compression=gzip zfs_001/zfs_fs_002
zfs set compression=zle zfs_001/zfs_fs_003
zfs set compression=lz4 zfs_001/zfs_fs_004

wget -O /zfs_001/zfs_fs_001/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /zfs_001/zfs_fs_002/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /zfs_001/zfs_fs_003/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /zfs_001/zfs_fs_004/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8

zfs list
```

вывод
```
NAME                 USED  AVAIL     REFER  MOUNTPOINT
zfs_001             4.87M   107M       28K  /zfs_001
zfs_001/zfs_fs_001  1.19M   107M     1.19M  /zfs_001/zfs_fs_001
zfs_001/zfs_fs_002  1.18M   107M     1.18M  /zfs_001/zfs_fs_002
zfs_001/zfs_fs_003  1.18M   107M     1.18M  /zfs_001/zfs_fs_003
zfs_001/zfs_fs_004  1.18M   107M     1.18M  /zfs_001/zfs_fs_004
```

## 2. Определить настройки pool’a

```sh   
# качаем, смотрим что там 
wget -qO zfs_task1.tar.gz "https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download"
tar -xvf zfs_task1.tar.gz
ls -l
ls -l zpoolexport/
zpool import -d ./zpoolexport/

# импортируем 
zpool import -d ./zpoolexport/ otus
zpool list
zpool status
df

# смотрим размер пулов 
zpool list -o name,size

# размер файловых структур
zfs list -o name,avail | grep otus

# всякие своства полезные 
zfs get all | grep otus | grep ' available \| type \| recordsize \| compression \| checksum'
```

результат
```sh
[root@otuslinux vagrant]# zpool list -o name,size
NAME      SIZE
otus      480M
zfs_001   224M
[root@otuslinux vagrant]# zfs list -o name,avail | grep otus
otus                 347M
otus/hometask2       347M
otus/storage         347M
[root@otuslinux vagrant]# zfs get all | grep otus | grep ' available \| type \| recordsize \| compression \| checksum'
otus                type                  filesystem             -
otus                available             347M                   -
otus                recordsize            128K                   local
otus                checksum              sha256                 local
otus                compression           zle                    local
otus/hometask2      type                  filesystem             -
otus/hometask2      available             347M                   -
otus/hometask2      recordsize            128K                   inherited from otus
otus/hometask2      checksum              sha256                 inherited from otus
otus/hometask2      compression           zle                    inherited from otus
otus/storage        type                  filesystem             -
otus/storage        available             347M                   -
otus/storage        recordsize            128K                   inherited from otus
otus/storage        checksum              sha256                 inherited from otus
otus/storage        compression           zle                    inherited from otus
otus/storage@task2  type                  snapshot               -
```


## 3. Найти сообщение от преподавателей
```sh
#
wget -qO otus_task2.file "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
ls -la
# применяем backup 
zfs receive otus/storage@task2 < otus_task2.file
# откатывает в нем снэпшот
zfs rollback otus/storage@task2

# смотрим мессадж
ls /otus/storage/task1/file_mess/secret_message
cat /otus/storage/task1/file_mess/secret_message
```
Результат
```sh
[root@otuslinux vagrant]# cat /otus/storage/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```





