#!/bin/sh
username=`whoami`
pidset=`ps -ef | grep $username | grep -v grep | grep -E '(qycrosssrv)' | awk '{ print $2 }'`
pidset=`echo $pidset `

echo "pids: $pidset"

echo "start kill pid..."

for pid in $pidset
do
	echo "kill $pid "
	kill -s 15 $pid
done

echo "done"