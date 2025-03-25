#!/bin/bash
set -eo pipefail

# xcodebuild -project $GRAPHVIZ_PROJECT -scheme xdot -configuration Release -sdk iphoneos build
# xcodebuild -project $GRAPHVIZ_PROJECT -scheme xdot -configuration Release -sdk iphonesimulator build
# DEVICE_ARM64_OUTPUT_DIR="lib/xdot/Release-iphoneos/libxdot.dylib"
# SIMULATOR_x86_64_OUTPUT_DIR="lib/xdot/Release-iphonesimulator/libxdot.dylib"
# xcodebuild -create-xcframework \
# -library $DEVICE_ARM64_OUTPUT_DIR -headers ../lib/xdot \
# -library $SIMULATOR_x86_64_OUTPUT_DIR -headers ../lib/xdot \
# -output ../../archives/xdot.xcframework

# sh ./build-xcframework.sh 

echo "==============="
LIBRARY_NAME=$1
LIBRARY_VERSION=$2

echo $LIBRARY_NAME $LIBRARY_VERSION

BUILD_FOLDER=graphviz_module/build
GRAPHVIZ_PROJECT="Graphviz.xcodeproj"
echo $BUILD_FOLDER
cd $BUILD_FOLDER

xcodebuild -project $GRAPHVIZ_PROJECT -scheme $LIBRARY_NAME -configuration Release -sdk iphoneos build
xcodebuild -project $GRAPHVIZ_PROJECT -scheme $LIBRARY_NAME -configuration Release -sdk iphonesimulator build
DEVICE_ARM64_OUTPUT_DIR="lib/$LIBRARY_NAME/Release-iphoneos/lib$LIBRARY_NAME$LIBRARY_VERSION.dylib"
SIMULATOR_x86_64_OUTPUT_DIR="lib/$LIBRARY_NAME/Release-iphonesimulator/lib$LIBRARY_NAME$LIBRARY_VERSION.dylib"
xcodebuild -create-xcframework \
-library $DEVICE_ARM64_OUTPUT_DIR -headers ../lib/$LIBRARY_NAME \
-library $SIMULATOR_x86_64_OUTPUT_DIR -headers ../lib/$LIBRARY_NAME \
-output ../../archives/$LIBRARY_NAME.xcframework