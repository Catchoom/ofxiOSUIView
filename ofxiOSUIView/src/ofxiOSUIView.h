//
//  ofxiOSUIView.h
//  iPhone+OF Static Library
//
//  Created by Luis Martinell Andreu on 12/01/2018.
//

#import <UIKit/UIKit.h>

#include "ofMain.h"
#import "ES1Renderer.h"
#import "ES2Renderer.h"
#include "ofAppiOSWindowUIView.h"

class ofxiOSBridgeApp;

@protocol ofxiOSUIViewProtocol;

@interface ofxiOSUIView : UIView {
    ofxiOSBridgeApp* app;
	//ofAppiOSWindow * window;
	ESRendererVersion rendererVersion;
	CGFloat scaleFactor;
	CGFloat scaleFactorPref;
	bool isViewLaidOut;
	ofiOSWindowSettings2 settings;
    shared_ptr<ofAppBaseWindow> mWindow;
}

@property (strong, nonatomic) ES1Renderer* renderer;
@property (strong, nonatomic) NSLock * glLock;
@property (strong, nonatomic) NSTimer* animationTimer;

@property (nonatomic, weak) id <ofxiOSUIViewProtocol> delegate;

@end

@protocol ofxiOSUIViewProtocol <NSObject>

- (void) ofxiOSViewSetup;
- (void) ofxiOSViewUpdate;
- (void) ofxiOSViewDraw;
- (void) ofxiOSViewExit;
- (void) ofxiOSViewTouchDown: (ofTouchEventArgs&) touch;
- (void) ofxiOSViewTouchMoved: (ofTouchEventArgs&) touch;
- (void) ofxiOSViewTouchUp: (ofTouchEventArgs&) touch;
- (void) ofxiOSViewTouchDoubleTap: (ofTouchEventArgs&) touch;
- (void) ofxiOSViewTouchCancelled: (ofTouchEventArgs&) touch;
- (void) ofxiOSViewLostFocus;
- (void) ofxiOSViewGotFocus;
- (void) ofxiOSViewDeviceOrientationChanged: (int) newOrientation;

@end

