#!/bin/bash
cd /app/odoo-db
docker container start odoo-db_certbot_1 && sleep 45
docker container start odoo-db_perm_1 
docker container stop odoo-db_db_1 
docker container start odoo-db_db_1 
