#!/usr/bin/env bash

source ./.env

MYSQL_DATABASE=${SHOP_TYPE}${SHOP_VERSION}

[ -d data/www ] || mkdir data/www
echo "checking out ${SHOP_TYPE}${SHOP_VERSION}"
[ -d  data/www/${SHOP_TYPE}${SHOP_VERSION} ] || git clone https://github.com/FATCHIP-GmbH/${SHOP_TYPE}.git data/www/${SHOP_TYPE}${SHOP_VERSION}
echo "updating ${SHOP_TYPE}${SHOP_VERSION}"
[ -d  data/www/${SHOP_TYPE}${SHOP_VERSION} ] &&  git -C data/www/${SHOP_TYPE}${SHOP_VERSION} pull

echo "starting host"
docker-compose up -d

if [ "${SHOP_TYPE}" == 'sw' ] ;then
  echo "updating shopware db settings"
  # wait for initial db init # fix this by grepping docker-compose ps and checking up status?
  sleep 15
  docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "REPLACE INTO s_core_shops (id, main_id, name, title, position, host, base_path, base_url, hosts, secure, template_id, document_template_id, category_id, locale_id, currency_id, customer_group_id, fallback_id, customer_scope, \`default\`, active) VALUES (1, NULL, \"$SHOP_NAME\", NULL, 0, \"$SHOP_HOSTNAME\", \"/${SHOP_TYPE}${SHOP_VERSION}\", NULL, 'localhost', 0, 22, 22, 3, 1, 1, 1, NULL, 0, 1, 1);" $MYSQL_DATABASE
  echo "fixing directory permissions"
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/var
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/web/cache
  echo -e "User: demo\nPassword:demo"
fi


if [ "${SHOP_TYPE}" == 'ox' ] ;then
  echo "updating oxid db settings"
  # wait for initial db init # fix this by grepping docker-compose ps and checking up status?
  sleep 20
  # docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "REPLACE INTO s_core_shops (id, main_id, name, title, position, host, base_path, base_url, hosts, secure, template_id, document_template_id, category_id, locale_id, currency_id, customer_group_id, fallback_id, customer_scope, \`default\`, active) VALUES (1, NULL, \"$SHOP_NAME\", NULL, 0, \"$SHOP_HOSTNAME\", \"/${SHOP_TYPE}${SHOP_VERSION}\", NULL, 'localhost', 0, 22, 22, 3, 1, 1, 1, NULL, 0, 1, 1);" $MYSQL_DATABASE
  echo "fixing directory permissions"
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/tmp
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/out/pictures
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/out/media
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/log
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/export
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/config.inc.php
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/.htaccess
  echo -e "User: support@fatchip.de\nPassword: support@fatchip.de"
fi

if [ "${SHOP_TYPE}" == 'mage' ] ;then
  echo "updating mage db settings"
  # wait for initial db init # fix this by grepping docker-compose ps and checking up status?
  sleep 20
  #docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "REPLACE INTO s_core_shops (id, main_id, name, title, position, host, base_path, base_url, hosts, secure, template_id, document_template_id, category_id, locale_id, currency_id, customer_group_id, fallback_id, customer_scope, \`default\`, active) VALUES (1, NULL, \"$SHOP_NAME\", NULL, 0, \"$SHOP_HOSTNAME\", \"/${SHOP_TYPE}${SHOP_VERSION}\", NULL, 'localhost', 0, 22, 22, 3, 1, 1, 1, NULL, 0, 1, 1);" $MYSQL_DATABASE
  echo "fixing directory permissions"
  #  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/tmp
  #  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/out/pictures
  docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/
  #docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/out/media
  #docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/log
  #docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/export
  #docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/config.inc.php
  #docker-compose exec -T apache-php chmod -R 777 ${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/.htaccess

  echo -e "User: fatchip\nPassword: Fatchip1"
fi