echo "Updating some packages"
#update packages
sudo apt update

echo "Installing apache, standby..."
# INSTALL APACHE2
sudo apt install apache2 -y

echo "Installing mariadb"
# INSTALL MARIADB
sudo apt-get install mariadb-server mariadb-client -y

# ADD REPOSITORY
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
# INSTALL EXTRA PACKAGES
sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl software-properties-common curl git imagemagick -y

# SETUP MYSQL
read -p "Enter new password for SQL: " sqlpswd
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$sqlpswd') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP DATABASE test"
mysql -e "CREATE DATABASE mediawiki"
mysql -e "CREATE DATABASE cargo"
mysql -e "GRANT ALL PRIVILEGES ON mediawiki.* TO 'root'@'localhost';"
mysql -e "GRANT ALL PRIVILEGES ON cargo.* TO 'root'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "copying php settings from github"
# Update PHP.ini
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/php.ini -o /etc/php/7.2/apache2/php.ini
sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sudo /etc/init.d/apache2 restart

echo "Configuring virtual hosts"
# Configure apache virutal hosts
read -p "Enter address URL for your site with no trailing /'s: " siteid
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/phab-template.conf -o /etc/apache2/sites-available/mediawiki.conf
#sudo rm /etc/apache2/sites-enabled/000-default.conf
#sudo rm /etc/apache2/sites-available/000-default.conf
sudo sed -i "s/ServerName replaceme/ServerName $siteid/g" /etc/apache2/sites-available/mediawiki.conf
sudo a2ensite mediawiki.conf
sudo a2enmod rewrite
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

echo "OK... Should be good to go..."
