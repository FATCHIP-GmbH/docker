#!/usr/bin/env bash

source ./.env
prog=docker.sh

MYSQL_USER=root
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=${SHOP_TYPE}${SHOP_VERSION}
APACHE_DOCUMENT_ROOT=/var/www

echo_title() {
  echo "==>   ${1}"
}

print_info(){
  echo -e "Status: " && docker-compose ps
  echo -e "Php info: http://${SHOP_HOSTNAME}.${DOMAIN}"
  echo -e "Shop: http://${SHOP_HOSTNAME}.${DOMAIN}/${SHOP_TYPE}${SHOP_VERSION}"
  echo -e "phpmyadmin: http://${SHOP_HOSTNAME}.${DOMAIN}/phpmyadmin : (mysql)-user: root pw:root"
  echo -e "mailcatcher: http://${SHOP_HOSTNAME}.${DOMAIN}:${MAILCATCHER_PORT}"
  case "${SHOP_TYPE}" in
    sw)    echo -e "Shop Admin: http://${SHOP_HOSTNAME}.${DOMAIN}/${SHOP_TYPE}${SHOP_VERSION}/backend user: demo password: demo\\n" ;;
    ox)    echo -e "Shop Admin: http://${SHOP_HOSTNAME}.${DOMAIN}/${SHOP_TYPE}${SHOP_VERSION}/admin : user: support@fatchip.de password: support@fatchip.de\\n";;
    mage)  echo -e "Shop Admin: http://${SHOP_HOSTNAME}.${DOMAIN}/${SHOP_TYPE}${SHOP_VERSION}/admin : user: fatchip password: Fatchip1\\n" ;;
  esac
}

clean_cache() {
  echo_title "clearing cache for ${SHOP_TYPE}${SHOP_VERSION}"
  case "${SHOP_TYPE}" in
    sw)    docker-compose exec -T apache-php rm -R "${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/var/cache"
           docker-compose exec -T apache-php rm -R "${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/web/cache"
           mkdir "data/www/${SHOP_TYPE}${SHOP_VERSION}/var/cache"
           mkdir "data/www/${SHOP_TYPE}${SHOP_VERSION}/web/cache";;
    ox)    [ -d "data/www/${SHOP_TYPE}${SHOP_VERSION}/tmp" ] && docker-compose exec -T apache-php rm -R "${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/tmp"
           mkdir "data/www/${SHOP_TYPE}${SHOP_VERSION}/tmp" ;;
    mage)  docker-compose exec -T apache-php rm -R "${APACHE_DOCUMENT_ROOT}/${SHOP_TYPE}${SHOP_VERSION}/var/*";
  esac
}

wait_for_mysql_initial_import(){
  echo_title  "waiting ${MYSQL_IMPORT_SLEEP=20S}s for initial db import"
  sleep $MYSQL_IMPORT_SLEEP=20
}

update_settings(){
  git_checkout
  echo_title "updating php version"
  docker-compose up -d
  echo_title "updating shop_hostname for ${SHOP_TYPE}${SHOP_VERSION}"
  case "${SHOP_TYPE}" in
    sw)    docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "UPDATE s_core_shops SET name=\"$SHOP_NAME\", host=\"${SHOP_HOSTNAME}.${DOMAIN}\", base_path=\"/$SHOP_TYPE$SHOP_VERSION\" WHERE id=1;" $MYSQL_DATABASE ;;
    ox)    ;;
    mage)  docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "UPDATE core_config_data SET value=\"http://${SHOP_HOSTNAME}.${DOMAIN}/$SHOP_TYPE$SHOP_VERSION/\" WHERE config_id=9;" $MYSQL_DATABASE && docker-compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -Bse "UPDATE core_config_data SET value=\"http://${SHOP_HOSTNAME}.${DOMAIN}/$SHOP_TYPE$SHOP_VERSION/\" WHERE config_id=10;" $MYSQL_DATABASE ;;
  esac
  clean_cache
  print_info
}

git_checkout(){
  [ -d data/www ] || mkdir -p data/www
  [ -d  "data/www/${SHOP_TYPE}${SHOP_VERSION}" ] && \
    echo_title "updating git ${SHOP_TYPE}${SHOP_VERSION}" && git -C "data/www/${SHOP_TYPE}${SHOP_VERSION}" pull

  [ ! -d  "data/www/${SHOP_TYPE}${SHOP_VERSION}" ] && \
    echo_title "checking out ${SHOP_TYPE}${SHOP_VERSION}" && \
    git clone "${SHOP_REPO}/${SHOP_TYPE}.git" "data/www/${SHOP_TYPE}${SHOP_VERSION}"
}

create(){
  git_checkout
  echo_title "starting ${SHOP_TYPE}${SHOP_VERSION} on ${SHOP_HOSTNAME}.${DOMAIN}"
  docker-compose up -d
  wait_for_mysql_initial_import
  update_settings
}

destroy(){
  echo_title "destroying host and data ${SHOP_TYPE}${SHOP_VERSION} on ${SHOP_HOSTNAME}.${DOMAIN}"
  docker-compose down -v
}

start(){
  echo_title "starting ${SHOP_TYPE}${SHOP_VERSION} on ${SHOP_HOSTNAME}.${DOMAIN}"
  docker-compose start
}

stop(){
  echo_title "stopping ${SHOP_TYPE}${SHOP_VERSION} on ${SHOP_HOSTNAME}.${DOMAIN}"
  docker-compose stop
}

case "$1" in
    create)
	  create ;;
    start)
	  start ;;
    stop)
	  stop ;;
    update)
      update_settings ;;
	destroy)
	  destroy ;;
	status)
	  print_info ;;

    *)
	echo $"Usage: $prog {create|start|stop|destroy|status}"
	exit 1
esac