#!/bin/bash 
ulimit -c unlimited
ulimit -n 204800

pwd=`pwd`

echo "********************************************************"
ulimit -c
echo "********************************************************"

echo "start all .... "
nohup $pwd/qydatasrv >$pwd/qydatasrv.out & 
nohup $pwd/qyworldsrv >$pwd/qyworldsrv.out & 
nohup $pwd/qyscenesrv 1 >$pwd/qyscenesrv1.out & 
nohup $pwd/qyscenesrv 2 >$pwd/qyscenesrv2.out & 
nohup $pwd/qyloginsrv >$pwd/qyloginsrv.out & 
nohup $pwd/qyconnsrv >$pwd/qyconnsrv.out & 
nohup $pwd/qylogsrv >$pwd/qylogsrv.out & 

echo "done"
