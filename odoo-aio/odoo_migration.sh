#!/bin/bash

#YYOGestiono Deployment and Migration Script


NEW_PROJECT_NAME=${PWD##*/}

#Move to Project Directory

#Import variables
echo '>>>Import variables: '
export $(grep -v '^#' .env | xargs)

#Copying Old Docker-Compose Project, clear unknow file on destination
echo '>>>Copying Old Docker-Compose Project: '
rsync -av --delete root@${ODOO_ORIGIN_HOST}:${OLD_PROJETC_DIR}/{addons,config,enterprise}  ./odoo/

##Rectifying Configuration on config/odoo.conf
#Comment db_host definition on odoo.conf
echo '>>>Comment db_host definition on odoo.conf: '
#Erase Database Host declaration
sed -i 's/^db_host/; db_host/g' ./odoo/config/odoo.conf
#Erase commented Addons declaration
sed -i '/;addons_path/d' ./odoo/config/odoo.conf
#Erase unneccesary declaration path
#sed -i 's|,/mnt/extra-addons/om_account_accountant,/mnt/extra-addons/l10n-cuba||g' ./odoo/config/odoo.conf
#Temporary comment extra addons daclaration
#sed -i 's/^addons_path/;addons_path/g' ./odoo/config/odoo.conf



#Create Backup Folder in case it does not exist
echo '>>>Create Backup Folder: '
mkdir -p ./odoo/backups/

#Clear local_backup
echo '>>>Clear local_backup: '
rm -f ./odoo/backups/*

# Docker-compose UP
echo '>>>UP Docker-compose: '
docker compose up -d
sleep 30

#Satisfacer dependencias
if  [ -n ${ODOO_DEPENDENCIES} ]; then \
docker container exec -u root ${NEW_PROJECT_NAME}_web_1 bash -c 'apt install -y python3-pip; yes | pip3 install lxml xlrd xlsxwriter openpyxl google-auth html2text'; \
fi

#Database & Filestore migration
#Create a local Backup Old System
echo '>>>Create a local Backup: '
curl -X POST \
    -F 'master_pwd='${ADMIN_PASSWORD} \
    -F 'name='${ODOO_DATABASE} \
    -F 'backup_format=zip' \
    -o ./odoo/backups/${ODOO_DATABASE}.zip \
    ${ODOO_PROTOCOL}://${ODOO_ORIGIN_SITE}/web/database/backup

#Delete Database if exists
echo '>>>Delete existing Local DBs with same name: '
curl \
    -F 'master_pwd='${ADMIN_PASSWORD} \
    -F 'name='${ODOO_DATABASE} \
     http://127.0.0.1:8069/web/database/drop

#Restore same Local Backup New systems
echo '>>>Restore same Local Backup: '
curl \
    -F 'master_pwd='${ADMIN_PASSWORD} \
    -F 'name='${ODOO_DATABASE} \
    -F 'copy=true' \
    -F backup_file=@./odoo/backups/${ODOO_DATABASE}.zip \
    http://127.0.0.1:8069/web/database/restore

#Restore extra addons declaration
#sed -i 's/^;addons_path/addons_path/g' ./odoo/config/odoo.conf

#Restart Odoo container with addons
#docker container restart ${NEW_PROJECT_NAME}_web_1


#Schedule a weekly SSL cert update
cp ./cron.weekly/*_certbot_renew.sh /etc/cron.weekly/
chmod +x /etc/cron.weekly/*_certbot_renew.sh