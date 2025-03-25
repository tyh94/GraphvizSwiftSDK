#!/bin/bash

set -eo pipefail

BUILD_FOLDER=graphviz_module/build
SOURCEFOLDER=graphviz_module
DEPLOYMENT_TARGET="18.0"

rm -rf $BUILD_FOLDER
mkdir -p $BUILD_FOLDER

# здесь все инструменты разработчика
XCODE_ROOT=$(xcode-select -print-path)
# корневая папка iPhone OS SDK
XCODE_ARM_ROOT=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer
# корневая папка iPhone Simulator SDK
XCODE_SIM_ROOT=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer
# здесь все основные утилиты, такие как...
XCODE_TOOLCHAIN_BIN=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin 
# C++ компилятор
CXX_COMPILER=${XCODE_TOOLCHAIN_BIN}/clang++
# C компилятор
C_COMPILER=${XCODE_TOOLCHAIN_BIN}/clang 

CXX_FLAGS="-arch armv7 -arch armv7s -arch arm64"
SYSTEM_ROOT=${XCODE_ARM_ROOT}/SDKs/iPhoneOS.sdk

cd $BUILD_FOLDER

cmake .. -G Xcode \
	-DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake \
    -DPLATFORM=OS64COMBINED \
	-DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY="libc++" \
	-DCMAKE_CXX_FLAGS="${CMAKE_C_FLAGS} -std=c++0x -stdlib=libc++" \
    -DDEPLOYMENT_TARGET=$DEPLOYMENT_TARGET \
    # -DCMAKE_Swift_COMPILER_FORCED=true \
    -DHAVE_DL_ITERATE_PHDR=OFF \
    # -DCMAKE_CXX_COMPILER=$CXX_COMPILER \
    # -DCMAKE_C_COMPILER=$C_COMPILER \
    # -DCMAKE_CXX_FLAGS="$CXX_FLAGS" 
    # -DCMAKE_OSX_SYSROOT="$SYSTEM_ROOT" \
	# -DIOS=1 \
    # -DLIBXML2_WITH_PROGRAMS=OFF \
    # -DBUILD_SHARED_LIBS=OFF \
    # -DCMAKE_SYSTEM_NAME=iOS \            
    # -DCMAKE_C_STANDARD=17 \
    # -DCMAKE_CXX_STANDARD=17 \
    # -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    # -DCMAKE_CXX_EXTENSIONS=OFF \
    # -DLIBXML2_WITH_UNICODE=ON \
    # -DLIBXML2_WITH_LZMA=OFF \
    # -DLIBXML2_WITH_ZLIB=OFF \
    # -DLIBXML2_WITH_FTP=OFF \
    # -DLIBXML2_WITH_HTTP=OFF \
    # -DLIBXML2_WITH_HTML=OFF \
    # -DLIBXML2_WITH_ICONV=OFF \
    # -DLIBXML2_WITH_LEGACY=OFF \
    # -DLIBXML2_WITH_MODULES=OFF \
    # -DLIBXML_THREAD_ENABLED=OFF \
    # -DLIBXML2_WITH_OUTPUT=OFF \
    # -DLIBXML2_WITH_PYTHON=OFF \
    # -DLIBXML2_WITH_DEBUG=OFF \
    # -DLIBXML2_WITH_THREADS=ON \
    # -DLIBXML2_WITH_THREAD_ALLOC=OFF \
    # -DLIBXML2_WITH_TESTS=OFF \
    # -DLIBXML2_WITH_DOCB=OFF \
    # -DLIBXML2_WITH_SCHEMATRON=OFF \
    # -DCMAKE_BUILD_TYPE=Release \
    # # -DCMAKE_INSTALL_LIBDIR=
    # -DCMAKE_MACOSX_BUNDLE=OFF

cmake --build . $BUILD_FOLDER --config Release
cmake --install $BUILD_FOLDER --config Release # Necessary to build combined library
