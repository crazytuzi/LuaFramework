#!/bin/sh
pwd=`pwd`

a=$(ps -ef |grep $pwd|grep -v grep |wc -l)
if [[ $a -ge 1 ]]
then
    ps aux | grep `pwd` | grep -v "grep" | awk '{print $2}' | xargs -i kill -2 {}
    echo "killall -2 finish"
else
    echo "OK"
fi

sleep 3

a=$(ps -ef |grep $pwd|grep -v grep |wc -l)
if [[ $a -ge 1 ]]
then
    ps aux | grep `pwd` | grep -v "grep" | awk '{print $2}' | xargs -i kill -9 {}
    echo "killall -9 finish"
else
    echo "OK"
fi
