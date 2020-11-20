
## 0.Установим ZFS 
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

# тоже пригодится
yum install -y wget



## 1. Определить алгоритм с наилучшим сжатием
# создаем пул-зеркало 
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


# качаем 50 книжек
for i in {1..50}; do echo "Download $i/50 book"; wget -qO /zfs_001/zfs_fs_001/$i.txt http://www.gutenberg.org/ebooks/$i.txt.utf-8; done

# раскладываем их в остальлыные 3 папки 
cp /zfs_001/zfs_fs_001/* /zfs_001/zfs_fs_002
cp /zfs_001/zfs_fs_001/* /zfs_001/zfs_fs_003
cp /zfs_001/zfs_fs_001/* /zfs_001/zfs_fs_004

# смотрим на объем
zfs list
# смотрим на качество компрессии
zfs get compressratio,compression /zfs_001/zfs_fs_00{1..4}




## 2. Определить настройки pool’a
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

## 3. Найти сообщение от преподавателей
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
