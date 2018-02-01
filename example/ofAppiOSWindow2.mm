/***********************************************************************
 
 Copyright (c) 2008, 2009, Memo Akten, www.memo.tv
 *** The Mega Super Awesome Visuals Company ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of MSA Visuals nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 * ***********************************************************************/ 
#include <TargetConditionals.h>
#include "ofAppiOSWindow2.h"
#include "ofGLRenderer.h"
#include "ofGLProgrammableRenderer.h"
#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
    #include "ofxiOSAppDelegate.h"
    #include "ofxiOSViewController.h"
    const std::string appDelegateName = "ofxiOSAppDelegate";
#elif TARGET_OS_TV
    #include "ofxtvOSAppDelegate.h"
    #include "ofxtvOSViewController.h"
    const std::string appDelegateName = "ofxtvOSAppDelegate";
#endif
#include "ofxiOSEAGLView.h"

//----------------------------------------------------------------------------------- instance.
static ofAppiOSWindow2 * _instance = NULL;
ofAppiOSWindow2 * ofAppiOSWindow2::getInstance() {
	return _instance;
}

//----------------------------------------------------------------------------------- constructor / destructor.
ofAppiOSWindow2::ofAppiOSWindow2() : hasExited(false) {
	if(_instance == NULL) {
        _instance = this;
    } else {
        ofLog(OF_LOG_ERROR, "ofAppiOSWindow2 instantiated more than once");
    }
    bRetinaSupportedOnDevice = false;
    bRetinaSupportedOnDeviceChecked = false;
}

ofAppiOSWindow2::~ofAppiOSWindow2() {
    close();
	_instance = NULL;
}

void ofAppiOSWindow2::close() {
    if(hasExited == false){
        hasExited = true;
        events().notifyExit();
        events().disable();
    }
}

void ofAppiOSWindow2::setup(const ofWindowSettings & _settings) {
    const ofiOSWindowSettings2 * iosSettings = dynamic_cast<const ofiOSWindowSettings2*>(&_settings);
    if(iosSettings){
        setup(*iosSettings);
    } else{
        setup(ofiOSWindowSettings2(_settings));
    }
}

void ofAppiOSWindow2::setup(const ofGLESWindowSettings & _settings) {
    const ofiOSWindowSettings2 * iosSettings = dynamic_cast<const ofiOSWindowSettings2*>(&_settings);
    if(iosSettings){
        setup(*iosSettings);
    } else{
        setup(ofiOSWindowSettings2(_settings));
    }
}

void ofAppiOSWindow2::setup(const ofiOSWindowSettings2 & _settings) {
    settings = _settings;
	setup();
}

void ofAppiOSWindow2::setup() {
	
	
	if(settings.setupOrientation == OF_ORIENTATION_UNKNOWN) {
		settings.setupOrientation = OF_ORIENTATION_DEFAULT;
	}
	setOrientation(settings.setupOrientation);
	if(settings.glesVersion >= ESRendererVersion_20) {
		currentRenderer = std::shared_ptr<ofBaseRenderer>(new ofGLProgrammableRenderer(this));
	} else {
		currentRenderer = std::shared_ptr<ofBaseRenderer>(new ofGLRenderer(this));
	}
	
	hasExited = false;
}

//----------------------------------------------------------------------------------- opengl setup.
void ofAppiOSWindow2::setupOpenGL(int w, int h, ofWindowMode screenMode) {
	settings.windowMode = screenMode; // use this as flag for displaying status bar or not
    setup(settings);
}

void ofAppiOSWindow2::loop() {
    startAppWithDelegate(appDelegateName);
}

void ofAppiOSWindow2::run(ofBaseApp * appPtr){
    startAppWithDelegate(appDelegateName);
}

void ofAppiOSWindow2::startAppWithDelegate(std::string appDelegateClassName) {
    static bool bAppCreated = false;
    if(bAppCreated == true) {
        return;
    }
    bAppCreated = true;
    
    @autoreleasepool {
        UIApplicationMain(0, nil, nil, [NSString stringWithUTF8String:appDelegateClassName.c_str()]);
    }
}

void ofAppiOSWindow2::update() {
    
}
void ofAppiOSWindow2::draw() {
    
}


//----------------------------------------------------------------------------------- cursor.
void ofAppiOSWindow2::hideCursor() {
    // not supported on iOS.
}

