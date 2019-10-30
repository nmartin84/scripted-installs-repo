# Install packages
sudo apt update
sudo apt install apache2 -y
sudo apt-get install mariadb-server mariadb-client -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl software-properties-common curl git imagemagick -y
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# SETUP MYSQL
echo "Setting up 'mediawikiuser' account with GRANT all privileges in SQL"
read -p "Enter new password for SQL: " sqlpswd
sudo mysql -e "CREATE DATABASE mediawiki;"
sudo mysql -e "CREATE DATABASE cargo;"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'mediawikiuser'@'localhost' IDENTIFIED BY '$sqlpswd';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Configure APACHE"
# Configure apache virutal hosts
sudo sed -i "s#/html#/html/mediawiki#g" /etc/apache2/sites-available/000-default.conf
sudo curl https://raw.githubusercontent.com/nmartin84/scripted-installs-repo/master/mwiki/php.ini -o /etc/php/7.1/apache2/php.ini
sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sudo /etc/init.d/apache2 restart

echo "installing mediawiki..."
# Install mediawiki
sudo wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.0.tar.gz
sudo tar -xzf mediawiki-1.33.0.tar.gz
sudo mv mediawiki-1.33.0 mediawiki
sudo mv mediawiki /var/www/html/mediawiki
sudo chown -R www-data:www-data /var/www/html/mediawiki/
sudo chmod -R 755 /var/www/html/mediawiki/
cd /var/www/html/mediawiki/extensions
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-Cargo.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-PageForms.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-TemplateData.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-Echo.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-TextExtracts.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-PageImages.git
sudo git clone -b REL1_33 https://github.com/wikimedia/mediawiki-extensions-Popups.git

# RESTART EVERYTHING
sudo /etc/init.d/mysql restart
sudo /etc/init.d/apache2 restart

# Install parsoid container
sudo docker run -d -p 8080:8000 -e PARSOID_DOMAIN_localhost=http://localhost/api.php thenets/parsoid:0.10
