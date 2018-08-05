#!/bin/bash

# Enviroment variable
#
export MYSQL_PASS="pass@root"
export MACHINE_PASS="vagrant"


echo "(Setting up your Vagrant box...)"
echo "(Updating apt-get...)"
sudo ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime > /dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
sudo add-apt-repository -y ppa:webupd8team/java > /dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/nginx > /dev/null 2>&1
sudo add-apt-repository -y ppa:webupd8team/terminix > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1

echo "----------------------------------------------------------------------"

# Nginx
echo "(Installing Nginx...)"
sudo apt-get install -y nginx curl zsh git tilix > /dev/null 2>&1
sudo systemctl enable nginx > /dev/null 2>&1
sudo systemctl start nginx > /dev/null 2>&1
systemctl status nginx

echo "----------------------------------------------------------------------"

# Add user to www-data group
sudo usermod -a -G www-data vagrant
sudo mkdir /project
sudo chown -R vagrant:vagrant /project
sudo chmod -R 755 /project

# MariaDB
echo "(Installing MariaDB ...)"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MYSQL_PASS"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MYSQL_PASS"
sudo apt-get install -y mariadb-server > /dev/null 2>&1
sudo systemctl enable mysql > /dev/null 2>&1
sudo systemctl start mysql > /dev/null 2>&1

echo "grant all privileges on *.* to root@localhost identified by '$MYSQL_PASS';" | mysql -uroot -p$MYSQL_PASS -Dmysql > /dev/null 2>&1
echo "grant all privileges on *.* to root@127.0.0.1 identified by '$MYSQL_PASS';" | mysql -uroot -p$MYSQL_PASS -Dmysql > /dev/null 2>&1
echo "flush privileges;" | mysql -uroot -p$MYSQL_PASS -Dmysql > /dev/null 2>&1
sudo systemctl restart mysql
systemctl status mysql

echo "----------------------------------------------------------------------"

# PHP
echo "(Installing PHP ...)"

sudo apt-get install -y php7.1-fpm \
php7.1-cli \
php7.1-common \
php7.1-gd \
php7.1-mysql \
php7.1-mcrypt \
php7.1-curl \
php7.1-intl \
php7.1-xsl \
php7.1-mbstring \
php7.1-zip \
php7.1-bcmath \
php7.1-iconv \
php7.1-soap \
php7.1-xdebug > /dev/null 2>&1

sudo printf "
[XDEBUG]
zend_extension="/usr/lib/php/20160303/xdebug.so"
xdebug.remote_enable=1
xdebug.remote_handler=dbgp 
xdebug.remote_mode=req
xdebug.remote_host=127.0.0.1 
xdebug.remote_port=9000
" >> /etc/php/7.1/fpm/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 1800/g' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2G/g' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/post_max_size = 2G/post_max_size = 2G/g' /etc/php/7.1/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2G/g' /etc/php/7.1/fpm/php.ini

sudo systemctl enable php7.1-fpm > /dev/null 2>&1
sudo systemctl start php7.1-fpm > /dev/null 2>&1
sudo systemctl restart nginx > /dev/null 2>&1

php -v
echo "----------------------------------------------------------------------"

# Composer
echo "Installing Composer ..."
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer > /dev/null 2>&1
composer

echo "----------------------------------------------------------------------"

# PHPStorm
echo "Installing PHPstorm ..."
wget https://download.jetbrains.com/webide/PhpStorm-2018.2.tar.gz > /dev/null 2>&1
sudo tar xfz PhpStorm-*.tar.gz -C /opt/ > /dev/null 2>&1
rm PhpStorm-*.tar.gz > /dev/null 2>&1
sudo mv /opt/Php* /opt/phpstorm > /dev/null 2>&1

echo "----------------------------------------------------------------------"

# Remove default app
echo "Removing default app ..."
sudo apt remove -y --purge gnome-terminal xterm firefox > /dev/null 2>&1
sudo apt autoremove -y > /dev/null 2>&1
sudo apt clean > /dev/null 2>&1
sudo update-alternatives --config x-terminal-emulator > /dev/null 2>&1

echo "----------------------------------------------------------------------"

echo "(Setting Ubuntu (user) password to \"vagrant\"...)"

echo "vagrant:$MACHINE_PASS" | chpasswd


echo "+---------------------------------------------------------+"
echo "|                      S U C C E S S                      |"
echo "+---------------------------------------------------------+"
echo "|   You're good to go! You can now view your server at    |"
echo "|                 \"127.0.0.1/\" in a browser.            |"
echo "|                                                         |"
echo "|  If you haven't already, I would suggest editing your   |"
echo "|     hosts file with \"127.0.0.1  projectname.vagrant\"  |"
echo "|         so that you can view your server with           |"
echo "|    \"projectname.vagrant/\" instead of \"127.0.0.1/\"   |"
echo "|                      in a browser.                      |"
echo "|                                                         |"
echo "|   First start phpstorm: /opt/phpstorm/bin/phpstorm.sh   |"
echo "|                                                         |"
echo "|          You can SSH in with vagrant / vagrant          |"
echo "|                                                         |"
echo "|      You can login to MySQL with root / $MYSQL_PASS     |"
echo "+---------------------------------------------------------+"