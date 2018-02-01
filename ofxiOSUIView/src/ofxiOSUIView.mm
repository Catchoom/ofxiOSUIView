    //
//  ofxiOSUIView.m
//  iPhone+OF Static Library
//
//  Created by Luis Martinell Andreu on 12/01/2018.
//

#import "ofxiOSUIView.h"

#import "ofxiOSBridgeApp.h"
#include "ofxiOS.h"
#include "ofAppiOSWindow2.h"

@implementation ofxiOSUIView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id) init {
	self = [super init];
	if (self) {
		[self initializeRenderer];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initializeRenderer];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self initializeRenderer];
	}
	return self;
}

- (void) initializeRenderer {
	scaleFactorPref = 2.0f;
	CAEAGLLayer * eaglLayer = (CAEAGLLayer *)self.layer;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	self.multipleTouchEnabled = true;
	self.opaque = YES;
	self.clipsToBounds = YES;
	
	settings.enableRetina = true; // enables retina resolution if the device supports it.
	settings.enableDepth = true; // enables depth buffer for 3d drawing.
	settings.enableAntiAliasing = false; // enables anti-aliasing which smooths out graphics on the screen.
	settings.numOfAntiAliasingSamples = 0; // number of samples used for anti-aliasing.
	settings.enableHardwareOrientation = true; // enables native view orientation.
	settings.enableHardwareOrientationAnimation = false; // enables native orientation changes to be animated.
	settings.glesVersion = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, ES3
	//settings.windowMode = OF_FULLSCREEN;
	
	//self->window = (ofAppiOSWindow *)(ofCreateWindow(settings).get());
    ofInit();
    
    ofiOSWindowSettings2 windowSettings;
    mWindow = std::make_shared<ofAppiOSWindow2>();
    mWindow->setup(windowSettings);
    ofGetMainLoop()->setCurrentWindow(mWindow);

	
	rendererVersion = ESRendererVersion_11;
	//rendererVersion = ESRendererVersion_20;
	self.renderer = [[ES1Renderer alloc] initWithDepth:settings.enableDepth
												 andAA:settings.enableAntiAliasing
										andFSAASamples:settings.numOfAntiAliasingSamples
											 andRetina:settings.enableRetina];
	/*
	 if(self->window->isProgrammableRenderer() == true) {
	 static_cast<ofGLProgrammableRenderer*>(self->window->renderer().get())->setup(settings.glesVersion, 0);
	 } else{
	 static_cast<ofGLRenderer*>(self->window->renderer().get())->setup();
	 }
	 */
    }


- (void)drawView:(id)sender {
	// NSLog(@"Window size: %f, %f", self.bounds.size.width, self.bounds.size.height);	
	
	[self.glLock lock];
	[self.renderer startRender];
	
	self->mWindow->events().notifyUpdate();
	
	self->mWindow->renderer()->startRender();
	
	if(((ofAppiOSWindow2*)self->mWindow.get())->isSetupScreenEnabled())
	{
		self->mWindow->renderer()->setupScreen();
	}
	
	self->mWindow->events().notifyDraw();
	
	self->mWindow->renderer()->finishRender();
	
	[self.renderer finishRender];
	[self.glLock unlock];
}

- (void) updateViewLayout {
    [self printDimensions];
    [self updateScaleFactor];
    
    [self.renderer startRender];
    [self.renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self.renderer finishRender];
    
    [self updateDimensions];
    
}

-(void) setupOfApp {
    [self updateViewLayout];
	
	if(((ofAppiOSWindow2*)self->mWindow.get())->isProgrammableRenderer() == true) {
		//static_cast<ofGLProgrammableRenderer*>(self->window->renderer().get())->setup(settings.glesVersion, 0);
	} else{
		static_cast<ofGLRenderer*>(self->mWindow->renderer().get())->setup();
	}
	
    self->app = new ofxiOSBridgeApp(self);
    ofRunApp(mWindow, std::move(std::shared_ptr<ofBaseApp>(self->app)));

    ofxiOSAlerts.addListener((ofxiOSBridgeApp*)self->app);
	
	ofDisableTextureEdgeHack();
	
	//self->mWindow->events().notifySetup();
	//self->window->renderer()->clear();
	
	int animationFrameInterval = 1;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval)
														   target:self
														 selector:@selector(drawView:)
														 userInfo:nil
														  repeats:TRUE];
}

-(void) didMoveToSuperview {
	[self updateDimensions];
}

