sudo apt update
sudo apt install apache2 -y
sudo apt-get install mariadb-server mariadb-client -y
sudo mysql_secure_installation
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-curl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-json php7.2-cli php7.0-apcu -y
sudo mkdir /var/www/html/repository
cd /var/www/html/repository
sudo apt install git
sudo git clone https://github.com/phacility/libphutil.git
sudo git clone https://github.com/phacility/arcanist.git
sudo git clone https://github.com/phacility/phabricator.git

# Update PHP.ini
sudo sed -i 's/file_uploads = Off/file_uploads = On/g' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/g' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/7.2/apache2/php.ini

# Configure Phabricator Post Tasks
read -p "Enter storage folder name: " storpath
sudo mkdir /var/$storpath
sudo chown www-data /var/$storpath
cd /var/www/html/repository/phabricator
sudo ./bin/config set storage.local-disk.path $storpath
sudo ./bin/config set files.enable-imagemagick true

# Install imagemagick and support
sudo apt install imagemagick

# Configure apache virutal hosts
read -p "Enter address URL for your site: " siteID
sudo cp ~/phabricator-temp.conf /etc/apache2/sites-available/phabricator.conf
sudo sed -i 's/ServerName example.com/ServerName $siteID/g' /etc/apache2/sites-available/phabricator.conf
