# ДЗ 12. Практика с SELinux

## Часть 1
в скрипте [provision.sh](provision.sh) последовательно прогоняются все три варинта решения и три раза получаем работающий nginx
```sh
# 1
# setsebool -P nis_enabled 1
    vm: tcp    LISTEN     0      128       *:8088                  *:*
   users:(("nginx",pid=3501,fd=6),("nginx",pid=3500,fd=6))

# 2 
# semanage port -a -t http_port_t -p tcp 8088
    vm: tcp    LISTEN     0      128       *:8088                  *:*
   users:(("nginx",pid=3525,fd=6),("nginx",pid=3524,fd=6))

# 3 
# rep nginx /var/log/audit/audit.log | audit2allow -M nginx
    vm: tcp    LISTEN     0      128       *:8088                  *:*
   users:(("nginx",pid=3562,fd=6),("nginx",pid=3561,fd=6))
```

## Часть 2
Копируем лабу https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems

[Описание задания в самой лабе](selinux_dns/otus-linux-adm/selinux_dns_problems/README.md)


Запускаем клиент, пробуем делать update - ошибка:
```sh
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
``` 
Идем на сервер 
```sh
#смотрим ошибки
grep named /var/log/audit/audit.log
...
type=AVC msg=audit(1615035009.612:72): avc:  denied  { create } for  pid=1453 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0
...
#используем магию изготовления политики
grep named /var/log/audit/audit.log | audit2allow -M named
#применяем
semodule -i named.pp
```
Идем на клиента, проверяем...
```sh
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.17
> send
> quit

[vagrant@client ~]$ dig @192.168.50.10 www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.4 <<>> @192.168.50.10 www.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26242
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.17

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sat Mar 06 16:58:21 UTC 2021
;; MSG SIZE  rcvd: 128
```
Всё работает.

