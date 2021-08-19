#!/bin/bash

set -e

NGROK_HOST=${1}

>&2 echo "Waiting for shop to start up.. "
while [[ -z $(curl -Lks http://localhost/ | grep '2013-present Magento') ]]; do 
  sleep 1
  >&2 echo -n .
done
>&2 echo
sudo docker exec --interactive magento /bin/bash <<EOF
echo "Install unzip for composer file permissions"
apt-get update && apt-get -y install unzip
echo "Set memory_limit in magento .htacces to 8G"
sed -i 's/php_value\ memory_limit\ 756M/php_value memory_limit 8G/' /opt/bitnami/magento/pub/.htaccess
cd /opt/bitnami/magento
echo "Setting Magento Adobe Auth token for ${MAGENTO_ACC_PUBKEY}"
composer config http-basic.repo.magento.com ${MAGENTO_ACC_PUBKEY} ${MAGENTO_ACC_PRIVKEY}
echo "Changing magento base-url to https://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url="http://${NGROK_HOST}/"
php bin/magento setup:store-config:set --base-url-secure="https://${NGROK_HOST}/"
echo "Flushing cache"
php bin/magento cache:flush >&/dev/null
echo "Installing sample data"
php -dmemory_limit=8G bin/magento sampledata:deploy
php -dmemory_limit=8G bin/magento setup:upgrade
php -dmemory_limit=8G bin/magento setup:di:compile
EOF
