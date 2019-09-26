# How to install
Pull this file to your box with curl or save it locally  
```
curl https://raw.githubusercontent.com/nmartin84/phabricator-install/master/install.sh -o ~/install.sh
```  

Then run  
```
sudo chmod go+x ~/install.sh
```  
followed by  
```
sudo ~/install.sh
```
Once completed you will need to run the following sql queries before phabricator will work
```
sudo mysql -u root
use mysql;
update user set plugin='' where User='root';
flush privileges;
Exit
```
