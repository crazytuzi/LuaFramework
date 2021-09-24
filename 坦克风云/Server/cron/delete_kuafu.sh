#!/bin/sh
#kkName mysql数据库名称
kkName='tank_1'
#缓存端口,按服清除
rrPort=15102

mysql -h127.0.0.1 -P3307 $kkName --default-character-set=utf8 -e "delete from serverbattlecfg where type = 2;"
mysql -h127.0.0.1 -P3307 $kkName --default-character-set=utf8 -e "delete from alliance;"
mysql -h127.0.0.1 -P3307 $kkName --default-character-set=utf8 -e "delete from alliance_members;"
/opt/tankserver/embedded/bin/redis-cli -p $rrPort keys "*across*" | xargs /opt/tankserver/embedded/bin/redis-cli -p $rrPort del
/opt/tankserver/embedded/bin/redis-cli -p $rrPort keys "*serverbattlecfg*" | xargs /opt/tankserver/embedded/bin/redis-cli -p $rrPort del