
# ставим нужное
yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
git \
gcc

cd /root
# качаем исходники nginx
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-2.el7.ngx.src.rpm

# качаем модуль поддержки kerberos аутентификации для nginx
git clone https://github.com/stnoonan/spnego-http-auth-nginx-module

# разворачиваем дерево каталогов
rpm -i nginx-1.18.0-2.el7.ngx.src.rpm

# добавляем модуль в спеку 
sed -i '130 a\   --add-module=/root/spnego-http-auth-nginx-module \\' /root/rpmbuild/SPECS/nginx.spec
sed -i '124 a\   --add-module=/root/spnego-http-auth-nginx-module \\' /root/rpmbuild/SPECS/nginx.spec

# ставим зависимости, если есть 
yum-builddep rpmbuild/SPECS/nginx.spec -y 

# собираем rpm
rpmbuild -bb rpmbuild/SPECS/nginx.spec 

# устанавливаем то что получислоь после сборки 
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm

# Создаем папку для репозитория
mkdir -p /usr/share/nginx/html/repo

# копируем туда rpm 
cp /root/rpmbuild/RPMS/x86_64/* /usr/share/nginx/html/repo/
# добавлем еще mc
wget -O /usr/share/nginx/html/repo/mc-4.8.7-11.el7.x86_64.rpm http://mirror.centos.org/centos/7/os/x86_64/Packages/mc-4.8.7-11.el7.x86_64.rpm

#показываем файлы в каталоге nginx
sed -i '8a\         autoindex on\;' /etc/nginx/conf.d/default.conf

#создаем репозиторий в папке nginx
createrepo /usr/share/nginx/html/repo/

# регистрируем свой репозиторий
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

# запускаем nginx
systemctl start nginx

# установим dependenses для mc
yum install gpm-libs -y

# установимм из своего репозитория mc
yum --disablerepo="*" --enablerepo="otus" install mc -y
