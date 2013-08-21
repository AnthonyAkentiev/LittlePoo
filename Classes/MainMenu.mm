#import "MainMenu.h"
#import "WinScreen.h"
#import "StageSelect.h"
#import "SimpleAudioEngine.h"

#import "Briefing.h"
#import "Disclaimer.h"

#import "helpers.h"
#import "SpriteEx.h"
#import "Game.h"
#import "Quiz.h"

#include "fonts.h"
#include "timings.h"
#include "triggers.h"
#include "stdlib.h"

#define MAXIMUM_RUNNING_LABEL_INDEX 5

@implementation MainMenu

-(void) switchSpecialMusicMode
{
    specialMusicMode        = YES;
    specialMusicModeUpdated = YES;  // cache is up to date
    [Game enableSpecialMusicMode];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touched screen!");
    touchBegin = ::time(NULL);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touch ended!");
    
    touchCounter++;
    if( touchCounter==10 )
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AllStagesUnlocked",@"") 
                                                        message:NSLocalizedString(@"AllStagesUnlockedMessage", @"")
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"AllStagesUnlockedOK",@"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [Game enableAllStages];
    }
}

// Continue from last opened stage
-(void) menuCallbackContinue: (id) sender
{
	[[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
										scene:[Quiz node]]];
    
	NSLog(@"Start");
}

// Select stage manually
-(void) menuCallbackStartNew: (id) sender
{
    NSLog(@"Continue");
    
    CCScene* q = (CCScene*) [[[Quiz alloc] initIfStageSelect] autorelease];
    
    [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
										scene:q]];

}

-(void) menuCallbackDisclaimer: (id) sender
{
	//[(MultiplexLayer*)parent switchTo:1];
	NSLog(@"Disclaimer");
    
    [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
										scene:[Disclaimer node]]];
}

-(void) menuCallbackQuit:(id) sender
{
	NSLog(@"Quit");
    CC_DIRECTOR_END();
    exit(0);
}


-(void) addMainMenu
{
	//id layer = [CCColorLayer layerWithColor: 0x2266FFff];	//RGBA
	//[self addChild: layer];
	// add menu1
	[CCMenuItemFont setFontSize:DEFAULT_MENU_BIGFONT];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	
    BOOL firstRun = [Game isFirstRun];
    //firstRun = FALSE;
    if(!firstRun)
    {
        CCMenuItem* item0		= [CCMenuItemFont itemFromString: NSLocalizedString(@"CONTINUE","") target:self selector:@selector(menuCallbackContinue:)];
        CCMenuItem* item1		= [CCMenuItemFont itemFromString: NSLocalizedString(@"START","") target:self selector:@selector(menuCallbackStartNew:)];
        //CCMenuItem* item2		= [CCMenuItemFont itemFromString: NSLocalizedString(@"DISCLAIMER","") target:self selector:@selector(menuCallbackDisclaimer:)];

        menu = [CCMenu menuWithItems: item0, item1, nil];
    }else 
    {
        // NOTE -> This is CONTINUE!!!
        CCMenuItem* item1		= [CCMenuItemFont itemFromString: NSLocalizedString(@"START","") target:self selector:@selector(menuCallbackContinue:)];  
        
        //CCMenuItem* item2		= [CCMenuItemFont itemFromString: NSLocalizedString(@"DISCLAIMER","") target:self selector:@selector(menuCallbackDisclaimer:)];
        
        menu = [CCMenu menuWithItems: item1, nil];
        // if only one item -> color it RED
        //[menu setColor:ccc3(255,0,0)];
    }
	[menu alignItemsVertically];
	
	// position to the right of the screen
	CGSize screen = [[CCDirector sharedDirector] winSize];
	menu.position = ccp(screen.width/2 + [menu contentSize].width/3, 
					screen.height/2 + [menu contentSize].height/4);
	[self addChild: menu];
	
	// add menu 2
    /*
    // QUIT is not allowed by Apple :-)
     
	[CCMenuItemFont setFontSize:DEFAULT_MENU_BIGFONT2];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	
	CCMenuItemFont* item3	= [CCMenuItemFont itemFromString: NSLocalizedString(@"QUIT","") target:self selector:@selector(menuCallbackQuit:)];
	menu2 = [CCMenu menuWithItems: item3, nil];
	[menu2 alignItemsVertically];
	[menu2 setColor:ccc3(255,0,0)];
	
	menu2.position = ccp(screen.width/2 + [menu2 contentSize].width/3, 
					menu.position.y - [menu contentSize].height/2 - RESIZE_Y(40));
	
	[self addChild:menu2];
    */
    
    // Disclaimer
    [CCMenuItemFont setFontSize:DEFAULT_MENU_BIGFONT2];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	
    CCMenuItem* item3		= [CCMenuItemFont itemFromString: NSLocalizedString(@"DISCLAIMER","") target:self selector:@selector(menuCallbackDisclaimer:)];
    
    menu2 = [CCMenu menuWithItems: item3, nil];
	[menu2 alignItemsVertically];
	[menu2 setColor:ccc3(255,255,255)];
	
	menu2.position = ccp(screen.width/2 + [menu2 contentSize].width/3, 
                         menu.position.y - [menu contentSize].height/2 - RESIZE_Y(40));
	
	[self addChild:menu2];

}

