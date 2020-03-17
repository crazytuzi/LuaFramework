#!/bin/bash

mysql -uroot -p123456 -h127.0.0.1 -e "drop database if exists venus"
mysql -uroot -p123456 -h127.0.0.1 -e "CREATE DATABASE venus DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -uroot -p123456 -h127.0.0.1 -D venus < ./create.sql
mysql -uroot -p123456 -h127.0.0.1 -D venus < ./update.sql
