# Vagrant DNS Lab

A Bind's DNS lab with Vagrant and Ansible, based on CentOS 7.

# Playground

<code>
    vagrant ssh client
</code>

  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key


==
Для Ansible под Windows правим исходный файл:

PS > wget -usebasicparsing https://gist.githubusercontent.com/tknerr/140fe6431953cc7dddfd/raw/install_ansible.sh -o install_ansible.sh

