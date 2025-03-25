#!/bin/bash

set -e

./autogen.sh

# Параметры
DEPLOYMENT_TARGET="18.0"
BUILD_DIR="build-ios"
OUTPUT_DIR="lib"

# Создаем директории
rm -rf $BUILD_DIR $OUTPUT_DIR
mkdir -p $BUILD_DIR $OUTPUT_DIR
cd $BUILD_DIR

# Сборка для устройств
echo "Building for arm64..."
../configure \
  --host=arm-apple-darwin \
  --enable-static \
  --disable-shared \
  CFLAGS="-arch arm64 -mios-version-min=$DEPLOYMENT_TARGET" \
  CXXFLAGS="-arch arm64 -mios-version-min=$DEPLOYMENT_TARGET" \
  LDFLAGS="-arch arm64 -mios-version-min=$DEPLOYMENT_TARGET" \
  CC="clang -arch arm64" \
  CXX="clang++ -arch arm64"

make -j$(sysctl -n hw.logicalcpu)
cp lib/gvc/.libs/libgvc.a ../$OUTPUT_DIR/libgvc_arm64.a

# Сборка для симулятора
echo "Building for x86_64..."
make distclean
../configure \
  --host=x86_64-apple-darwin \
  --enable-static \
  --disable-shared \
  CFLAGS="-arch x86_64 -mios-simulator-version-min=$DEPLOYMENT_TARGET" \
  CXXFLAGS="-arch x86_64 -mios-simulator-version-min=$DEPLOYMENT_TARGET" \
  LDFLAGS="-arch x86_64 -mios-simulator-version-min=$DEPLOYMENT_TARGET" \
  CC="clang -arch x86_64" \
  CXX="clang++ -arch x86_64"

make -j$(sysctl -n hw.logicalcpu)
cp lib/gvc/.libs/libgvc.a ../$OUTPUT_DIR/libgvc_x86_64.a

# Создание универсальной библиотеки
echo "Creating universal library..."
lipo -create \
  ../$OUTPUT_DIR/libgvc_arm64.a \
  ../$OUTPUT_DIR/libgvc_x86_64.a \
  -output ../$OUTPUT_DIR/libgvc_universal.a

echo "Build complete! Output in $OUTPUT_DIR"