void ofAppiOSWindow2::showCursor() {
    // not supported on iOS.
}

//----------------------------------------------------------------------------------- window / screen properties.
void ofAppiOSWindow2::setWindowPosition(int x, int y) {
    windowPosition.x = x;
    windowPosition.y = y;
}

void ofAppiOSWindow2::setWindowShape(int w, int h) {
    windowSize.x = w;
    windowSize.y = h;
}

glm::vec2	ofAppiOSWindow2::getWindowPosition() {
    return windowPosition;
}

glm::vec2	ofAppiOSWindow2::getWindowSize() {
	return windowSize;
}

glm::vec2	ofAppiOSWindow2::getScreenSize() {
	return screenSize;
}

int ofAppiOSWindow2::getWidth(){
	if(settings.enableHardwareOrientation == true ||
       orientation == OF_ORIENTATION_DEFAULT ||
       orientation == OF_ORIENTATION_180) {
		return (int)getWindowSize().x;
	}
	return (int)getWindowSize().y;
}

int ofAppiOSWindow2::getHeight(){
	if(settings.enableHardwareOrientation == true ||
       orientation == OF_ORIENTATION_DEFAULT ||
       orientation == OF_ORIENTATION_180) {
		return (int)getWindowSize().y;
	}
	return (int)getWindowSize().x;
}

ofWindowMode ofAppiOSWindow2::getWindowMode() {
	return settings.windowMode;
}

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
//----------------------------------------------------------------------------------- orientation.
void ofAppiOSWindow2::setOrientation(ofOrientation toOrientation) {
    if(orientation == toOrientation) {
        return;
    }
    bool bOrientationPortraitOne = (orientation == OF_ORIENTATION_DEFAULT) || (orientation == OF_ORIENTATION_180);
    bool bOrientationPortraitTwo = (toOrientation == OF_ORIENTATION_DEFAULT) || (toOrientation == OF_ORIENTATION_180);
    bool bResized = bOrientationPortraitOne != bOrientationPortraitTwo;

    orientation = toOrientation;
#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    switch (orientation) {
        case OF_ORIENTATION_DEFAULT:
            interfaceOrientation = UIInterfaceOrientationPortrait;
            break;
        case OF_ORIENTATION_180:
            interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case OF_ORIENTATION_90_RIGHT:
            interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case OF_ORIENTATION_90_LEFT:
            interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            break;
    }


    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate respondsToSelector:@selector(glViewController)] == NO) {
        // check app delegate has glViewController,
        // otherwise calling glViewController will cause a crash.
        return;
    }
    ofxiOSViewController * glViewController = ((ofxiOSAppDelegate *)appDelegate).glViewController;
    ofxiOSEAGLView * glView = glViewController.glView;
	
    if(settings.enableHardwareOrientation == true) {
        [glViewController rotateToInterfaceOrientation:interfaceOrientation animated:settings.enableHardwareOrientationAnimation];
    } else {
        [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:settings.enableHardwareOrientationAnimation];
        if(bResized == true) {
            [glView layoutSubviews]; // calling layoutSubviews so window resize notification is fired.
        }
    }
#endif
}

ofOrientation ofAppiOSWindow2::getOrientation() {
	return orientation;
}

bool ofAppiOSWindow2::doesHWOrientation() {
    return settings.enableHardwareOrientation;
}

//-----------------------------------------------------------------------------------
bool ofAppiOSWindow2::enableHardwareOrientation() {
    return (settings.enableHardwareOrientation = true);
}

bool ofAppiOSWindow2::disableHardwareOrientation() {
    return (settings.enableHardwareOrientation = false);
}

bool ofAppiOSWindow2::enableOrientationAnimation() {
    return (settings.enableHardwareOrientationAnimation = true);
}

bool ofAppiOSWindow2::disableOrientationAnimation() {
    return (settings.enableHardwareOrientationAnimation = false);
}

#endif

//-----------------------------------------------------------------------------------
void ofAppiOSWindow2::setWindowTitle(std::string title) {
    // not supported on iOS.
}

void ofAppiOSWindow2::setFullscreen(bool fullscreen) {
#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen withAnimation:UIStatusBarAnimationSlide];
#endif
    if(fullscreen) {
        settings.windowMode = OF_FULLSCREEN;
    } else {
        settings.windowMode = OF_WINDOW;
    }
}

