#!/bin/bash
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$CUR_DIR/build32.sh
$CUR_DIR/build64.sh

BUILD_DIR=$CUR_DIR/../buildall
if [ -d "$BUILD_DIR" ]; then
  rm -rf $BUILD_DIR
fi
mkdir $BUILD_DIR
mkdir $BUILD_DIR/src

cp -r $CUR_DIR/../build32/src/* $BUILD_DIR/src
cp -r $CUR_DIR/../build64/src/* $BUILD_DIR/src
