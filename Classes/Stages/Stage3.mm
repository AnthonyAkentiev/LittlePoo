#import "Stage3.h"
#import "Stage4.h"
#include "helpers.h"
#include "triggers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "SpriteTags.h"
#import "Game.h"
#include "stage_tags.h"
#import "SimpleAudioEngine.h"

@implementation Stage3

-(int) getStageTag
{
    return STAGE3_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE3_TIME_SECONDS;
}

-(id) init
{
    if(self=[super init])
    {       
        // init stuff
        isGoal1Visible = NO;
        
        // background
		[self initBackgroundSprites:@"" movingBack:@"city_bg_ver1.png" movingForeground:@""];
	    [self loadTileMap:@"stage3.tmx" layerName:@"Ground"];       
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
    MusicTuple music[] = 
    {
        {@"chemodan_strana.mp3",0.1f},
        {@"dengi.mp3",0.1f},
    };
    
    unsigned int index = (rand() % _countof(music));    
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                     loop:YES];
#endif
}

-(BOOL)               isBackgroundDark
{
    return  YES;
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
    return (id<IStage>*)[Stage4 node];
}

-(NSString*) getStageTitle
{
    return NSLocalizedString(@"Briefing3Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing3",@"");
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
    
}
@end
