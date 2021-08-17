#!/bin/bash

set -e

NGROK_HOST=${1}

>&2 echo -n "Waiting for shop "
while [[ -z $(curl -Lks http://localhost/ | grep '2013-present Magento') ]]; do 
  sleep 1
  >&2 echo -n .
done
>&2 echo
sudo docker exec --interactive magento /bin/bash <<EOF
cd /opt/bitnami/magento
echo "Setting Magento Adobe auth tokens"
composer config --global --auth http-basic.repo.magento.com ${MAGENTO_ACC_PUBKEY} ${MAGENTO_ACC_PRIVKEY}
echo "Changing magento base-url to https://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url="http://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url-secure="https://${NGROK_HOST}/"
echo "Flushing cache"
php bin/magento cache:flush >&/dev/null
echo "Installing sample data"
php bin/magento sampledata:deploy
php bin/magento setup:upgrade
EOF
