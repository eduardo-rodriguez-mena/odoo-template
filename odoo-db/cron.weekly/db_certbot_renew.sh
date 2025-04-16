#!/bin/bash
cd /app/odoo-db
docker container start odoo-db-certbot-1 && sleep 45
docker container start odoo-db-perm-1 
docker container stop odoo-db-db-1 
docker container start odoo-db-db-1 
