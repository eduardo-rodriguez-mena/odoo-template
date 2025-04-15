#!/bin/bash
cd /app/odoo-web
docker container start odoo-web_certbot_1 && sleep 45
docker container stop odoo-web_nginx-proxy_1 
docker container start odoo-web_nginx-proxy_1 