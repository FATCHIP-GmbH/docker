# setup shopware, magento or oxid shops in docker containers 

## Features
- phpmyadmin inlcuded
- mailcatcher included

## Prerequisites
- working docker and docker-compose install
see [docker-install](https://github.com/FATCHIP-GmbH/docker-install)<br />
for linux and windows 10 unattended install scripts
- access to fatchip/apache-php docker container
see [docker-apache-php](https://github.com/FATCHIP-GmbH/docker-apache-php)

## Example configuration
this example configuration creates a shop instance accessible at
* sw546.testing.fatchip.local:80
* running shopware 4.5.6
* running php 7.1 
* mailcatcher is accessible on port 8081
* shopname is set to "Demoshop"

```
SHOP_HOSTNAME=sw546
DOMAIN=testing.fatchip.local
SHOP_NAME=Demoshop
PHP_VERSION=7.1
SHOP_TYPE=sw
SHOP_VERSION=546
APACHE_PORT=80
MAILCATCHER_PORT=8081
SHOP_REPO_PREFIX=git@github.com:FATCHIP-GmbH
MYSQL_IMPORT_SLEEP=20

# do not change
IMAGE=fatchip/apache-php
IMAGE_VERSION=latest
```

## Basic usage
show available commands:
```cmd
]$ ./docker.sh 
```
example output
```cmd
Usage: docker.sh {create|start|stop|update|destroy|status}
```

create a new container instance:
```cmd
./docker.sh create
```
example output:
```cmd
$ ./docker.sh create
==>   checking out sw546
Klone nach 'data/www/sw546' ...
remote: Counting objects: 13707, done.
remote: Compressing objects: 100% (7852/7852), done.
remote: Total 13707 (delta 5375), reused 13707 (delta 5375), pack-reused 0
Empfange Objekte: 100% (13707/13707), 30.54 MiB | 3.20 MiB/s, Fertig.
Löse Unterschiede auf: 100% (5375/5375), Fertig.
Checke Dateien aus: 100% (12535/12535), Fertig.
==>   starting sw546 on sw546.testing.fatchip.local
Creating network "docker_default" with the default driver
Creating volume "docker_mysql-data" with default driver
Creating docker_mysql_1 ... done
Creating docker_apache-php_1 ... done
==>   waiting 20s for initial db import
==>   updating php version
docker_mysql_1 is up-to-date
docker_apache-php_1 is up-to-date
==>   updating shop_hostname for sw546
==>   clearing cache for sw546
Status: 
       Name                      Command               State                     Ports                   
---------------------------------------------------------------------------------------------------------
docker_apache-php_1   supervisord -c /etc/superv ...   Up      0.0.0.0:8081->1080/tcp, 0.0.0.0:80->80/tcp
docker_mysql_1        docker-entrypoint.sh mysqld      Up      3306/tcp                                  
Php info: http://sw546.testing.fatchip.local
Shop: http://sw546.testing.fatchip.local/sw546
phpmyadmin: http://sw546.testing.fatchip.local/phpmyadmin : (mysql)-user: root pw:root
mailcatcher: http://sw546.testing.fatchip.local:8081
Shop Admin: http://sw546.testing.fatchip.local/sw546/backend user: demo password: demo
Please wait 10-20s after creation until shop is ready!

```

once a container instance is created, you can start and stop the container
```cmd
./docker.sh stop
```
example output:
```cmd
$ ./docker.sh stop
==>   stopping sw546 on sw546.testing.fatchip.local
Stopping docker_apache-php_1 ... done
Stopping docker_mysql_1      ... done
```

```cmd
./docker.sh start
```
example output:
```cmd
$ ./docker.sh stop
==>   stopping sw546 on sw546.testing.fatchip.local
Stopping docker_apache-php_1 ... done
Stopping docker_mysql_1      ... done
```

destroy a container instance and destroy all data including the database:
```cmd
./docker.sh destroy
```
example output:
```cmd
$ ./docker.sh destroy
==>   destroying host and data sw546 on sw546.testing.fatchip.local
Removing docker_apache-php_1 ... done
Removing docker_mysql_1      ... done
Removing network docker_default
Removing volume docker_mysql-data
```


## Changing settings

you can change the following settings after creating a container instance:
- SHOP_HOSTNAME
- DOMAIN
- SHOP_NAME
- PHP_VERSION

you have to run update to apply the new settings
```cmd
./docker.sh update
```
example output:
```cmd
$ ./docker.sh update
==>   destroying host and data sw546 on sw546.testing.fatchip.local
Removing docker_apache-php_1 ... done
Removing docker_mysql_1      ... done
Removing network docker_default
Removing volume docker_mysql-data
```

## Documentation