void ofAppiOSWindow2::toggleFullscreen() {
    if(settings.windowMode == OF_FULLSCREEN) {
        setFullscreen(false);
    } else {
        setFullscreen(true);
    }
}



//-----------------------------------------------------------------------------------
bool ofAppiOSWindow2::enableRendererES2() {
    if(isRendererES2() == true) {
        return false;
    }
    std::shared_ptr<ofBaseRenderer>renderer (new ofGLProgrammableRenderer(this));
    ofSetCurrentRenderer(renderer);
    return true;
}

bool ofAppiOSWindow2::enableRendererES1() {
    if(isRendererES1() == true) {
        return false;
    }
    std::shared_ptr<ofBaseRenderer> renderer(new ofGLRenderer(this));
    ofSetCurrentRenderer(renderer);
    return true;
}


bool ofAppiOSWindow2::isProgrammableRenderer() {
    return (currentRenderer && currentRenderer->getType()==ofGLProgrammableRenderer::TYPE);
}

ofxiOSRendererType ofAppiOSWindow2::getGLESVersion() {
    return (ofxiOSRendererType)settings.glesVersion;
}

bool ofAppiOSWindow2::isRendererES2() {
    return (isProgrammableRenderer() && settings.glesVersion == 2);
}

bool ofAppiOSWindow2::isRendererES1() {
    return !isProgrammableRenderer();
}

//-----------------------------------------------------------------------------------
void ofAppiOSWindow2::enableSetupScreen() {
	settings.enableSetupScreen = true;
};

void ofAppiOSWindow2::disableSetupScreen() {
	settings.enableSetupScreen = false;
};

bool ofAppiOSWindow2::isSetupScreenEnabled() {
    return settings.enableSetupScreen;
}

void ofAppiOSWindow2::setVerticalSync(bool enabled) {
    // not supported on iOS.
}

//----------------------------------------------------------------------------------- retina.
bool ofAppiOSWindow2::enableRetina(float retinaScale) {
    if(isRetinaSupportedOnDevice()) {
        settings.enableRetina = true;
        settings.retinaScale = retinaScale;
    }
    return settings.enableRetina;
}

bool ofAppiOSWindow2::disableRetina() {
    return (settings.enableRetina = false);
}

bool ofAppiOSWindow2::isRetinaEnabled() {
    return settings.enableRetina;
}

bool ofAppiOSWindow2::isRetinaSupportedOnDevice() {
    if(bRetinaSupportedOnDeviceChecked) {
        return bRetinaSupportedOnDevice;
    }
    
    bRetinaSupportedOnDeviceChecked = true;
    
    @autoreleasepool {
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            if ([[UIScreen mainScreen] scale] > 1){
                bRetinaSupportedOnDevice = true;
            }
        }
    }
    
    return bRetinaSupportedOnDevice;
}

float ofAppiOSWindow2::getRetinaScale() {
    return settings.retinaScale;
}

//----------------------------------------------------------------------------------- depth buffer.
bool ofAppiOSWindow2::enableDepthBuffer() {
    return (settings.enableDepth = true);
}

bool ofAppiOSWindow2::disableDepthBuffer() {
    return (settings.enableDepth = false);
}

bool ofAppiOSWindow2::isDepthBufferEnabled() {
    return settings.enableDepth;
}

//----------------------------------------------------------------------------------- anti aliasing.
bool ofAppiOSWindow2::enableAntiAliasing(int samples) {
	settings.numOfAntiAliasingSamples = samples;
    return (settings.enableAntiAliasing = true);
}

bool ofAppiOSWindow2::disableAntiAliasing() {
    return (settings.enableAntiAliasing = false);
}

bool ofAppiOSWindow2::isAntiAliasingEnabled() {
    return settings.enableAntiAliasing;
}

int	ofAppiOSWindow2::getAntiAliasingSampleCount() {
    return settings.numOfAntiAliasingSamples;
}

//-----------------------------------------------------------------------------------
ofCoreEvents & ofAppiOSWindow2::events(){
    return coreEvents;
}

//-----------------------------------------------------------------------------------
std::shared_ptr<ofBaseRenderer> & ofAppiOSWindow2::renderer(){
    return currentRenderer;
}

ofiOSWindowSettings2 & ofAppiOSWindow2::getSettings() {
    return settings;
}
