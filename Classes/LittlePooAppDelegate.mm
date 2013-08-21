#include "helpers.h"
#include "triggers.h"
#include "timings.h"

#import "LittlePooAppDelegate.h"
#import "GameConfig.h"
#import "Briefing.h"
#import "MainMenu.h"
#import "WinScreen.h"
#import "Game.h"
#import "Quiz.h"
#import "RootViewController.h"
#import "SimpleAudioEngine.h"

#import "Stage0.h"
#import "Stage1.h"
#import "Stage2.h"
#import "Stage3.h"
#import "Stage4.h"
#import "Stage5.h"
#import "Stage6.h"

float CurrentScaleFactorX = 1.0f;
float CurrentScaleFactorY = 1.0f;
float CurrentScaleFactorXRaw = 1.0f;
float CurrentScaleFactorYRaw = 1.0f;

@implementation LittlePooAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    ::srand((unsigned int)::time(NULL));
    
    //NSString* s1 = @"/var/mobile/poo";
    //FILE *f = freopen([s1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	//if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
	//	[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];
	
	CCDirector *director = [CCDirector sharedDirector];

	[[CCDirector sharedDirector]setDepthTest:false];
    
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
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:/*GL_DEPTH_COMPONENT16_OES*/0
						];
	
    // not working in this version:
    //[director setDepthBufferFormat:kEAGLColorFormatRGB565];
    
    [glView setMultipleTouchEnabled:YES];
    
	// attach the openglView to the director
	[director setOpenGLView:glView];
    
    if(![director enableRetinaDisplay:YES])
        CCLOG(@"Retina Display Not supported");
    
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeRight];
	[director setAnimationInterval:1.0/MAXIMUM_FPS_RATE];
    
#ifdef SHOW_FPS_VAL
	[director setDisplayFPS:YES];
#endif
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	
	// game was written for iPhone 4 - 960x640 pixels.
    // HOWEVER - all coordinates are in 480x320!!!
    // Cocos is written so that Retina display will just got scale==2!
    // So no need to provide 960/640 coordinate points.
    // It will auto-scale high-res objects... 
    // ONCE MORE: Provide all RAW coordinates in 480x320 coord.space!
    // 
    // NOTE2: Cocos2d auto. loads images with 2x postfix as High-Res images with scale==2.
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGRect bounds = [mainScreen bounds];
    CGRect pixels = bounds;

    // note that device is Album-oriented...
	CurrentScaleFactorXRaw = CurrentScaleFactorX = pixels.size.height/480.0f;
	CurrentScaleFactorYRaw = CurrentScaleFactorY = pixels.size.width/320.0f;
    
    // if we run on iPad -> we can scale down a bit!
    if( bounds.size.width>=1024 || bounds.size.height>=1024 )
    {
        CurrentScaleFactorX*=GLOBAL_GAME_OBJECTS_SCALE_IPAD;
        CurrentScaleFactorY*=GLOBAL_GAME_OBJECTS_SCALE_IPAD;
    }else
    {
        CurrentScaleFactorX*=GLOBAL_GAME_OBJECTS_SCALE;
        CurrentScaleFactorY*=GLOBAL_GAME_OBJECTS_SCALE;
    }
    
    [director setProjection:CCDirectorProjection2D];
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.7f]; 
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"all_sprites.plist"]; 
    
#ifdef _DEBUG
    //Stage6* currentStage = [Stage6 node];
    //Game* g = [[[Game alloc] initWithStage:currentStage]autorelease];   
    //[[CCDirector sharedDirector] runWithScene: (CCScene*)g];

    //Quiz* quiz = [[Quiz alloc]init];
    //[[CCDirector sharedDirector] runWithScene: (CCScene*)quiz];
    
    [[CCDirector sharedDirector] runWithScene: [MainMenu node]];
#else
	[[CCDirector sharedDirector] runWithScene: [MainMenu node]];
#endif	
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc 
{
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
