#include "ofxiOSBridgeApp.h"

//--------------------------------------------------------------
ofxiOSBridgeApp :: ofxiOSBridgeApp (ofxiOSUIView* view) {
	mOfxiOSUIView = view;
    cout << "creating ofxiOSBridgeApp" << endl;
}

//--------------------------------------------------------------
ofxiOSBridgeApp :: ~ofxiOSBridgeApp () {
    cout << "destroying ofxiOSBridgeApp" << endl;
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::setup() {
	[mOfxiOSUIView.delegate ofxiOSViewSetup];
}


//--------------------------------------------------------------
void ofxiOSBridgeApp::update(){
	[mOfxiOSUIView.delegate ofxiOSViewUpdate];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::draw() {
	[mOfxiOSUIView.delegate ofxiOSViewDraw];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::exit() {
	[mOfxiOSUIView.delegate ofxiOSViewExit];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchDown(ofTouchEventArgs &touch){
	[mOfxiOSUIView.delegate ofxiOSViewTouchDown:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchMoved(ofTouchEventArgs &touch){
	[mOfxiOSUIView.delegate ofxiOSViewTouchDown:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchUp(ofTouchEventArgs &touch){
	[mOfxiOSUIView.delegate ofxiOSViewTouchUp:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchDoubleTap(ofTouchEventArgs &touch){
	[mOfxiOSUIView.delegate ofxiOSViewTouchDoubleTap:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::lostFocus(){
	[mOfxiOSUIView.delegate ofxiOSViewLostFocus];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::gotFocus(){
	[mOfxiOSUIView.delegate ofxiOSViewGotFocus];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofxiOSBridgeApp::deviceOrientationChanged(int newOrientation){
    [mOfxiOSUIView.delegate ofxiOSViewDeviceOrientationChanged:newOrientation];
}


//--------------------------------------------------------------
void ofxiOSBridgeApp::touchCancelled(ofTouchEventArgs& args){
	[mOfxiOSUIView.delegate ofxiOSViewTouchCancelled:args];
}

