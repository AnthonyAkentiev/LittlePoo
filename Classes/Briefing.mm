// Import the interfaces
#import "Briefing.h"
#import "CCTouchDispatcher.h"
#import "Game.h"
#include "helpers.h"
#include "fonts.h"
#include "timings.h"

// Intro implementation
@implementation Briefing

#define BRIEFING_TITLE_TEXT_COLOR ccc3(0,0,0)
#define BRIEFING_TEXT_COLOR ccc3(255,255,255)

-(void)moveNextScene
{
    Game* game = [[[Game alloc] initWithStage:startThisStageAfterBriefing]autorelease];
    CCScene* nextScene = (CCScene*)game;
	
	[[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
										scene:nextScene]];
    
    [startThisStageAfterBriefing startStage];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touched Briefing screen!");	
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
-(id) initWithStage:(StageBase<IStage>*)stage
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) 
	{		
        startThisStageAfterBriefing = [stage retain];
        
        self.isTouchEnabled = YES;
        
        CGSize screen = [[CCDirector sharedDirector] winSize];
        
        
        CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"frame1.jpg"];
        bg.position = ccp(screen.width/2, screen.height/2);
        [bg setWidth:screen.width];
        [bg setHeight:screen.height];
        [self addChild:bg z:-5];
        
        // 0 - Title 
        NSString* strTitle = [startThisStageAfterBriefing getStageTitle];
        
        /*
#ifdef _DEBUG
        UIScreen* mainScreen = [UIScreen mainScreen];
        CGFloat scale = [mainScreen scale];
        strTitle = [NSString stringWithFormat:@"w=%f; h=%f; scale=%f",screen.width,
                                                  screen.height,
                                                  scale
                                        ];
#endif
        */
        
        // Marker Felt
        // @"Thonburi" 
        // "Chalkduster"
        // Heiti SC- wide
        // Zapfino - itallic   
        
        CCLabelTTF* labelTitle = [self createLabel:strTitle
                                     textSize:RESIZE_FONT(BRIEFING_TITLE_TEXT_SIZE)
                                  fontName:@"Zapfino"];
        [labelTitle setColor:BRIEFING_TITLE_TEXT_COLOR];
        
        NSLog(@"%f - %f",labelTitle.contentSize.width, labelTitle.contentSize.height );
        
        labelTitle.position =  ccp(screen.width /2 , 
                                   screen.height - labelTitle.contentSize.height/2 - RESIZE_Y(5) );
        
		[self addChild: labelTitle];
        
  
        
        // 1 - Briefing text
        NSString* strBriefing = [startThisStageAfterBriefing getBriefingText];
        CCLabelTTF* label = [self createLabel:strBriefing
                                     textSize:RESIZE_FONT(BRIEFING_TEXT_SIZE)
                                     fontName:@"Marker Felt"];
        [label setColor:BRIEFING_TEXT_COLOR];
        
		// position the label on the center of the screen
        CGFloat posY = labelTitle.position.y - labelTitle.contentSize.height 
                            - RESIZE_Y(5) - label.contentSize.height/2 ;

		label.position =  ccp( screen.width /2 , posY );
        
		[self addChild: label];
	}
	
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [startThisStageAfterBriefing release];
	[super dealloc];
}
@end
