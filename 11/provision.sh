#!/bin/bash

sudo su
#одному пользователю можно будет работать в выходной через группу
useradd user_ok
#другому нельзя
useradd user_not_ok

echo "psw" | passwd --stdin user_ok
echo "psw" | passwd --stdin user_not_ok

#группа для админов по выходным 
groupadd admin_group

gpasswd -a user_ok admin_group
gpasswd -a vagrant admin_group

cp /vagrant/test.sh /usr/local/sbin
chmod 544 /usr/local/sbin/test.sh

#разрешим логин в ssh по паролю
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service

#добавим обработчик для sshd
sed -i '8i\account required pam_exec.so /usr/local/sbin/test.sh' /etc/pam.d/sshd

#тольк на посмотреть и отдебажить
#sed -i '8i\account optional pam_exec.so stdout debug/usr/local/sbin/test2.sh' /etc/pam.d/sshd

