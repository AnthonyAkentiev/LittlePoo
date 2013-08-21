#include "StageSelect.h"
#import "MainMenu.h"
#import "WinScreen.h"
#import "StageSelect.h"
#import "Stage0.h"
#import "Stage5.h"
#import "SimpleAudioEngine.h"

#import "Briefing.h"
#import "helpers.h"
#import "SpriteEx.h"
#import "Game.h"
#include "fonts.h"
#include "timings.h"
#include "stdlib.h"

@implementation StageSelect

struct StageTuple
{
    NSString* stageName;
    NSString* className;
};

// Provide here item that user can select.
StageTuple stages[] =
{
    {NSLocalizedString(@"Briefing0Name",@""),@"Stage0"},
    {NSLocalizedString(@"Briefing1Name",@""),@"Stage1"},
    {NSLocalizedString(@"Briefing2Name",@""),@"Stage2"},
    {NSLocalizedString(@"Briefing3Name",@""),@"Stage3"},
    {NSLocalizedString(@"Briefing4Name",@""),@"Stage4"},
    {NSLocalizedString(@"Briefing5Name",@""),@"Stage5"},
    {NSLocalizedString(@"Briefing6Name",@""),@"Stage6"},
};

-(void)moveBack
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
	//[self moveBack];
}

-(void) menuCallback:(id) sender
{
    NSLog(@"StageSeelct-menuCallback");
    
    CCMenuItem* item = (CCMenuItem*) sender;
    NSLog(@"Selected item: %d",item.tag);
    NSAssert(item.tag<_countof(stages),@"Bad index");
    
    // select stage    
    Class currentStage  = NSClassFromString(stages[item.tag].className);
        
    Briefing* br = [[[Briefing alloc] initWithStage:[currentStage node]]autorelease];
	CCScene* nextScene = (CCScene*) br;
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
	[[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
										scene:nextScene]];	
}

-(void) addMenu
{
    NSLog(@"StageSeelct-addMenu");
    NSMutableArray* openedStages = [Game getOpenStagesArray];
    
	// add menu1
	[CCMenuItemFont setFontSize:DEFAULT_MENU_BIGFONT];
	[CCMenuItemFont setFontName: @"Marker Felt"];
    
    int dummyList[2] = {0, 0};
    menu = [[CCMenu alloc]initWithItems:nil 
                                 vaList:(va_list)dummyList];
    
    for(size_t i=0; i<_countof(stages); ++i)
    {
        // select stage    
        Class currentStage  = NSClassFromString(stages[i].className);
        StageBase<IStage>* tmp = [currentStage alloc];
        int tag = [tmp getStageTag];
        [tmp release];
        
        // add only if player has unlocked this stage!
        if([Game isPresentStage:openedStages 
                          stageTag:tag])
        { 
            NSString* strFormatted = [NSString stringWithFormat:@"%d. %@",
                                            i + 1,stages[i].stageName];
            
            CCMenuItem* item   = [CCMenuItemFont itemFromString:strFormatted 
                                                         target:self     
                                                       selector:@selector(menuCallback:)];
            
            [item setTag:i];
            [menu addChild:item];
        }
    }    
    
	[menu alignItemsVertically];
	[openedStages release];
    
	const CGSize screen = [[CCDirector sharedDirector] winSize];
	menu.position = ccp(screen.width/2 , screen.height/2 );
	[self addChild: menu];
}

-(void) playRandomMusic
{   
    NSLog(@"StageSeelct-playRandomMusic");
    struct MusicTuple
    {
        NSString* file;
        float volume;
    };
    
#ifdef PLAY_BACKGROUND_MUSIC
    if([Game isSpecialMusicMode])
    {
        MusicTuple music[] = 
        {
            {@"sektor1.mp3",0.1f},
            {@"sektor2.mp3",0.2f},
            {@"sektor3.mp3",0.2f},
            {@"how_to_be.mp3",0.1f},
            {@"leningrad1.mp3",0.1f},
            {@"dengi.mp3",0.1f},
            {@"mandaty2.mp3",0.1f},
            {@"blya.mp3",0.1f},
            {@"chemodan_strana.mp3",0.1f},
        };
        
        unsigned int index = (rand() % _countof(music));    
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                         loop:YES];
    }else
    {
        // no music playin'
    }
#endif
}


-(id) init
{
    if(self = [super init])
    {
        self.isTouchEnabled = YES;
        
        [self addMenu];
        //[self playRandomMusic];
        
        CGSize screen = [[CCDirector sharedDirector] winSize];
        
        NSLog(@"StageSeelct-adding sprite");
        
        CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"frame1.jpg"];
        bg.position = ccp(screen.width/2, screen.height/2);
        [bg setWidth:screen.width];
        [bg setHeight:screen.height];
        [self addChild:bg z:-5];
    }
    
    return self;
}


@end