#!/bin/bash

copy_frameworks() {
    local framework=$1
    SDKS="device simulator"
    for SDK in $SDKS; do 
        mkdir $TEMP_DIR/$SDK/$framework.framework/Headers/
        if [ "$framework" == "libEGL" ]; then
            TO_COPY="EGL"
        elif [ "$framework" == "libGLESv2" ]; then
            TO_COPY="GLES GLES2 GLES3 KHR"
        elif [ "$framework" == "libfeature_support" ]; then
            cp angle/src/feature_support_util/feature_support_util.h $TEMP_DIR/$SDK/$framework.framework/Headers/
            return
        else
            echo "Error: Unknown framework $framework."
            exit 1
        fi

        for COPY in $TO_COPY; do
            cp -R angle/include/$COPY $TEMP_DIR/$SDK/$framework.framework/Headers/$COPY
        done
    done
}

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
mkdir Frameworks/

autoninja -C angle/out/$BUILD_TYPE-iphoneos
autoninja -C angle/out/$BUILD_TYPE-iphonesimulator_x86_64
autoninja -C angle/out/$BUILD_TYPE-iphonesimulator_arm64

TEMP_DIR=$(mktemp -d)

mkdir $TEMP_DIR/simulator_x86_64
mkdir $TEMP_DIR/simulator_arm64
mkdir $TEMP_DIR/simulator
mkdir $TEMP_DIR/device

FRAMEWORKS="libEGL libGLESv2 libfeature_support"

for FRAMEWORK in $FRAMEWORKS; do
    cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/$FRAMEWORK.framework $TEMP_DIR/simulator/
    cp -R angle/out/$BUILD_TYPE-iphoneos/$FRAMEWORK.framework $TEMP_DIR/device

    lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/$FRAMEWORK.framework/$FRAMEWORK angle/out/$BUILD_TYPE-iphonesimulator_x86_64/$FRAMEWORK.framework/$FRAMEWORK \
        -output $TEMP_DIR/simulator/$FRAMEWORK.framework/$FRAMEWORK

    cp -R angle/out/$BUILD_TYPE-iphonesimulator_arm64/$FRAMEWORK.dSYM $TEMP_DIR/simulator/
    cp -R angle/out/$BUILD_TYPE-iphoneos/$FRAMEWORK.dSYM $TEMP_DIR/device

    lipo -create angle/out/$BUILD_TYPE-iphonesimulator_arm64/$FRAMEWORK.dSYM/Contents/Resources/DWARF/$FRAMEWORK \
        angle/out/$BUILD_TYPE-iphonesimulator_x86_64/$FRAMEWORK.dSYM/Contents/Resources/DWARF/$FRAMEWORK \
        -output $TEMP_DIR/simulator/$FRAMEWORK.dSYM/Contents/Resources/DWARF/$FRAMEWORK
    
    copy_frameworks $FRAMEWORK

    xcodebuild -create-xcframework -framework $TEMP_DIR/device/$FRAMEWORK.framework -debug-symbols $TEMP_DIR/device/$FRAMEWORK.dSYM \
        -framework $TEMP_DIR/simulator/$FRAMEWORK.framework -debug-symbols $TEMP_DIR/simulator/$FRAMEWORK.dSYM \
        -output Frameworks/$FRAMEWORK.xcframework
done

