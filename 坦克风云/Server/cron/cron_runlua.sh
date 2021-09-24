#!/bin/bash

lua_bin='/opt/tankserver/embedded/bin/lua'
timer_dir='/opt/tankserver/game/tank_timer/'
timer_file=${timer_dir}$1
msg=`grep cmd $timer_file|sed "s/msg\=//"`
basedir="$( cd "$( dirname "$0"  )" && pwd  )" 
lua_file=${basedir}/$2

if [ ! -f $lua_file ];then
        echo "No such file: $lua_file";
        exit 1
fi

#for i in `cut -f2 port_zone.ini`
for i in `cat ${timer_dir}port_zone.ini|awk '{print int($2)}'`
do
        cmd=`echo $msg | sed "s/zoneid\"\:1\,/zoneid\"\:$i\,/"`
        $lua_bin ${lua_file} $cmd $basedir
done
