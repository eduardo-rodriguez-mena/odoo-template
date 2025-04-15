#!/bin/bash
cd /app/odoo-aio
docker container start odoo-aio_certbot_1 && sleep 45
docker container stop odoo-aio_nginx-proxy_1 
docker container start odoo-aio_nginx-proxy_1 
