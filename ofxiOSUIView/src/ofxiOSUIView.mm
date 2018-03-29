    //
//  ofxiOSUIView.m
//  iPhone+OF Static Library
//
//  Created by Luis Martinell Andreu on 12/01/2018.
//

#import "ofxiOSUIView.h"

#import "ofxiOSBridgeApp.h"
#include "ofxiOS.h"
#include "ofAppiOSWindowUIView.h"
#import "ES1Renderer.h"
#import "ES2Renderer.h"
#include "ofAppiOSWindowUIView.h"

@interface ofxiOSUIView () {
    ofxiOSBridgeApp* app;
    ESRendererVersion rendererVersion;
    CGFloat scaleFactor;
    CGFloat scaleFactorPref;
    bool isViewLaidOut;
    ofiOSWindowSettings2 settings;
    shared_ptr<ofAppBaseWindow> mWindow;
    NSMutableDictionary    * activeTouches;
    bool bInit;
    
    ES1Renderer* renderer;
    NSLock * glLock;
    NSTimer* animationTimer;
    
    CADisplayLink* displayLink;
}
@end

@implementation ofxiOSUIView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id) init {
	self = [super init];
	if (self) {
        self.autoSetup = YES;
		[self initializeRenderer];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
        self.autoSetup = YES;
		[self initializeRenderer];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
        self.autoSetup = YES;
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
    
    ofSetDataPathRoot([[NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]] cStringUsingEncoding:NSUTF8StringEncoding]);
    
    ofInit();
    
    ofiOSWindowSettings2 windowSettings;
    mWindow = std::make_shared<ofAppiOSWindowUIView>();
    mWindow->setup(windowSettings);
    ofGetMainLoop()->setCurrentWindow(mWindow);

	
	rendererVersion = ESRendererVersion_11;
	//rendererVersion = ESRendererVersion_20;
	renderer = [[ES1Renderer alloc] initWithDepth:settings.enableDepth
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
    
    activeTouches = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActive:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void) toggleActive: (NSNotification*) notification {
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {

        displayLink.paused = NO;
    } else {

        displayLink.paused = YES;
    }
}

- (void)drawView:(id)sender {
	// NSLog(@"Window size: %f, %f", self.bounds.size.width, self.bounds.size.height);
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
	[glLock lock];
	[renderer startRender];
	
	self->mWindow->events().notifyUpdate();
	
	self->mWindow->renderer()->startRender();
	
	if(((ofAppiOSWindowUIView*)self->mWindow.get())->isSetupScreenEnabled())
	{
		self->mWindow->renderer()->setupScreen();
	}
	
	self->mWindow->events().notifyDraw();
	
	self->mWindow->renderer()->finishRender();
	
	[renderer finishRender];
	[glLock unlock];
}

- (void) updateViewLayout {
    [self printDimensions];
    [self updateScaleFactor];
    
    [renderer startRender];
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [renderer finishRender];
    
    [self updateDimensions];
    
}

- (void) setup {
    [self setupOfApp];
}

-(void) setupOfApp {
    isViewLaidOut = true;
    [self updateViewLayout];
	
	if(((ofAppiOSWindowUIView*)self->mWindow.get())->isProgrammableRenderer() == true) {
		//static_cast<ofGLProgrammableRenderer*>(self->window->renderer().get())->setup(settings.glesVersion, 0);
	} else{
		static_cast<ofGLRenderer*>(self->mWindow->renderer().get())->setup();
	}
	
    self->app = new ofxiOSBridgeApp(self);
    ofRunApp(mWindow, std::move(std::shared_ptr<ofBaseApp>(self->app)));

    ofxiOSAlerts.addListener((ofxiOSBridgeApp*)self->app);
	
	ofDisableTextureEdgeHack();

    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    bInit = YES;
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
        if (self.autoSetup) {
            [self setupOfApp];
        }
	}
}


- (void) removeFromSuperview {
	[animationTimer invalidate];
	animationTimer = nil;
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
	
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    
    window->setWindowPosition(self.frame.origin.x * scaleFactor, self.frame.origin.y * scaleFactor);
    window->setWindowShape(self.bounds.size.width * scaleFactor, self.bounds.size.height * scaleFactor);
	
	NSLog(@"Window size: %f, %f", self.bounds.size.width, self.bounds.size.height);
	UIScreen * currentScreen = self.window.screen;  // current screen is the screen that GLView is attached to.
	if(!currentScreen) {                            // if GLView is not attached, assume to be main device screen.
		currentScreen = [UIScreen mainScreen];
	}
    
    window->screenSize.x = currentScreen.bounds.size.width * scaleFactor;
    window->screenSize.y = currentScreen.bounds.size.height * scaleFactor;
}


//------------------------------------------------------
- (CGPoint)orientateTouchPoint:(CGPoint)touchPoint {
    
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    if(window->doesHWOrientation()) {
        return touchPoint;
    }
    
    ofOrientation orientation = ofGetOrientation();
    CGPoint touchPointOriented = CGPointZero;
    
    switch(orientation) {
        case OF_ORIENTATION_180:
            touchPointOriented.x = ofGetWidth() - touchPoint.x;
            touchPointOriented.y = ofGetHeight() - touchPoint.y;
            break;
            
        case OF_ORIENTATION_90_LEFT:
            touchPointOriented.x = touchPoint.y;
            touchPointOriented.y = ofGetHeight() - touchPoint.x;
            break;
            
        case OF_ORIENTATION_90_RIGHT:
            touchPointOriented.x = ofGetWidth() - touchPoint.y;
            touchPointOriented.y = touchPoint.x;
            break;
            
        case OF_ORIENTATION_DEFAULT:
        default:
            touchPointOriented = touchPoint;
            break;
    }
    return touchPointOriented;
}

