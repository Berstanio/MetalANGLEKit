//
// Copyright 2019 Le Hoang Quyen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//

#import "MGLDisplay.h"
#import <Metal/MTLDevice.h>

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <EGL/eglext_angle.h>
#include <EGL/eglplatform.h>

namespace
{
void Throw(NSString *msg)
{
    [NSException raise:@"MGLSurfaceException" format:@"%@", msg];
}
}

bool IsMetalDisplayAvailable()
{
    static int sHasMetalDevice = -1;

    if (sHasMetalDevice != -1)
    {
        return sHasMetalDevice;
    }
    // We only support macos 10.13+ and 11 for now. Since they are requirements for Metal 2.0.
#if TARGET_OS_SIMULATOR
    if (@available(macOS 10.13, macCatalyst 13.0, iOS 13, *))
#else
    if (@available(macOS 10.13, macCatalyst 13.0, iOS 11, *))
#endif
    {
        @autoreleasepool
        {
#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
            // On MacOS we need another method to determin whether Metal is supported.
            NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
            if ([devices count] == 0)
#else
            // This doesn't seem to work always
            // (https://stackoverflow.com/questions/59116802/how-to-check-if-metal-is-supported)
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            if (!device)
#endif
            {
                NSLog(@"Can't get Metal device. Metal Display won't be available.");
                sHasMetalDevice = 0;
            }
            else
            {
                sHasMetalDevice = 1;
            }
        }
        return sHasMetalDevice;
    }
    NSLog(@"The device is too old to support Metal. Falling back to OpenGL.");
    sHasMetalDevice = 0;
    return sHasMetalDevice;
}


// EGLDisplayHolder
@interface EGLDisplayHolder : NSObject
@property(nonatomic) EGLDisplay eglDisplay;
@end

@implementation EGLDisplayHolder

- (id)init
{
    if (self = [super init])
    {
        // Init display
        EGLAttrib displayAttribs[] = {EGL_NONE};
        _eglDisplay = eglGetPlatformDisplay(EGL_PLATFORM_ANGLE_ANGLE, nullptr, displayAttribs);
        if (_eglDisplay == EGL_NO_DISPLAY)
        {
            Throw(@"Failed To call eglGetPlatformDisplay()");
        }
        if (!eglInitialize(_eglDisplay, NULL, NULL))
        {
            Throw(@"Failed To call eglInitialize()");
        }
    }

    return self;
}

- (void)dealloc
{
    if (_eglDisplay != EGL_NO_DISPLAY)
    {
        eglTerminate(_eglDisplay);
        _eglDisplay = EGL_NO_DISPLAY;
    }
}

@end

static EGLDisplayHolder *gGlobalDisplayHolder;
static MGLDisplay *gDefaultDisplay;

// MGLDisplay implementation
@interface MGLDisplay () {
    EGLDisplayHolder *_eglDisplayHolder;
}

@end

@implementation MGLDisplay

+ (MGLDisplay *)defaultDisplay
{
    if (!gDefaultDisplay)
    {
        gDefaultDisplay = [[MGLDisplay alloc] init];
    }
    return gDefaultDisplay;
}

- (id)init
{
    if (self = [super init])
    {
        if (!gGlobalDisplayHolder)
        {
            gGlobalDisplayHolder = [[EGLDisplayHolder alloc] init];
        }
        _eglDisplayHolder = gGlobalDisplayHolder;
        _eglDisplay       = _eglDisplayHolder.eglDisplay;
    }

    return self;
}

@end
