
# ставим нужное
yum install -y mailx

# запускать будем раз в минуту чтоб не скучно смотреть 
echo "*/1 * * * * /vagrant/logparser.sh" | crontab

