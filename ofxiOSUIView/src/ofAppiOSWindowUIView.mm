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
#include "ofAppiOSWindowUIView.h"
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
static ofAppiOSWindowUIView * _instance = NULL;
ofAppiOSWindowUIView * ofAppiOSWindowUIView::getInstance() {
	return _instance;
}

//----------------------------------------------------------------------------------- constructor / destructor.
ofAppiOSWindowUIView::ofAppiOSWindowUIView() : hasExited(false) {
	if(_instance == NULL) {
        _instance = this;
    } else {
        ofLog(OF_LOG_ERROR, "ofAppiOSWindow2 instantiated more than once");
    }
    bRetinaSupportedOnDevice = false;
    bRetinaSupportedOnDeviceChecked = false;
}

ofAppiOSWindowUIView::~ofAppiOSWindowUIView() {
    close();
	_instance = NULL;
}

void ofAppiOSWindowUIView::close() {
    if(hasExited == false){
        hasExited = true;
        events().notifyExit();
        events().disable();
    }
}

void ofAppiOSWindowUIView::setup(const ofWindowSettings & _settings) {
    const ofiOSWindowSettings2 * iosSettings = dynamic_cast<const ofiOSWindowSettings2*>(&_settings);
    if(iosSettings){
        setup(*iosSettings);
    } else{
        setup(ofiOSWindowSettings2(_settings));
    }
}

void ofAppiOSWindowUIView::setup(const ofGLESWindowSettings & _settings) {
    const ofiOSWindowSettings2 * iosSettings = dynamic_cast<const ofiOSWindowSettings2*>(&_settings);
    if(iosSettings){
        setup(*iosSettings);
    } else{
        setup(ofiOSWindowSettings2(_settings));
    }
}

void ofAppiOSWindowUIView::setup(const ofiOSWindowSettings2 & _settings) {
    settings = _settings;
	setup();
}

