call ./stop_all.bat

cd sql
call ./update.bat
cd ..

start qydatasrv.exe
sleep 1
start qyworldsrv.exe
sleep 1
start qyscenesrv.exe 1
sleep 1
start qyloginsrv.exe
start qyconnsrv.exe
start qylogsrv.exe

