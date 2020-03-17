#!/bin/bash 
ulimit -c unlimited
ulimit -n 204800

pwd=`pwd`

echo "********************************************************"
ulimit -c
echo "********************************************************"

echo "start all .... "
nohup valgrind --tool=memcheck --leak-check=full --log-file="qydatasrv.log.%p" $pwd/qydatasrv >$pwd/qydatasrv.out & 
sleep 1
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyworldsrv.log.%p" $pwd/qyworldsrv >$pwd/qyworldsrv.out & 
sleep 1
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyloginsrv.log.%p" $pwd/qyloginsrv >$pwd/qyloginsrv.out &
sleep 1
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyscenesrv1.log.%p" $pwd/qyscenesrv 1 >$pwd/qyscenesrv1.out & 
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyscenesrv2.log.%p" $pwd/qyscenesrv 2 >$pwd/qyscenesrv2.out & 
sleep 2
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyloginsrv.log.%p" $pwd/qyloginsrv >$pwd/qyloginsrv.out & 
sleep 2
nohup valgrind --tool=memcheck --leak-check=full --log-file="qyconnsrv.log.%p" $pwd/qyconnsrv >$pwd/qyconnsrv.out & 

echo "done"
