# ДЗ 11. PAM

Задача:  
    Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

Решение:  
    Видимо через /etc/security/time.conf не сделать, т.к. там можно указывать только пользоватлей. Придется делать через pam_exec.so

VM запускается со скриптом [provision.sh](provision.sh).
Проверять логин будет [test.sh](test.sh)

Проверяем:
    Два пользователя:
        - user_ok - в группе admin_group и ему можно по выходным работать 
        - user_not_ok - не в группе

    На время проверки в [test.sh](test.sh) сделал проверку не выходных, а вторника (сегодня)

    
```bash
> vagrant ssh

#подключаемся пользователем, который может работать по вторникам
[vagrant@vm ~]$ ssh user_ok@localhost
The authenticity of host 'localhost (::1)' can't be established.
ECDSA key fingerprint is SHA256:kdiUeSqyWSkhO83b3FUUDqxP+wYkeb8FCGqJlYHFufI.
ECDSA key fingerprint is MD5:96:1f:e6:69:c3:26:1a:2e:a4:48:6c:14:23:df:67:cb.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
user_ok@localhost's password:
[user_ok@vm ~]$ logout
Connection to localhost closed.

#подключаемся пользователем, который НЕ может работать по вторникам
[vagrant@vm ~]$ ssh user_not_ok@localhost
user_not_ok@localhost's password:
/usr/local/sbin/test.sh failed: exit code 1
Authentication failed.
[vagrant@vm ~]$
```