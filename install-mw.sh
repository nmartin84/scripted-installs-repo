#Install packages
sudo apt update
sudo apt install apache2 -y
sudo apt-get install mariadb-server mariadb-client -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl software-properties-common curl git imagemagick -y

# SETUP MYSQL
read -p "Enter new password for SQL: " sqlpswd
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$sqlpswd') WHERE User = 'root'"
sudo mysql -e "CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "DROP USER ''@'localhost'"
sudo mysql -e "DROP DATABASE test"
sudo mysql -e "CREATE DATABASE mediawiki"
sudo mysql -e "CREATE DATABASE cargo"
sudo mysql -e "GRANT ALL PRIVILEGES ON mediawiki.* TO 'mediawikiuser'@'localhost';"
sudo mysql -e "GRANT ALL PRIVILEGES ON cargo.* TO 'mediawikiuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "copying php settings from github"
# Update PHP.ini
sudo curl https://raw.githubusercontent.com/nmartin84/scripted-installs-repo/master/mwiki/php.ini -o /etc/php/7.1/apache2/php.ini
sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sudo /etc/init.d/apache2 restart

echo "Configuring virtual hosts"
# Configure apache virutal hosts
sudo sed -i 's#html/#html/mediawiki#' /etc/apache2/sites-available/000-default.conf
sudo /etc/init.d/apache2 restart

echo "installing mediawiki..."
# Install mediawiki
sudo wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.0.tar.gz
sudo tar -xzf mediawiki-1.33.0.tar.gz
sudo mv mediawiki-1.33.0 mediawiki
sudo mv mediawiki /var/www/html/mediawiki
sudo chown -R www-data:www-data /var/www/html/mediawiki/
sudo chmod -R 755 /var/www/html/mediawiki/

# RESTART EVERYTHING
sudo /etc/init.d/mysql restart
sudo /etc/init.d/apache2 restart

echo "DONE... Cloning and configuring extensions next."

sudo git clone
