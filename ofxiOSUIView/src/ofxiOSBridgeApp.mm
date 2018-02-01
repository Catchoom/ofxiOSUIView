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
	[mOfxiOSUIView ofxiOSViewSetup];
}


//--------------------------------------------------------------
void ofxiOSBridgeApp::update(){
	[mOfxiOSUIView ofxiOSViewUpdate];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::draw() {
	[mOfxiOSUIView ofxiOSViewDraw];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::exit() {
	[mOfxiOSUIView ofxiOSViewExit];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchDown(ofTouchEventArgs &touch){
	[mOfxiOSUIView ofxiOSViewTouchDown:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchMoved(ofTouchEventArgs &touch){
	[mOfxiOSUIView ofxiOSViewTouchDown:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchUp(ofTouchEventArgs &touch){
	[mOfxiOSUIView ofxiOSViewTouchUp:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::touchDoubleTap(ofTouchEventArgs &touch){
	[mOfxiOSUIView ofxiOSViewTouchDoubleTap:touch];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::lostFocus(){
	[mOfxiOSUIView ofxiOSViewLostFocus];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::gotFocus(){
	[mOfxiOSUIView ofxiOSViewGotFocus];
}

//--------------------------------------------------------------
void ofxiOSBridgeApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofxiOSBridgeApp::deviceOrientationChanged(int newOrientation){
	[mOfxiOSUIView ofxiOSViewDeviceOrientationChanged:newOrientation];
}


//--------------------------------------------------------------
void ofxiOSBridgeApp::touchCancelled(ofTouchEventArgs& args){
	[mOfxiOSUIView ofxiOSViewTouchCancelled:args];
}

