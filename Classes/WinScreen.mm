// Import the interfaces
#import "WinScreen.h"
#import "MainMenu.h"
#import "helpers.h"
#include "fonts.h"
#import "SimpleAudioEngine.h"
#import "SpriteEx.h"
#include "triggers.h"

@implementation WinScreen

#define STAGE_TRANSITION_DURATION (1.2f)

-(void)moveNextScene
{    
	// move to MainMenu scene!
	// HACK: else NSClassFromString will fail
	[CCTransitionRadialCCW node];
	
	Class transition  = NSClassFromString(NSLocalizedString(@"_TransitionToMainMenu",""));
	
	CCScene* mainMenu = [MainMenu node];
	[[CCDirector sharedDirector] replaceScene: [transition 
									    transitionWithDuration:STAGE_TRANSITION_DURATION 
									    scene:mainMenu]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touched WinScreen screen!");
	
	[self moveNextScene];
}

// called by us
-(void) initialize:(BOOL) failure
      isNoTimeLeft:(BOOL)isNoTimeLeft;
{
#ifdef PLAY_BACKGROUND_MUSIC
    if(failure)
    {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3f];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"chemodan_musor.mp3" 
                                                         loop:YES];
    }else
    {
        
    }
#endif
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"frame1.jpg"];
    bg.position = ccp(screen.width/2, screen.height/2);
    [bg setWidth:screen.width];
    [bg setHeight:screen.height];
    [self addChild:bg z:-5];
    
	// add main Text
	CCLabelTTF* label = [CCLabelTTF labelWithString:NSLocalizedString(failure?@"YouLose":@"YouWin","") 
								    fontName:@"Marker Felt" 
								    fontSize:RESIZE_FONT(YOULOSE_TEXT_SIZE)];
	
	// ask director the the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// position the label on the center of the screen
	label.position =  ccp( size.width /2 , size.height/2 );
	
	// add the label as a child to this Layer
	[self addChild: label];
	
	
	// add description
    if(!failure)
    {
        CCLabelTTF* label2 = [CCLabelTTF labelWithString:NSLocalizedString(@"YouWinDesc","") 
                                        fontName:@"Marker Felt" 
                                        fontSize:RESIZE_FONT(YOULOSE_TEXT_DESC_TEXT_SIZE)];		
        CGSize sizeLabel = CGSizeMake([label2 contentSize].width,[label2 contentSize].height);
        
        // position the label on the center of the screen
        label2.position =  ccp(size.width/2, sizeLabel.height);
        
        // add the label as a child to this Layer
        [self addChild: label2];
    }else if(isNoTimeLeft)
    {       
        CCLabelTTF* label2 = [CCLabelTTF labelWithString:NSLocalizedString(@"NoTimeLeft","")
                                                fontName:@"Marker Felt" 
                                                fontSize:RESIZE_FONT(YOULOSE_TEXT_DESC_TEXT_SIZE)];		
        CGSize sizeLabel = CGSizeMake([label2 contentSize].width,[label2 contentSize].height);
        
        // position the label on the center of the screen
        label2.position =  ccp(size.width/2, sizeLabel.height);
        
        // add the label as a child to this Layer
        [self addChild: label2];
    }
}

// on "init" you need to initialize your instance
-(id) init
{	
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) 
	{		
        self.isTouchEnabled = YES;
	}
	
	return self;
}
@end