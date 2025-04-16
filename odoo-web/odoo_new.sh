#!/bin/bash

#YYOGestiono Deployment and Migration Script


NEW_PROJECT_NAME=${PWD##*/}

#Move to Project Directory

#Import variables
echo '>>>Import variables: '
export $(grep -v '^#' .env | xargs)

# #Copying Old Docker-Compose Project, clear unknow file on destination
# echo '>>>Copying Old Docker-Compose Project: '
# rsync -av --delete root@${ODOO_ORIGIN_HOST}:${OLD_PROJETC_DIR}/{addons,config,enterprise}  ./odoo/

##Rectifying Configuration on config/odoo.conf
#Comment db_host definition on odoo.conf
echo '>>>Comment db_host definition on odoo.conf: '
#Erase Database Host declaration
# sed -i 's/^db_host/; db_host/g' ./odoo/config/odoo.conf
#Erase commented Addons declaration
sed -i '/;addons_path/d' ./odoo/config/odoo.conf
#Erase unneccesary declaration path
#sed -i 's|,/mnt/extra-addons/om_account_accountant,/mnt/extra-addons/l10n-cuba||g' ./odoo/config/odoo.conf
#Temporary comment extra addons daclaration
#sed -i 's/^addons_path/;addons_path/g' ./odoo/config/odoo.conf


# Docker-compose UP
echo '>>>UP Docker-compose: '
docker compose up -d
sleep 30

#Satisfacer dependencias
if  [ -n ${ODOO_DEPENDENCIES} ]; then \
docker container exec -u root ${NEW_PROJECT_NAME}_web_1 bash -c 'apt install -y python3-pip; yes | pip3 install lxml xlrd xlsxwriter openpyxl google-auth html2text'; \
fi

#Restore extra addons declaration
#sed -i 's/^;addons_path/addons_path/g' ./odoo/config/odoo.conf

#Restart Odoo container with addons
#docker container restart ${NEW_PROJECT_NAME}_web_1


#Schedule a weekly SSL cert update
cp ./cron.weekly/*_certbot_renew.sh /etc/cron.weekly/
chmod +x /etc/cron.weekly/*_certbot_renew.sh