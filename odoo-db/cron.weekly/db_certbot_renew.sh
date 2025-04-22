#!/bin/bash
cd /app/odoo-db
docker container start odoo-db-certbot-1 && sleep 45
docker compose stop
docker compose up -d
