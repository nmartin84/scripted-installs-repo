phab_path = /var/www/html/repository/phabricator/

# Update packages
sudo apt update
# Install apache
sudo apt install apache2 -y
# Intstall maria
sudo apt-get install mariadb-server mariadb-client -y
# Install common
sudo apt-get install software-properties-common -y
# Add repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
# Install PHP & MISC
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-curl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-json php7.2-cli php7.0-apcu -y
sudo apt install git -y
sudo apt install curl -y
sudo apt-get install python-pygments -y
# Install imagemagick and support
sudo apt install imagemagick

# Setup MYSQL
read -p "Enter new password for SQL: " sqlpswd
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$sqlpswd') WHERE User = 'root'"
mysql -e "DROP USER ''@'localhost'"
mysql -e "DROP USER ''@'$(hostname)'"
mysql -e "DROP DATABASE test"
mysql -e "FLUSH PRIVILEGES"

# Configure apache virutal hosts
read -p "Enter address URL for your site with no trailing /'s: " siteID
sudo curl /phab-template.conf -o /etc/apache2/sites-available/phabricator.conf
sudo sed -i 's/ServerName replaceme/ServerName $siteID/g' /etc/apache2/sites-available/phabricator.conf

# Install phabricator
sudo mkdir /var/www/html/repository
cd /var/www/html/repository
sudo git clone https://github.com/phacility/libphutil.git
sudo git clone https://github.com/phacility/arcanist.git
sudo git clone https://github.com/phacility/phabricator.git

# Update PHP.ini
sudo curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/php.ini -o /etc/php/7.2/apache2/php.ini

# Configure Phabricator Post Tasks
read -p "Enter storage folder name: " storpath
sudo mkdir /var/$storpath
sudo chown www-data /var/$storpath

# Configure Repo Directory
sudo mkdir /var/repo
sudo chown www-data /var/repo

# Configure Phab Settings
cd $phab_path
sudo var/www/html/repository/phabricator/bin/config set storage.local-disk.path /var/$storpath
sudo var/www/html/repository/phabricator/bin/config set files.enable-imagemagick true
sudo var/www/html/repository/phabricator/bin/config set phabricator.base-uri 'http://$siteID/'
sudo var/www/html/repository/phabricator/bin/config set phabricator.developer-mode true
sudo var/www/html/repository/phabricator/bin/config set pygments.enabled true

# SQL Changes
sudo rm /etc/mysql/my.cnf
sudo cp ~/phab-install/my.cnf /etc/mysql/my.cnf