void ofAppiOSWindowUIView::setup() {
	
	
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
void ofAppiOSWindowUIView::setupOpenGL(int w, int h, ofWindowMode screenMode) {
	settings.windowMode = screenMode; // use this as flag for displaying status bar or not
    setup(settings);
}

void ofAppiOSWindowUIView::loop() {
    startAppWithDelegate(appDelegateName);
}

void ofAppiOSWindowUIView::run(ofBaseApp * appPtr){
    startAppWithDelegate(appDelegateName);
}

void ofAppiOSWindowUIView::startAppWithDelegate(std::string appDelegateClassName) {
    static bool bAppCreated = false;
    if(bAppCreated == true) {
        return;
    }
    bAppCreated = true;
    
    @autoreleasepool {
        UIApplicationMain(0, nil, nil, [NSString stringWithUTF8String:appDelegateClassName.c_str()]);
    }
}

void ofAppiOSWindowUIView::update() {
    
}
void ofAppiOSWindowUIView::draw() {
    
}


//----------------------------------------------------------------------------------- cursor.
void ofAppiOSWindowUIView::hideCursor() {
    // not supported on iOS.
}

void ofAppiOSWindowUIView::showCursor() {
    // not supported on iOS.
}

//----------------------------------------------------------------------------------- window / screen properties.
void ofAppiOSWindowUIView::setWindowPosition(int x, int y) {
    windowPosition.x = x;
    windowPosition.y = y;
}

void ofAppiOSWindowUIView::setWindowShape(int w, int h) {
    windowSize.x = w;
    windowSize.y = h;
}

glm::vec2	ofAppiOSWindowUIView::getWindowPosition() {
    return windowPosition;
}

glm::vec2	ofAppiOSWindowUIView::getWindowSize() {
	return windowSize;
}

glm::vec2	ofAppiOSWindowUIView::getScreenSize() {
	return screenSize;
}

int ofAppiOSWindowUIView::getWidth(){
	if(settings.enableHardwareOrientation == true ||
       orientation == OF_ORIENTATION_DEFAULT ||
       orientation == OF_ORIENTATION_180) {
		return (int)getWindowSize().x;
	}
	return (int)getWindowSize().y;
}

int ofAppiOSWindowUIView::getHeight(){
	if(settings.enableHardwareOrientation == true ||
       orientation == OF_ORIENTATION_DEFAULT ||
       orientation == OF_ORIENTATION_180) {
		return (int)getWindowSize().y;
	}
	return (int)getWindowSize().x;
}

ofWindowMode ofAppiOSWindowUIView::getWindowMode() {
	return settings.windowMode;
}

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
//----------------------------------------------------------------------------------- orientation.
void ofAppiOSWindowUIView::setOrientation(ofOrientation toOrientation) {
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

ofOrientation ofAppiOSWindowUIView::getOrientation() {
	return orientation;
}

bool ofAppiOSWindowUIView::doesHWOrientation() {
    return settings.enableHardwareOrientation;
}

//-----------------------------------------------------------------------------------
bool ofAppiOSWindowUIView::enableHardwareOrientation() {
    return (settings.enableHardwareOrientation = true);
}

bool ofAppiOSWindowUIView::disableHardwareOrientation() {
    return (settings.enableHardwareOrientation = false);
}

bool ofAppiOSWindowUIView::enableOrientationAnimation() {
    return (settings.enableHardwareOrientationAnimation = true);
}

bool ofAppiOSWindowUIView::disableOrientationAnimation() {
    return (settings.enableHardwareOrientationAnimation = false);
}

#endif

//-----------------------------------------------------------------------------------
void ofAppiOSWindowUIView::setWindowTitle(std::string title) {
    // not supported on iOS.
}

void ofAppiOSWindowUIView::setFullscreen(bool fullscreen) {
#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen withAnimation:UIStatusBarAnimationSlide];
#endif
    if(fullscreen) {
        settings.windowMode = OF_FULLSCREEN;
    } else {
        settings.windowMode = OF_WINDOW;
    }
}

void ofAppiOSWindowUIView::toggleFullscreen() {
    if(settings.windowMode == OF_FULLSCREEN) {
        setFullscreen(false);
    } else {
        setFullscreen(true);
    }
}



//-----------------------------------------------------------------------------------
bool ofAppiOSWindowUIView::enableRendererES2() {
    if(isRendererES2() == true) {
        return false;
    }
    std::shared_ptr<ofBaseRenderer>renderer (new ofGLProgrammableRenderer(this));
    ofSetCurrentRenderer(renderer);
    return true;
}

bool ofAppiOSWindowUIView::enableRendererES1() {
    if(isRendererES1() == true) {
        return false;
    }
    std::shared_ptr<ofBaseRenderer> renderer(new ofGLRenderer(this));
    ofSetCurrentRenderer(renderer);
    return true;
}


bool ofAppiOSWindowUIView::isProgrammableRenderer() {
    return (currentRenderer && currentRenderer->getType()==ofGLProgrammableRenderer::TYPE);
}

ofxiOSRendererType ofAppiOSWindowUIView::getGLESVersion() {
    return (ofxiOSRendererType)settings.glesVersion;
}

bool ofAppiOSWindowUIView::isRendererES2() {
    return (isProgrammableRenderer() && settings.glesVersion == 2);
}

bool ofAppiOSWindowUIView::isRendererES1() {
    return !isProgrammableRenderer();
}

//-----------------------------------------------------------------------------------
void ofAppiOSWindowUIView::enableSetupScreen() {
	settings.enableSetupScreen = true;
};

void ofAppiOSWindowUIView::disableSetupScreen() {
	settings.enableSetupScreen = false;
};

bool ofAppiOSWindowUIView::isSetupScreenEnabled() {
    return settings.enableSetupScreen;
}

void ofAppiOSWindowUIView::setVerticalSync(bool enabled) {
    // not supported on iOS.
}

//----------------------------------------------------------------------------------- retina.
bool ofAppiOSWindowUIView::enableRetina(float retinaScale) {
    if(isRetinaSupportedOnDevice()) {
        settings.enableRetina = true;
        settings.retinaScale = retinaScale;
    }
    return settings.enableRetina;
}

bool ofAppiOSWindowUIView::disableRetina() {
    return (settings.enableRetina = false);
}

bool ofAppiOSWindowUIView::isRetinaEnabled() {
    return settings.enableRetina;
}

bool ofAppiOSWindowUIView::isRetinaSupportedOnDevice() {
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

float ofAppiOSWindowUIView::getRetinaScale() {
    return settings.retinaScale;
}

//----------------------------------------------------------------------------------- depth buffer.
bool ofAppiOSWindowUIView::enableDepthBuffer() {
    return (settings.enableDepth = true);
}

bool ofAppiOSWindowUIView::disableDepthBuffer() {
    return (settings.enableDepth = false);
}

bool ofAppiOSWindowUIView::isDepthBufferEnabled() {
    return settings.enableDepth;
}

//----------------------------------------------------------------------------------- anti aliasing.
bool ofAppiOSWindowUIView::enableAntiAliasing(int samples) {
	settings.numOfAntiAliasingSamples = samples;
    return (settings.enableAntiAliasing = true);
}

bool ofAppiOSWindowUIView::disableAntiAliasing() {
    return (settings.enableAntiAliasing = false);
}

bool ofAppiOSWindowUIView::isAntiAliasingEnabled() {
    return settings.enableAntiAliasing;
}

int	ofAppiOSWindowUIView::getAntiAliasingSampleCount() {
    return settings.numOfAntiAliasingSamples;
}

//-----------------------------------------------------------------------------------
ofCoreEvents & ofAppiOSWindowUIView::events(){
    return coreEvents;
}

//-----------------------------------------------------------------------------------
std::shared_ptr<ofBaseRenderer> & ofAppiOSWindowUIView::renderer(){
    return currentRenderer;
}

ofiOSWindowSettings2 & ofAppiOSWindowUIView::getSettings() {
    return settings;
}
