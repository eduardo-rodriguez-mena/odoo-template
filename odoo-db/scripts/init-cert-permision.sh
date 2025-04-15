#!/bin/bash
echo "Comenzando"
chown :999 -R /etc/letsencrypt
find /etc/letsencrypt -type f -exec chmod 0640 {} +
find /etc/letsencrypt -type d -exec chmod 0750 {} +
echo "Terminando"


