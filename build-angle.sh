#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Error: You must provide exactly one argument."
    echo "Usage: $0 <Release/Debug>"
    exit 1
fi

BUILD_TYPE="$1"

if [ "$BUILD_TYPE" == "Release" ] || [ "$BUILD_TYPE" == "Debug" ]; then
    echo "Using build type: $BUILD_TYPE"
else
    echo "Error: Invalid build type. Only 'Release' or 'Debug' are allowed."
    exit 1
fi

cd "$(dirname "$0")"

export PATH="$(pwd)/depot_tools:$PATH"

rm -r Frameworks/

autoninja -C angle/out/$BUILD_TYPE-iphoneos
autoninja -C angle/out/$BUILD_TYPE-iphonesimulator

TEMP_DIR=$(mktemp -d)

mkdir $TEMP_DIR/simulator
mkdir $TEMP_DIR/device

cp -R angle/out/$BUILD_TYPE-iphonesimulator/libEGL.framework $TEMP_DIR/simulator
cp -R angle/out/$BUILD_TYPE-iphonesimulator/libGLESv2.framework $TEMP_DIR/simulator
cp -R angle/out/$BUILD_TYPE-iphoneos/libEGL.framework $TEMP_DIR/device
cp -R angle/out/$BUILD_TYPE-iphoneos/libGLESv2.framework $TEMP_DIR/device

SDKS="device simulator"
for SDK in $SDKS; do 
    mkdir $TEMP_DIR/$SDK/libEGL.framework/Headers/
    cp -R angle/include/EGL $TEMP_DIR/$SDK/libEGL.framework/Headers/EGL

    TO_COPY="GLES GLES2 GLES3 KHR"
    for COPY in $TO_COPY; do
        mkdir $TEMP_DIR/$SDK/libGLESv2.framework/Headers/
        cp -R angle/include/$COPY $TEMP_DIR/$SDK/libGLESv2.framework/Headers/$COPY
    done
done

mkdir Frameworks/
xcodebuild -create-xcframework -framework $TEMP_DIR/device/libEGL.framework -framework $TEMP_DIR/simulator/libEGL.framework -output Frameworks/libEGL.xcframework
xcodebuild -create-xcframework -framework $TEMP_DIR/device/libGLESv2.framework -framework $TEMP_DIR/simulator/libGLESv2.framework -output Frameworks/libGLESv2.xcframework