//------------------------------------------------------

-(void) resetTouches {
    [activeTouches removeAllObjects];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event{
    
    if(!bInit) {
        // if the glView is destroyed which also includes the OF app,
        // we no longer need to pass on these touch events.
        return;
    }
    
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    
    for(UITouch *touch in touches) {
        int touchIndex = 0;
        while([[activeTouches allValues] containsObject:[NSNumber numberWithInt:touchIndex]]){
            touchIndex++;
        }
        
        [activeTouches setObject:[NSNumber numberWithInt:touchIndex] forKey:[NSValue valueWithPointer:(void *)touch]];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        touchPoint.x *= scaleFactor; // this has to be done because retina still returns points in 320x240 but with high percision
        touchPoint.y *= scaleFactor;
        touchPoint = [self orientateTouchPoint:touchPoint];
        
        if( touchIndex==0 ){
            window->events().notifyMousePressed(touchPoint.x, touchPoint.y, 0);
        }
        
        ofTouchEventArgs touchArgs;
        touchArgs.numTouches = [[event touchesForView:self] count];
        touchArgs.x = touchPoint.x;
        touchArgs.y = touchPoint.y;
        touchArgs.id = touchIndex;
        if([touch tapCount] == 2){
            touchArgs.type = ofTouchEventArgs::doubleTap;
            ofNotifyEvent(window->events().touchDoubleTap,touchArgs);    // send doubletap
        }
        touchArgs.type = ofTouchEventArgs::down;
        ofNotifyEvent(window->events().touchDown,touchArgs);    // but also send tap (upto app programmer to ignore this if doubletap came that frame)
    }
}

//------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event{
    
    if(!bInit) {
        // if the glView is destroyed which also includes the OF app,
        // we no longer need to pass on these touch events.
        return;
    }
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    
    for(UITouch *touch in touches){
        int touchIndex = [[activeTouches objectForKey:[NSValue valueWithPointer:(void*)touch]] intValue];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        touchPoint.x *= scaleFactor; // this has to be done because retina still returns points in 320x240 but with high percision
        touchPoint.y *= scaleFactor;
        touchPoint = [self orientateTouchPoint:touchPoint];
        
        if( touchIndex==0 ){
            window->events().notifyMouseDragged(touchPoint.x, touchPoint.y, 0);
        }
        ofTouchEventArgs touchArgs;
        touchArgs.numTouches = [[event touchesForView:self] count];
        touchArgs.x = touchPoint.x;
        touchArgs.y = touchPoint.y;
        touchArgs.id = touchIndex;
        touchArgs.type = ofTouchEventArgs::move;
        ofNotifyEvent(window->events().touchMoved, touchArgs);
    }
}

//------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event{
    
    if(!bInit) {
        // if the glView is destroyed which also includes the OF app,
        // we no longer need to pass on these touch events.
        return;
    }
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    
    for(UITouch *touch in touches){
        int touchIndex = [[activeTouches objectForKey:[NSValue valueWithPointer:(void*)touch]] intValue];
        
        [activeTouches removeObjectForKey:[NSValue valueWithPointer:(void*)touch]];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        touchPoint.x *= scaleFactor; // this has to be done because retina still returns points in 320x240 but with high percision
        touchPoint.y *= scaleFactor;
        touchPoint = [self orientateTouchPoint:touchPoint];
        
        if( touchIndex==0 ){
            window->events().notifyMouseReleased(touchPoint.x, touchPoint.y, 0);
        }
        
        ofTouchEventArgs touchArgs;
        touchArgs.numTouches = [[event touchesForView:self] count] - [touches count];
        touchArgs.x = touchPoint.x;
        touchArgs.y = touchPoint.y;
        touchArgs.id = touchIndex;
        touchArgs.type = ofTouchEventArgs::up;
        ofNotifyEvent(window->events().touchUp, touchArgs);
    }
}

//------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event{
    
    if(!bInit) {
        // if the glView is destroyed which also includes the OF app,
        // we no longer need to pass on these touch events.
        return;
    }
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    
    for(UITouch *touch in touches){
        int touchIndex = [[activeTouches objectForKey:[NSValue valueWithPointer:(void*)touch]] intValue];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        touchPoint.x *= scaleFactor; // this has to be done because retina still returns points in 320x240 but with high percision
        touchPoint.y *= scaleFactor;
        touchPoint = [self orientateTouchPoint:touchPoint];
        
        ofTouchEventArgs touchArgs;
        touchArgs.numTouches = [[event touchesForView:self] count];
        touchArgs.x = touchPoint.x;
        touchArgs.y = touchPoint.y;
        touchArgs.id = touchIndex;
        touchArgs.type = ofTouchEventArgs::cancel;
        ofNotifyEvent(window->events().touchCancelled, touchArgs);
    }
    
    [self touchesEnded:touches withEvent:event];
}

- (void) dealloc {
    
    ofAppiOSWindowUIView* window = (ofAppiOSWindowUIView*)ofGetMainLoop()->getCurrentWindow().get();
    window->events().notifyExit();
    
    ofxiOSAlerts.removeListener(self->app);
    
    ofGetMainLoop()->exit();
    
    bInit = NO;
}


@end
