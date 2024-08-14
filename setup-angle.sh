#!/bin/bash
cd "$(dirname "$0")"

export PATH="$(pwd)/depot_tools:$PATH"

cd angle

python3 scripts/bootstrap.py
gclient sync

rm -r out/

gn gen out/Debug-iphonesimulator_arm64 --args="target_cpu=\"arm64\" is_debug=true target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Debug-iphonesimulator_x86_64 --args="target_cpu=\"x64\" is_debug=true target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Debug-iphoneos --args="is_debug=true target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"device\""

gn gen out/Release-iphonesimulator_arm64 --args="target_cpu=\"arm64\" is_debug=false target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Release-iphonesimulator_x86_64 --args="target_cpu=\"x64\" is_debug=false target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Release-iphoneos --args="is_debug=false target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"device\""
