# ДЗ 07. Управление пакетами. Дистрибьюция софта

Собираем RPM nginx c дополнительным модулем для kerberos аутентификации https://github.com/stnoonan/spnego-http-auth-nginx-module

VM провижиниться vagrant-ом и скриптом [`provision.sh`](provision.sh).

По итогу у нас: 
- создан RMP с доп.подулем
- установлен локально 
- создан репозиторий 
- туда добавлен модифицированный nginx и mc
- mc устанолвен из репозитория 

<br>

```
    vm: ================================================================================
    vm:  Package      Arch             Version                     Repository      Size
    vm: ================================================================================
    vm: Installing:
    vm:  mc           x86_64           1:4.8.7-11.el7              otus           1.7 M
    vm:
    vm: Transaction Summary
    vm: ================================================================================
    vm: Install  1 Package
    vm:
    vm: Total download size: 1.7 M
    vm: Installed size: 5.6 M
    vm: Downloading packages:
    vm: Running transaction check
    vm: Running transaction test
    vm: Transaction test succeeded
    vm: Running transaction
    vm:   Installing : 1:mc-4.8.7-11.el7.x86_64                                     1/1
    vm:
    vm:   Verifying  : 1:mc-4.8.7-11.el7.x86_64                                     1/1
    vm:
    vm:
    vm: Installed:
    vm:   mc.x86_64 1:4.8.7-11.el7
    vm:
    vm: Complete!
```





