# ДЗ 08. Bash

VM провижинится скриптом [provision.sh](provision.sh):

```sh
yum install -y mailx
echo "*/1 * * * * /vagrant/logparser.sh" | crontab
```

Скрипт [logparser.sh](logparser.sh) запускается каждую минуту (чтоб не долго не ждать).

После старта vm можно подключится и проверить что там происходит:

```sh
>  vagrant ssh
[vagrant@vm ~]$ cd /vagrant/
[vagrant@vm vagrant]$ cat logparser.heartbeat
Tue Dec 8 17:37:01 UTC 2020
Ничего нового в логах за последний период
```
логично, пока мы подключались скри пт сработал уже более одного раза и обработал файл, а нового ничего туда не попало.<br>


Добавим в лог немного записей и посмотрим на результат: 
```sh
[vagrant@vm vagrant]$ cat access-4560-644067.log | head -n 1000 >> access-4560-644067.log
[vagrant@vm vagrant]$ cat logparser.heartbeat
Tue Dec 8 17:38:01 UTC 2020
Начало периода: 14/Aug/2019:04:12:10
Конец периода: 14/Aug/2019:13:49:02
# топ 5 IP адресов
     78 109.236.252.130
     67 93.158.167.130
     66 188.43.241.106
     45 87.250.233.68
     37 212.57.117.19
# топ 5 адресов
    233 /
    171 /wp-login.php
     80 /xmlrpc.php
     37 /robots.txt
     17 /favicon.ico
# все ошибки
     81 404
     14 400
      4 500
      3 499
      2 403
      1 405
# список всех кодов возврата
    732 200
    148 301
     81 404
     14 400
     14 "-"
      4 500
      3 499
      2 403
      1 405
      1 304
[vagrant@vm vagrant]$
```

Спустя минуту снова пусто 
```
[vagrant@vm vagrant]$ cat logparser.heartbeat
Tue Dec 8 17:39:01 UTC 2020
Ничего нового в логах за последний период
[vagrant@vm vagrant]$
```

