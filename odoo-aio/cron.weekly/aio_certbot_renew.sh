#!/bin/bash
cd /app/odoo-aio
docker container start odoo-aio-certbot-1 && sleep 45
docker container stop odoo-aio-nginx-proxy-1 
docker container start odoo-aio-nginx-proxy-1 
