#!/bin/bash
apt update
apt install -y postgresql postgresql-contrib
pg_isready
systemctl status postgresql
echo -e "postgres\npostgres" | passwd postgres
sudo -u postgres -i psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
#cat /etc/postgresql/11/main/postgresql.conf
#cat /etc/postgresql/11/main/pg_hba.conf
#sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres -i psql -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
sudo -u postgres createdb -O zabbix zabbix

apt install -y nginx

wget https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-1+buster_all.deb
dpkg -i zabbix-release_5.0-1+buster_all.deb
apt update
apt install -y zabbix-server-pgsql zabbix-frontend-php php7.3-pgsql zabbix-nginx-conf zabbix-agent

zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix

#DBPassword=zabbix
sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

#uncommect # listen 80;
sed -i 's/#        listen          80;/        listen          80 default_server;/g' /etc/zabbix/nginx.conf
sed -i 's/listen 80 default_server;/listen 80;/g' /etc/nginx/sites-enabled/default

#php_value[date.timezone] = Asia/Yekaterinburg
sed -i 's/; php_value\[date.timezone\] = Europe\/Riga/php_value\[date.timezone\] = Asia\/Yekaterinburg/g' /etc/zabbix/php-fpm.conf

systemctl restart zabbix-server zabbix-agent nginx php7.3-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.3-fpm
