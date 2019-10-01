# Make Directories
sudo mkdir /var/www/html/repository
sudo mkdir /var/repo
sudo chown www-data /var/repo

# Update packages
sudo apt update

# Install apache
sudo apt install apache2 -y

# Intstall maria
sudo apt-get install mariadb-server mariadb-client -y

# Setup MYSQL
read -p "Enter new password for SQL: " sqlpswd
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$sqlpswd') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"

# Install common
sudo apt-get install software-properties-common -y
sudo apt install curl -y
# Add repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
# Install PHP & MISC
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-curl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-json php7.2-cli php7.0-apcu -y
# Install extras
sudo apt install git -y
sudo apt-get install python-pygments -y
sudo apt install imagemagick -y

# Update PHP.ini
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/php.ini -o /etc/php/7.2/apache2/php.ini
sudo /etc/init.d/apache2 restart

# Install phabricator
sudo mkdir /var/www/html/repository
cd /var/www/html/repository
sudo git clone https://github.com/phacility/libphutil.git
sudo git clone https://github.com/phacility/arcanist.git
sudo git clone https://github.com/phacility/phabricator.git

# Update tables
cd /var/www/html/repository/phabricator
sudo ./bin/config set mysql.host localhost
sudo ./bin/config set mysql.user root
sudo ./bin/config set mysql.pass $sqlpswd
sudo ./bin/storage upgrade --user root --password $sqlpswd

# Configure apache virutal hosts
read -p "Enter address URL for your site with no trailing /'s: " siteid
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/phab-template.conf -o /etc/apache2/sites-available/phabricator.conf
sudo sed -i "s/ServerName replaceme/ServerName $siteid/g" /etc/apache2/sites-available/phabricator.conf
sudo a2ensite phabricator.conf
sudo a2enmod rewrite
sudo /etc/init.d/apache2 restart

# fix permissions
sudo chown -R www-data:www-data /var/www/html/repository/phabricator/
sudo chmod -R 755 /var/www/html/repository/phabricator/

# Configure Phabricator Post Tasks
read -p "Enter storage folder name: " storpath
sudo mkdir /var/$storpath
sudo chown www-data /var/$storpath

# Configure Phab Settings
cd /var/www/html/repository/phabricator
sudo ./bin/config set storage.local-disk.path /var/$storpath
sudo ./bin/config set files.enable-imagemagick true
sudo ./bin/config set phabricator.base-uri http://"$siteid"
sudo ./bin/config set phabricator.developer-mode true
sudo ./bin/config set pygments.enabled true

# SQL Changes
sudo rm /etc/mysql/my.cnf
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/my.cnf -o /etc/mysql/my.cnf

# Restart everything
sudo /etc/init.d/mysql restart
sudo /etc/init.d/apache2 restart