- (void) didMoveToWindow {
	[self updateDimensions];
}

- (void) layoutSubviews {
	NSLog(@"Layout subviews");
	[self updateDimensions];
	if (isViewLaidOut) {
        [self updateViewLayout];
	} else {
		[self setupOfApp];
		isViewLaidOut = true;
	}
}


- (void) removeFromSuperview {
	[self.animationTimer invalidate];
	self.animationTimer = nil;
	self->mWindow->close();
}

-(void)printFrame:(CGRect)rect label:(NSString*)comment
{
	NSLog(@"%@ x: %f y: %f w: %f h: %f",
		  comment,
		  rect.origin.x,
		  rect.origin.y,
		  rect.size.width,
		  rect.size.height);
	
}

-(void)printDimensions
{
	[self printFrame:self.frame label:@"view.frame"];
	[self printFrame:[[UIScreen mainScreen] bounds] label:@"currentScreen.bounds"];
}

- (void)updateScaleFactor
{
	UIScreen * currentScreen = self.window.screen;
	if(currentScreen == nil) {
		currentScreen = [UIScreen mainScreen];
	}
	
	if([currentScreen respondsToSelector:@selector(scale)] == NO) {
		return;
	}
	
	scaleFactor = MIN(scaleFactorPref, [currentScreen scale]);
	if(!scaleFactor)
	{
		scaleFactor = 1;
	}
	if(scaleFactor != self.contentScaleFactor)
	{
		self.contentScaleFactor = scaleFactor;
	}
}


- (void)updateDimensions
{
	
	//self->window->windowPos.set(self.frame.origin.x * scaleFactor, self.frame.origin.y * scaleFactor, 0);
	//self->window->windowSize.set(self.bounds.size.width * scaleFactor, self.bounds.size.height * scaleFactor, 0);
    ofAppiOSWindow2* window = (ofAppiOSWindow2*)ofGetMainLoop()->getCurrentWindow().get();
    
    window->setWindowPosition(self.frame.origin.x * scaleFactor, self.frame.origin.y * scaleFactor);
    window->setWindowShape(self.bounds.size.width * scaleFactor, self.bounds.size.height * scaleFactor);
	
	NSLog(@"Window size: %f, %f", self.bounds.size.width, self.bounds.size.height);
	UIScreen * currentScreen = self.window.screen;  // current screen is the screen that GLView is attached to.
	if(!currentScreen) {                            // if GLView is not attached, assume to be main device screen.
		currentScreen = [UIScreen mainScreen];
	}
    
    window->screenSize.x = currentScreen.bounds.size.width * scaleFactor;
    window->screenSize.y = currentScreen.bounds.size.height * scaleFactor;
    
	//self->window->screenSize.set(currentScreen.bounds.size.width * scaleFactor, currentScreen.bounds.size.height * scaleFactor, 0);
}

#pragma mark protocol

- (void) ofxiOSViewSetup {
	[self.delegate ofxiOSViewSetup];
}

- (void) ofxiOSViewUpdate {
	[self.delegate ofxiOSViewUpdate];
}

- (void) ofxiOSViewDraw {
	[self.delegate ofxiOSViewDraw];
}

- (void) ofxiOSViewExit {
	[self.delegate ofxiOSViewExit];
}

- (void) ofxiOSViewTouchUp:(ofTouchEventArgs &)touch {
	[self.delegate ofxiOSViewTouchUp:touch];
}

- (void) ofxiOSViewTouchDown:(ofTouchEventArgs &)touch {
	[self.delegate ofxiOSViewTouchDown:touch];
}

- (void) ofxiOSViewTouchDoubleTap:(ofTouchEventArgs &)touch {
	[self.delegate ofxiOSViewTouchDoubleTap:touch];
}

- (void) ofxiOSViewTouchMoved:(ofTouchEventArgs &)touch {
	[self.delegate ofxiOSViewTouchMoved:touch];
}

- (void) ofxiOSViewTouchCancelled:(ofTouchEventArgs &)touch {
	[self.delegate ofxiOSViewTouchCancelled:touch];
}

- (void) ofxiOSViewGotFocus {
	[self.delegate ofxiOSViewGotFocus];
}

- (void) ofxiOSViewLostFocus {
	[self.delegate ofxiOSViewLostFocus];
}

- (void) ofxiOSViewDeviceOrientationChanged:(int)newOrientation {
	[self.delegate ofxiOSViewDeviceOrientationChanged:newOrientation];
}

#pragma mark -


@end
