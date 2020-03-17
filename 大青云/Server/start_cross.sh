#!/bin/sh
ulimit -c unlimited
ulimit -n 204800

pwd=`pwd`

echo "********************************************************"
ulimit -c
echo "********************************************************"

echo "start qycrosssrv"
nohup $pwd/qycrosssrv >$pwd/qycrosssrv.out &
echo "done"
