# ДЗ 20. Настраиваем split-dns

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

## Готовим лабу
1. По условиям задачи надо добавить в лабу еще одного клиента (client2), добавляем в [Vagrantfile](Vagrantfile), плюс я на Windows и у меня не работает on-host Ansible -> меняем в конфиге на ```"ansible_local"```
```sh
...
  config.vm.provision "ansible_local" do |ansible|
...
  config.vm.define "client2" do |client|
    client.vm.network "private_network", ip: "192.168.50.16", virtualbox__intnet: "dns"
    client.vm.hostname = "client2"
  end
```
2. Не работают динамичекие апдейты. Чиним как в [лабе](https://github.com/BerdnikovAE/otus.linuxadminpro/tree/main/13) по SELinux (или отключением ```setenforce=0```). Не уверен что правильно мне ту лабу еще не зачли.
```sh
cat /var/log/audit/audit.log | grep named | audit2allow -M named
semodule -i named.pp
systemctl restart named
```
3. Проверяем, что всё ок: динамические апдейты работают, репликация работает.
```sh
# на client делаем апдейт на первый сервер ns01
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.17
> send
> quit

# на client2 спрашиваем ns02
[vagrant@client2 ~]$ dig @192.168.50.11 ddns.lab www.ddns.lab. +short
192.168.50.17
```

## Теперь задание

1. завести в зоне dns.lab имена
  * web1 - смотрит на клиент1
  * web2 смотрит на клиент2

2. завести еще одну зону newdns.lab 
  * www - смотрит на обоих клиентов

3. настроить split-dns
  * клиент1 - видит обе зоны, но в зоне dns.lab только web1
  * клиент2 видит только dns.lab

п.2 и п.3 выполнен 

``` sh
#/etc/named.conf
acl "cl1" { 192.168.50.15; };

view "new" {
        match-clients { "cl1"; };

        // newdns
        zone "newdns.lab" {
                type master;
                allow-transfer { key "zonetransfer.key"; };
                file "/etc/named/named.newdns.lab";
        };
};

view "old" {

        match-clients { any; };

        // root zone
        zone "." IN {
                type hint;
                file "named.ca";
        };


        // zones like localhost
        include "/etc/named.rfc1912.zones";
        // root's DNSKEY
        include "/etc/named.root.key";


        // lab's zone
        zone "dns.lab" {
            type master;
            allow-transfer { key "zonetransfer.key"; };
            file "/etc/named/named.dns.lab";
        };

        // lab's zone reverse
        zone "50.168.192.in-addr.arpa" {
            type master;
            allow-transfer { key "zonetransfer.key"; };
            file "/etc/named/named.dns.lab.rev";
        };

        // lab's ddns zone
        zone "ddns.lab" {
            type master;
            allow-transfer { key "zonetransfer.key"; };
            allow-update { key "zonetransfer.key"; };
            file "/etc/named/named.ddns.lab";
        };
};
```

проверяем п.2 и п.3.
```sh
[vagrant@client2 ~]$ dig @192.168.50.10 www.newdns.lab +short
[vagrant@client2 ~]$

[root@client vagrant]$ dig @192.168.50.10 www.newdns.lab +short
192.168.50.16
192.168.50.15
```