-(void) reloadLabel
{
    [self showLabel];
}

-(void) initLabels
{
    for(int i=0; i<=MAXIMUM_RUNNING_LABEL_INDEX; ++i)
        [labelsNotShown addObject:[NSNumber numberWithInteger:i]];
}

-(NSInteger) isNumberPresent:(unsigned int)labelIndex
{
    NSInteger i=0;
    for(id obj in labelsNotShown)
    {
        // cehck if present in array
        NSNumber* num = (NSNumber*)obj;
        
        if([num unsignedIntValue]==labelIndex)
            return i; // we found it
        
        ++i;
    }
    return -1;  //not found
}

-(unsigned int) getNextLabelIndex
{ 
   if(![labelsNotShown count])
   {
       // start again
       [self initLabels];
   }
    
   while(true)
   {
       unsigned int newIndex = (rand() % (MAXIMUM_RUNNING_LABEL_INDEX + 1));
       
       // search it in labels not show
       const NSInteger found = [self isNumberPresent:newIndex];
       if( found!=-1 )    
       {
           [labelsNotShown removeObjectAtIndex:found];
           return newIndex;
       }
   }
    
   NSAssert(true!=false,@"Bad");
   return 0;  
}

-(NSString*) getNextResourceString
{
    // check if multi-label is available?
    if(currentRunningStringIndex!=-1)
    {
        NSString* strIndexMulti = [NSString stringWithFormat:@"Intro%d_%d",
                                    currentRunningStringIndex,multiStringIndex + 1];
     
        // check if this resource exists
        NSString* strTry = NSLocalizedString(strIndexMulti, @"");
        if(([strTry compare:strIndexMulti]!=NSOrderedSame))
        {
            ++multiStringIndex;
            return strIndexMulti;
        }
    }
    
    multiStringIndex = 0;   // return to first multistring item!
    
    currentRunningStringIndex = [self getNextLabelIndex];
    NSString* strIndex = [NSString stringWithFormat:@"Intro%d",currentRunningStringIndex];
    
    return strIndex;
}

-(void) showLabel
{      
    // create and initialize a running Label
    NSString* strIndex = [self getNextResourceString];
    NSString* str      = NSLocalizedString(strIndex, @"");
    
    CCLabelTTF* label = [CCLabelTTF labelWithString:str
    //                         dimensions:actualSize
    //                        alignment:UITextAlignmentCenter
    //                      lineBreakMode:UILineBreakModeCharacterWrap 
                                fontName:@"Thonburi"        // Helvetica Neue
                                fontSize:RUNNING_LABLE_MAINMENU_TEXT_SIZE];
    
    const ccTime duration = ([str length] * SINGLE_CHAR_RUNNING_TIME);
    
    CGSize sizeLabel = CGSizeMake([label contentSize].width,[label contentSize].height);
    
    // position the label on the center of the screen
    const CGSize screen = [[CCDirector sharedDirector] winSize];
    label.position =  ccpLeft(label,screen.width, sizeLabel.height/2);
    
    [label setColor:ccc3(0,0,0)];
    
    // add the label as a child to this Layer
    [self addChild: label];
    
    // start moving
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:duration 
                                           position:ccp(-[label contentSize].width/2 + screen.width - RESIZE_X_RAW(50),
                                                        label.position.y)];
    
    CCCallFunc* reloadLabelAction = [CCCallFunc actionWithTarget:self 
                                                        selector:@selector(reloadLabel)];

    CCFadeTo* escapeToVoid = [CCFadeTo actionWithDuration:0.5];
    
    [label runAction: 
     [CCSequence actions:moveTo,reloadLabelAction,escapeToVoid,nil]
    ];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) 
	{		      
        self.isTouchEnabled = YES;
        
        touchCounter            = 0;
        specialMusicMode        = NO;
        specialMusicModeUpdated = NO;   // read from file (through Game static method)
        
        // Background
        CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"pu_splash_sketch.jpg"];
        CGSize screen = [[CCDirector sharedDirector] winSize];
        bg.position = ccp(screen.width/2, screen.height/2);
        [bg setWidth:screen.width];
        [bg setHeight:screen.height];
        [self addChild:bg z:-5];
                
        // initialize
        labelsNotShown = [[NSMutableArray alloc]init];
        [self initLabels];
        
        //label = nil;
        currentRunningStringIndex = -1;
        multiStringIndex = 0;
		[self showLabel];
        
		// add menu
		[self addMainMenu];
#ifdef PLAY_BACKGROUND_MUSIC
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"main_menu.mp3" 
                                                         loop:YES];
#endif
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
    [labelsNotShown release];
	[super dealloc];
}

@end
