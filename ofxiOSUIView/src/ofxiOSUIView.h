//
//  ofxiOSUIView.h
//  iPhone+OF Static Library
//
//  Created by Luis Martinell Andreu on 12/01/2018.
//

#import <UIKit/UIKit.h>

#include "ofMain.h"

class ofxiOSBridgeApp;

@protocol ofxiOSUIViewProtocol;

@interface ofxiOSUIView : UIView

@property (nonatomic, weak) id <ofxiOSUIViewProtocol> delegate;

@property (nonatomic) bool autoSetup;

- (void) setup;

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

