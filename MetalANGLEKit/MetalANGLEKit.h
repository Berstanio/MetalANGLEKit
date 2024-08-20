//
//  MetalANGLEKit.h
//  MetalANGLEKit
//
//  Created by berstanio on 13.08.24.
//

#import <Foundation/Foundation.h>

//! Project version number for MetalANGLEKit.
FOUNDATION_EXPORT double MetalANGLEKitVersionNumber;

//! Project version string for MetalANGLEKit.
FOUNDATION_EXPORT const unsigned char MetalANGLEKitVersionString[];

#ifndef METALANGLEKIT_INCLUDE
#define METALANGLEKIT_INCLUDE
#endif

// In this header, you should import all the public headers of your framework using statements like #import <MetalANGLEKit/PublicHeader.h>
#import <MetalANGLEKit/MGLContext.h>
#import <MetalANGLEKit/MGLLayer.h>
#import <MetalANGLEKit/MGLKView.h>
#import <MetalANGLEKit/MGLKViewController.h>
#import <MetalANGLEKit/MGLKitPlatform.h>
#import <MetalANGLEKit/MGLDisplay.h>
#import <MetalANGLEKit/EGL/eglext.h>
#import <MetalANGLEKit/GLES/egl.h>
#import <MetalANGLEKit/GLES/glext.h>
#import <MetalANGLEKit/GLES2/gl2.h>
#import <MetalANGLEKit/GLES2/gl2ext.h>
#import <MetalANGLEKit/GLES3/gl3.h>
#import <MetalANGLEKit/GLES3/gl31.h>
#import <MetalANGLEKit/GLES3/gl32.h>
#import <MetalANGLEKit/feature_support_util.h>
