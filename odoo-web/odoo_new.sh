#!/bin/bash

#YYOGestiono New Deployment


NEW_PROJECT_NAME=${PWD##*/}

#Import variables
echo '>>>Import variables: '
export $(grep -v '^#' .env | xargs)


##Rectifying Configuration on config/odoo.conf
#Comment db_host definition on odoo.conf
echo '>>>Comment db_host definition on odoo.conf: '
#Erase Database Host declaration
sed -i 's/^db_host/;db_host/g' ./odoo/config/odoo.conf
#Set Master Pasword
sed -i s|^admin_passwd = .*|admin_passwd = ${ADMIN_PASSWORD}| ./odoo/config/odoo.conf
#set  dbfilter
sed -i s/^dbfilter = .*/dbfilter = ${ODOO_DATABASE}/ ./odoo/config/odoo.conf


# Docker-compose UP
echo '>>>UP Docker-compose: '
docker compose up -d
sleep 30

#Satisfacer dependencias
if  [ -n ${ODOO_DEPENDENCIES} ]; then \
docker container exec -u root ${NEW_PROJECT_NAME}-web-1 bash -c 'apt install -y python3-pip; yes | pip3 install lxml xlrd xlsxwriter openpyxl google-auth html2text'; \
fi

#Schedule a weekly SSL cert update
cp ./cron.weekly/*_certbot_renew.sh /etc/cron.weekly/
chmod +x /etc/cron.weekly/*_certbot_renew.sh