#import "Stage1.h"
#include "helpers.h"
#include "triggers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "SpriteTags.h"
#import "Stage2.h"
#import "Game.h"
#include "stage_tags.h"
#import "SimpleAudioEngine.h"

@implementation Stage1

-(int) getStageTag
{
    return STAGE1_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE1_TIME_SECONDS;
}

-(id) init
{
    if(self=[super init])
    {       
        // init stuff
        isGoal1Visible = NO;
        
        // background
		[self initBackgroundSprites:@"" movingBack:@"stage1_bg.png" movingForeground:@""];
        [self loadTileMap:@"stage1.tmx" layerName:@"Ground"];
        
		// Will get Cloud%d objects from tilemap 
		[self addClouds:7];   // first param is z-order! not a cloud count! 
    }
    return self;
}

-(void) playRandomMusic
{   
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
            //{@"sektor1.mp3",0.1f},
            //{@"sektor2.mp3",0.2f},
            //{@"sektor3.mp3",0.2f},
            {@"we_dont.mp3",0.4f},
            {@"happy_new_gad.mp3",0.3f},
            {@"uncle_vova.mp3",0.2f}
        };
        
        unsigned int index = (rand() % _countof(music));    
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                         loop:YES];
    }else
    {
        MusicTuple music[] = 
        {
            {@"chemodan_strana.mp3",0.1f}
        };
        
        unsigned int index = (rand() % _countof(music));    
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                         loop:YES];
    }
#endif
}

-(void) startStage
{
    [self playRandomMusic];
}

-(void)dealloc
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[super dealloc];
}

-(id<IStage>*)  getNextStage
{
    return (id<IStage>*)[Stage2 node];
}

-(NSString*) getStageTitle
{
    return NSLocalizedString(@"Briefing1Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing1",@"");
}

-(BOOL)               isBackgroundDark
{
    return  NO;
}

-(id)        getCurrentDialogue
{
    return nil;
}

-(void)      goalIsVisible:(NSString*)objectName
                  distance:(CGFloat)distance
                    object:(id)object
          isVerticalVisible:(BOOL)isVerticalVisible
{   
    if([objectName compare:@"goal1"]==NSOrderedSame 
       && isGoal1Visible==NO && isVerticalVisible)
    {
        //snow = [Snow node];
        //[self addChild:snow z:10];
        isGoal1Visible = YES;
    }
}
@end