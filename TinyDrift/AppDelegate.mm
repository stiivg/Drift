//
//  AppDelegate.m
//  TinyDrift
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameManager.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window;

// if this is the first time ever running
// this app we need some default defaults
+ (void)initialize{
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjects:[NSArray arrayWithObjects:
                                                        [NSNumber numberWithFloat:0.1],
                                                        [NSNumber numberWithFloat:0.5],
                                                        [NSNumber numberWithBool:YES],
                                                        nil]
                                 forKeys:[NSArray arrayWithObjects:
                                          @"MusicLevel", // starts at score of 0.2
                                          @"SoundLevel", // starts at level 0.8
                                          @"Tutorial",   // starts with tutorial on
                                          nil]];
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:appDefaults];
} 


- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    
    // we are starting up
    // get the settings
    // that we saved when we last quit
    // or if its the first time ever running this game
    // it will load the default defaults
    float musicLevel = [[NSUserDefaults standardUserDefaults] floatForKey:@"MusicLevel"];
    [[GameManager sharedGameManager] setBackgroundVolume:musicLevel];    
    
    float soundLevel = [[NSUserDefaults standardUserDefaults] floatForKey:@"SoundLevel"];
    [[GameManager sharedGameManager] setEffectsVolume:soundLevel];    

    BOOL tutorial = [[NSUserDefaults standardUserDefaults] boolForKey:@"Tutorial"];
    [[GameManager sharedGameManager] setIsTutorialOn:tutorial];    
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];//sjg
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    [[GameManager sharedGameManager] setupAudioEngine];
	
	// Run the intro Scene
    [[GameManager sharedGameManager] runSceneWithID:kMainScene];
}

-(void)saveSettings {
    // save current settings to the defaults
    float musicLevel = [[GameManager sharedGameManager] backgroundVolume];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:musicLevel] forKey:@"MusicLevel"];
    
    float soundLevel = [[GameManager sharedGameManager] effectsVolume];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:soundLevel] forKey:@"SoundLevel"];
    
    BOOL tutorial = [[GameManager sharedGameManager] isTutorialOn];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:tutorial] forKey:@"Tutorial"];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [self saveSettings];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    [self saveSettings];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveSettings];

	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
    
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
