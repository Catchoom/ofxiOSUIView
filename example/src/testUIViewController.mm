//
//  testUIViewController.m
//  emptyExample
//
//  Created by Luis Martinell Andreu on 03/01/2018.
//

#import "testUIViewController.h"

@interface testUIViewController  () <ofxiOSUIViewProtocol> {
    ofFbo fbo;
}

@end

@implementation testUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.glView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) ofxiOSViewSetup {
    ofBackground(ofColor::black);
    ofEnableAlphaBlending();
    
    fbo.allocate(ofGetWidth(), ofGetHeight());
}

- (void) ofxiOSViewUpdate {
}

- (void) ofxiOSViewDraw {
    
    stringstream info;
    info << "ofGetWidth(): " << ofGetWidth()  << endl;
    info << "ofGetHeight(): " << ofGetHeight()    << endl;
    info << "ofGetScreenWidth(): " << ofGetScreenWidth()  << endl;
    info << "ofGetScreenHeight: " << ofGetScreenHeight()    << endl;
    info << "ofGetWindowWidth: " << ofGetWindowWidth()  << endl;
    info << "ofGetWindowHeight: " << ofGetWindowHeight()    << endl;
    
    info << ofGetFrameNum()    << endl;
    
    int w = MIN(ofGetWidth(), ofGetHeight()) * 0.6;
    int h = w;
    int x = (ofGetWidth() - w)  * 0.5;
    int y = (ofGetHeight() - h) * 0.5;
    int p = 0;
    
    ofPushStyle();
    
    GLint previousFboId = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &previousFboId);
    fbo.begin();
    ofSetColor(ofRandom(255), ofRandom(255), ofRandom(255), ofRandom(255));
    ofDrawCircle(ofRandom(ofGetWidth()), ofRandom(ofGetHeight()), 30);
    ofSetColor(255, 255, 255, 255);
    ofDrawBitmapString(info.str(), 20, 100);
    fbo.end();
    ofPopStyle();
    fbo.draw(0, 0);
    
    ofPushStyle();
    ofSetColor(ofColor::red);
    ofDrawRectangle(x, y, w, h);
    ofPopStyle();
    
    
    //ofDrawBitmapString(info.str(), 20, 100);
}

- (void) ofxiOSViewExit {
}

- (void) ofxiOSViewTouchUp:(ofTouchEventArgs &)touch {
}

- (void) ofxiOSViewTouchDown:(ofTouchEventArgs &)touch {
}

- (void) ofxiOSViewTouchDoubleTap:(ofTouchEventArgs &)touch {
}

- (void) ofxiOSViewTouchMoved:(ofTouchEventArgs &)touch {
}

- (void) ofxiOSViewTouchCancelled:(ofTouchEventArgs &)touch {
}

- (void) ofxiOSViewGotFocus {
}

- (void) ofxiOSViewLostFocus {
}

- (void) ofxiOSViewDeviceOrientationChanged:(int)newOrientation {
}

@end
