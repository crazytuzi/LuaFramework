start qycrosssrv.exe 1 0 croconf.xml
sleep 2
start qyconnsrv.exe 1 0 croconf.xml
start qyscenesrv.exe 1 1 croconf.xml
sleep 5

cd sql
call ./update.bat
cd ..

start qydatasrv.exe
sleep 2
start qyworldsrv.exe
sleep 2
start qyscenesrv.exe 1
sleep 2
start qyscenesrv.exe 2
sleep 2
start qyloginsrv.exe
start qyconnsrv.exe
start qylogsrv.exe
