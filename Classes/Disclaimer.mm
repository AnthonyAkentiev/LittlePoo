// Import the interfaces
#import "Disclaimer.h"
#import "MainMenu.h"
#import "helpers.h"
#include "fonts.h"
#import "SimpleAudioEngine.h"
#import "SpriteEx.h"
#include "triggers.h"

@implementation Disclaimer

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

-(CCLabelTTF*)createLabel:(NSString*)text
                 textSize:(CGFloat)textSize
                 fontName:(NSString*)fontName
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    // get needed size
    CGSize actualSize = [text sizeWithFont:[UIFont fontWithName:fontName
                                                           size:textSize]
                         constrainedToSize:screen
                             lineBreakMode:UILineBreakModeMiddleTruncation];
    // add label
    CCLabelTTF* label = [CCLabelTTF labelWithString:text
                                         dimensions:actualSize
                                          alignment:UITextAlignmentCenter
                                      lineBreakMode:UILineBreakModeMiddleTruncation 
                                           fontName:fontName
                                           fontSize:textSize];
    return label;
}

// on "init" you need to initialize your instance
-(id) init
{	
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) 
	{		
        self.isTouchEnabled = YES;
        
        CGSize screen = [[CCDirector sharedDirector] winSize];
        
        CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"frame3.jpg"];
        bg.position = ccp(screen.width/2, screen.height/2);
        [bg setWidth:screen.width];
        [bg setHeight:screen.height];
        [self addChild:bg z:-5];
        
        
        CCLabelTTF* labelTitle = [self createLabel:NSLocalizedString(@"DisclaimerCaption","")
                                          textSize:RESIZE_FONT(DISCLAIMER_TEXT_SIZE)
                                          fontName:@"Marker Felt"];
        [labelTitle setColor:ccc3(50,50,50)];
        
        NSLog(@"%f - %f",labelTitle.contentSize.width, labelTitle.contentSize.height );
        
        labelTitle.position =  ccp(screen.width /2 , 
                                   screen.height - labelTitle.contentSize.height/2 - RESIZE_Y(90) );
        
		[self addChild: labelTitle];
        
        
        
        // 1 - Briefing text
        CCLabelTTF* label = [self createLabel:NSLocalizedString(@"DisclaimerText","")
                                     textSize:RESIZE_FONT(DISCLAIMER_TEXT_SIZE)
                                     fontName:@"Marker Felt"];
        
		// position the label on the center of the screen
        CGFloat posY = labelTitle.position.y - labelTitle.contentSize.height 
        - RESIZE_Y(5) - label.contentSize.height/2 ;
        
		label.position =  ccp( screen.width /2 , posY );
        
		[self addChild: label];
        
        /*
        // add main Text
        CCLabelTTF* label = [self createLabel:NSLocalizedString(@"DisclaimerText","")
                                     textSize:RESIZE_FONT(DISCLAIMER_TEXT_SIZE)
                                     fontName:@"Marker Felt"];
                                     
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // position the label on the center of the screen
        label.position =  ccp( size.width /2 , size.height/2 );
        
        // add the label as a child to this Layer
        [self addChild: label];
         */
	}
	
	return self;
}
@end