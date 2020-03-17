#!/bin/bash

mysql -uroot -p123456 -h127.0.0.1 -D venus < ./update.sql
