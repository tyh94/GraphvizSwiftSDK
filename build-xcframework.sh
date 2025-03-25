#!/bin/bash

set -eo pipefail

SCHEME_NAME=$1

XCWORKSPACE_PATH="graphviz_module/build/Graphviz.xcodeproj"
echo "Workspace:${XCWORKSPACE_PATH}"

# Constants
OUTPUT_DIR="out-xcframework"
CONFIGURATION="Release"
DERIVED_DATA_PATH="DerivedData"
FRAMEWORK_NAME=$SCHEME_NAME

EXTRAARGS="SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
ONLY_ACTIVE_ARCH=NO \
OTHER_CFLAGS=-fembed-bitcode \
GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=NO \
CLANG_ENABLE_CODE_COVERAGE=NO \
BITCODE_GENERATION_MODE=bitcode"

rm -rf "${OUTPUT_DIR}"


echo "Build iphoneos platform"
rm -rf "${DERIVED_DATA_PATH}"
xcodebuild \
	-project "${XCWORKSPACE_PATH}" \
	-scheme "${SCHEME_NAME}" \
	-configuration "${CONFIGURATION}" \
	-archivePath "${DERIVED_DATA_PATH}/${CONFIGURATION}-iphoneos" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-sdk iphoneos \
	# -destination "generic/platform=iOS" \
	"$EXTRAARGS" \
	archive | xcbeautify

echo "Copy the framework in output device folder"

DEVICE_OUTPUT_DIR="${OUTPUT_DIR}/Device"

mkdir -p "${DEVICE_OUTPUT_DIR}"
cp -Rf "${DERIVED_DATA_PATH}/${CONFIGURATION}-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" "${DEVICE_OUTPUT_DIR}"


echo "Build iphonesimulator platform"
rm -rf "${DERIVED_DATA_PATH}"
xcodebuild  \
	-project "${XCWORKSPACE_PATH}" \
	-scheme "${SCHEME_NAME}" \
	-configuration "${CONFIGURATION}" \
	-archivePath "${DERIVED_DATA_PATH}/${CONFIGURATION}-iphonesimulator" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-sdk iphonesimulator \
	# -destination "generic/platform=iOS Simulator" \
	"$EXTRAARGS" \
	archive | xcbeautify

echo "Copy the framework in output simulator folder"

SIMULATOR_OUTPUT_DIR="${OUTPUT_DIR}/Simulator"

mkdir -p "${SIMULATOR_OUTPUT_DIR}"
cp -Rf "${DERIVED_DATA_PATH}/${CONFIGURATION}-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" "${SIMULATOR_OUTPUT_DIR}"

XCFRAMEWORK="${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

xcodebuild -create-xcframework \
	-framework "${DEVICE_OUTPUT_DIR}/${FRAMEWORK_NAME}.framework/" \
	-framework "${SIMULATOR_OUTPUT_DIR}/${FRAMEWORK_NAME}.framework/" \
	-output "${XCFRAMEWORK}"