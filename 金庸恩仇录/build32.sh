#!/bin/bash
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR=$CUR_DIR/../build32
SRC_DIR=$BUILD_DIR/src
if [ -d "$BUILD_DIR" ]; then
  rm -rf $BUILD_DIR
fi

mkdir $BUILD_DIR
mkdir $SRC_DIR

$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i app -o $SRC_DIR/app.zip -p app -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i cocos -o $SRC_DIR/cocos.zip -p cocos -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i constant -o $SRC_DIR/constant.zip -p constant -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i data -o $SRC_DIR/data.zip -p data -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i framework -o $SRC_DIR/framework.zip -p framework -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i game -o $SRC_DIR/game.zip -p game -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i network -o $SRC_DIR/network.zip -p network -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i sdk -o $SRC_DIR/sdk.zip -p sdk -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i update -o $SRC_DIR/update.zip -p update -e xxtea_zip -ek suifengsy -es sign
$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i utility -o $SRC_DIR/utility.zip -p utility -e xxtea_zip -ek suifengsy -es sign

cp -r config.lua $SRC_DIR
cp -r main.lua $SRC_DIR
