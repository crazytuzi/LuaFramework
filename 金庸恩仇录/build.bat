set FILE_DIR=../build
if exist "%FILE_DIR%" rmdir /s /q "%FILE_DIR%"
set SRC=%FILE_DIR%/src/
mkdir "%SRC%"

call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i app -o %SRC%app.zip -p app -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i cocos -o %SRC%cocos.zip -p cocos -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i constant -o %SRC%constant.zip -p constant -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i data -o %SRC%data.zip -p data -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i framework -o %SRC%framework.zip -p framework -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i game -o %SRC%game.zip -p game -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i network -o %SRC%network.zip -p network -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i sdk -o %SRC%sdk.zip -p sdk -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i update -o %SRC%update.zip -p update -e xxtea_zip -ek suifengsy -es sign
call %QUICK_V3_ROOT%/quick/bin/compile_scripts.bat -i utility -o %SRC%utility.zip -p utility -e xxtea_zip -ek suifengsy -es sign

copy /y config.lua "%SRC%"
copy /y main.lua "%SRC%"
::"C:\Program Files\WinRAR\WinRAR.exe" a –ibck –m5 ../build/update5001.zip %SRC%
pause