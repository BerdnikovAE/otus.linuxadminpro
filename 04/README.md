# ДЗ 04. NFS, FUSE

Две VM создаются [Vagrantfile](Vagrantfile) и провижнятся скриптами:<br>

   - VM server (```nfss```)  скриптом [```nfss_script.sh```](nfss_script.sh)<br>
   - VM client (```nfsc```)  скриптом [```nfsc_script.sh```](nfsc_script.sh)<br>

После настройки можно проверить:
```sh
> vagrant ssh nfsc
Last login: Thu Nov 19 13:29:10 2020 from 10.0.2.2
[vagrant@nfsc ~]$ "test" >> /mnt/10_share/upload/test.txt
[vagrant@nfsc ~]$ ls -la /mnt/10_share/upload/
total 0
drwxrwxrwx. 2 root    root    22 Nov 19 13:29 .
dr-xr-xr-x. 3 root    root    20 Nov 19 13:28 ..
-rw-rw-r--. 1 vagrant vagrant  0 Nov 19 13:29 test.txt
```
