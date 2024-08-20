#!/bin/bash

apply_git_patch() {
    local patch_file=$1

    if git apply --check --reverse < "$patch_file" > /dev/null 2>&1; then
        echo "Already applied $patch_file"
    else
        if git apply < "$patch_file" > /dev/null 2>&1; then
            echo "Applied $patch_file"
        else
            echo "Failed to apply $patch_file" >&2
            exit 1
        fi
    fi
}

cd "$(dirname "$0")"

export PATH="$(pwd)/depot_tools:$PATH"

cd angle

python3 scripts/bootstrap.py
gclient sync

apply_git_patch ../angle_include_fix.patch
apply_git_patch ../angle_metal_default_fix.patch
apply_git_patch ../angle_feature_util_fix.patch
apply_git_patch ../angle_feature_util_metal_check.patch

gn gen out/Debug-iphonesimulator_arm64 --args="is_debug=true enable_dsyms=true target_os=\"ios\" target_cpu=\"arm64\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Debug-iphonesimulator_x86_64 --args="is_debug=true enable_dsyms=true target_os=\"ios\" target_cpu=\"x64\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Debug-iphoneos --args="is_debug=true enable_dsyms=true target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"device\""

gn gen out/Release-iphonesimulator_arm64 --args="is_official_build=true target_os=\"ios\" target_cpu=\"arm64\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Release-iphonesimulator_x86_64 --args="is_official_build=true target_os=\"ios\" target_cpu=\"x64\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"simulator\""
gn gen out/Release-iphoneos --args="is_official_build=true target_os=\"ios\" ios_enable_code_signing=false angle_enable_metal=true angle_enable_wgpu=false ios_deployment_target=\"11.0\" angle_build_all=false target_environment=\"device\""
