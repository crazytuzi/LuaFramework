#!/bin/sh
ulimit -c unlimited
ulimit -n 204800

pwd=`pwd`

echo "********************************************************"
ulimit -c
echo "********************************************************"

if [ $# != 1 ]; then
	echo "please input bot id"
	exit 1;
fi
botid=$1
echo "start qyrobot $botid"
nohup $pwd/qyrobot $botid >$pwd/qyrobot.out &
echo "done"
