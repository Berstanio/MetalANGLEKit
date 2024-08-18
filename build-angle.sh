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
autoninja -C angle/out/$BUILD_TYPE-iphonesimulator_x86_64
autoninja -C angle/out/$BUILD_TYPE-iphonesimulator_arm64

TEMP_DIR=$(mktemp -d)

mkdir $TEMP_DIR/simulator_x86_64
mkdir $TEMP_DIR/simulator_arm64
mkdir $TEMP_DIR/simulator
mkdir $TEMP_DIR/device

cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/libEGL.framework $TEMP_DIR/simulator/
cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/libGLESv2.framework $TEMP_DIR/simulator/
cp -R angle/out/$BUILD_TYPE-iphoneos/libEGL.framework $TEMP_DIR/device
cp -R angle/out/$BUILD_TYPE-iphoneos/libGLESv2.framework $TEMP_DIR/device

lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/libEGL.framework/libEGL angle/out/$BUILD_TYPE-iphonesimulator_x86_64/libEGL.framework/libEGL -output $TEMP_DIR/simulator/libEGL.framework/libEGL
lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/libGLESv2.framework/libGLESv2 angle/out/$BUILD_TYPE-iphonesimulator_x86_64/libGLESv2.framework/libGLESv2 -output $TEMP_DIR/simulator/libGLESv2.framework/libGLESv2

cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/libEGL.dSYM $TEMP_DIR/simulator/
cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/libGLESv2.dSYM $TEMP_DIR/simulator/
cp -R angle/out/$BUILD_TYPE-iphoneos/libEGL.dSYM $TEMP_DIR/device
cp -R angle/out/$BUILD_TYPE-iphoneos/libGLESv2.dSYM $TEMP_DIR/device

lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/libEGL.dSYM/Contents/Resources/DWARF/libEGL \
    angle/out/$BUILD_TYPE-iphonesimulator_x86_64/libEGL.dSYM/Contents/Resources/DWARF/libEGL \
    -output $TEMP_DIR/simulator/libEGL.dSYM/Contents/Resources/DWARF/libEGL

lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/libGLESv2.dSYM/Contents/Resources/DWARF/libGLESv2 \
    angle/out/$BUILD_TYPE-iphonesimulator_x86_64/libGLESv2.dSYM/Contents/Resources/DWARF/libGLESv2 \
    -output $TEMP_DIR/simulator/libGLESv2.dSYM/Contents/Resources/DWARF/libGLESv2

SDKS="device simulator"
for SDK in $SDKS; do 
    mkdir $TEMP_DIR/$SDK/libEGL.framework/Headers/
    cp -R angle/include/EGL $TEMP_DIR/$SDK/libEGL.framework/Headers/EGL

    TO_COPY="GLES GLES2 GLES3 KHR"
    mkdir $TEMP_DIR/$SDK/libGLESv2.framework/Headers/
    for COPY in $TO_COPY; do
        cp -R angle/include/$COPY $TEMP_DIR/$SDK/libGLESv2.framework/Headers/$COPY
    done
done

mkdir Frameworks/
xcodebuild -create-xcframework -framework $TEMP_DIR/device/libEGL.framework -debug-symbols $TEMP_DIR/device/libEGL.dSYM \
    -framework $TEMP_DIR/simulator/libEGL.framework -debug-symbols $TEMP_DIR/simulator/libEGL.dSYM \
    -output Frameworks/libEGL.xcframework

xcodebuild -create-xcframework -framework $TEMP_DIR/device/libGLESv2.framework -debug-symbols $TEMP_DIR/device/libGLESv2.dSYM \
        -framework $TEMP_DIR/simulator/libGLESv2.framework -debug-symbols $TEMP_DIR/simulator/libGLESv2.dSYM \
        -output Frameworks/libGLESv2.xcframework


