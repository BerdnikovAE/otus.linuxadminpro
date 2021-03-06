#!/bin/bash

sudo su

#утилиты для SELinux
yum install -y setools-console policycoreutils-python

#nginx
yum install -y epel-release
yum install -y nginx
systemctl start nginx.service

# есть порт 80
ss -tunlp | grep nginx
#правим конфиг nginx
sed -i 's/listen       80 default_server/listen       8088 default_server/g' /etc/nginx/nginx.conf
sed -i 's/listen       \[\:\:\]\:80 default_server/listen       \[\:\:\]\:8088 default_server/g' /etc/nginx/nginx.conf

#старуем - получаем ошибку 
systemctl restart nginx
#смотрим на ошибку и там же подсказка 
# vm:         Allow access by executing:
# vm:         # setsebool -P nis_enabled 1
audit2why < /var/log/audit/audit.log

# cпособ 1
#правим semanage boolean
setsebool -P nis_enabled 1
systemctl restart nginx
#проверяем, есть порт 8088
ss -tunlp | grep *.8088
#возвращаем как было 
setsebool -P nis_enabled 0

# cпособ 2
semanage port -a -t http_port_t -p tcp 8088
# пример прямо в man: https://man7.org/linux/man-pages/man8/semanage-port.8.html
systemctl restart nginx
#проверяем, есть порт 8088
ss -tunlp | grep *.8088
#возвращаем как было 
semanage port -d -t http_port_t -p tcp 8088

# cпособ 3
# стартанем чтоб была ошибка
systemctl restart nginx
# используем генератор политик по этой ошибке (см. https://www.nginx.com/blog/using-nginx-plus-with-selinux/)
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
# применим 
semodule -i nginx.pp
systemctl restart nginx
#проверяем, есть порт 8088
ss -tunlp | grep *.8088



