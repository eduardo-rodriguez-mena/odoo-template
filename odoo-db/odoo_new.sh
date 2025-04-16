#!/bin/bash

#YYOGestiono New Deployment


NEW_PROJECT_NAME=${PWD##*/}

#Move to Project Directory

#Import variables
echo '>>>Import variables: '
export $(grep -v '^#' .env | xargs)


# Docker-compose UP
echo '>>>UP Docker-compose: '
docker compose up -d
sleep 30

#Satisfacer dependencias
if  [ -n ${ODOO_DEPENDENCIES} ]; then \
docker container exec -u root ${NEW_PROJECT_NAME}_web_1 bash -c 'apt install -y python3-pip; yes | pip3 install lxml xlrd xlsxwriter openpyxl google-auth html2text'; \
fi

#Schedule a weekly SSL cert update
cp ./cron.weekly/*_certbot_renew.sh /etc/cron.weekly/
chmod +x /etc/cron.weekly/*_certbot_renew.sh