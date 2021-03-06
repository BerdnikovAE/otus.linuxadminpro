# 20. настраиваем split-dns

Лаба для ДЗ взята тут https://github.com/erlong15/vagrant-bind
В лабе следующая конфигурация vm:

  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key


добавлен еще в Vagrantfile 
  * client2 (192.168.50.16)
    * used to test the env, runs rndc and nsupdate


