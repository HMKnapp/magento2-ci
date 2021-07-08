#!/bin/bash

set -xe

NGROK_HOST=${1}

sleep 120
sudo docker exec --interactive magento /bin/bash <<EOF
cd /opt/bitnami/magento
echo "Changing magento base-url to https://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url="http://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url-secure="https://${NGROK_HOST}/"
echo "Flushing cache"
php bin/magento cache:flush >&/dev/null
EOF
