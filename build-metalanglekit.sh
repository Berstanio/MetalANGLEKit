#!/bin/sh
rm -r build
mkdir build

xcodebuild archive \
    -project MetalANGLEKit.xcodeproj \
    -scheme MetalANGLEKit \
    -destination "generic/platform=iOS" \
    -archivePath "build/MetalANGLEKit-iOS"

xcodebuild archive \
    -project MetalANGLEKit.xcodeproj \
    -scheme MetalANGLEKit \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "build/MetalANGLEKit-iOS_Simulator"

xcodebuild -create-xcframework \
    -archive build/MetalANGLEKit-iOS_Simulator.xcarchive -framework MetalANGLEKit.framework \
    -archive build/MetalANGLEKit-iOS.xcarchive -framework MetalANGLEKit.framework \
    -output build/MetalANGLEKit.xcframework