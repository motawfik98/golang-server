#!/bin/bash

sudo apt install -y apache2
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo ufw allow 'Apache'
sudo mkdir /var/www/devops
sudo chown -R $USER:$USER /var/www/devops
sudo chmod -R 755 /var/www/devops
cd /var/www/devops && sudo touch stderr.log stdout.log
cd /etc/apache2/sites-available && touch devops.conf

echo "
NameVirtualHost *:80
<VirtualHost *:80>
       ServerAdmin webmaster@localhost

       ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined

       ProxyPreserveHost On
       ServerName ec2-35-158-111-55.eu-central-1.compute.amazonaws.com
       ServerAlias www.ec2-35-158-111-55.eu-central-1.compute.amazonaws.com
       ProxyPass / http://localhost:3000/
       ProxyPassReverse / http://localhost:3000/


RewriteEngine on
RewriteCond %{SERVER_NAME} =www.ec2-35-158-111-55.eu-central-1.compute.amazonaws.com [OR]
RewriteCond %{SERVER_NAME} =ec2-35-158-111-55.eu-central-1.compute.amazonaws.com
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" | sudo tee devops.conf
sudo a2ensite devops.conf
sudo a2dissite 000-default.conf

cd /etc/systemd/system && sudo touch devops.service
echo "
[Unit]
Description = DevOps API

[Service]
WorkingDirectory=/var/www/devops
ExecStart=/var/www/devops/devops-cicd
User =ubuntu
Group =ubuntu
Restart =always
StandardOutput=append:/var/www/devops/stdout.log
StandardError=append:/var/www/devops/stderr.log

[Install]
WantedBy=multi-user.target" | sudo tee devops.service
sudo systemctl restart apache2
sudo systemctl start devops.service
