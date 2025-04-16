#!/bin/bash
cd /app/odoo-web
docker container start odoo-web-certbot-1 && sleep 45
docker container stop odoo-web-nginx-proxy-1 
docker container start odoo-web-nginx-proxy-1 