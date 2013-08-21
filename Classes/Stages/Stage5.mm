#import "Stage5.h"
#import "Stage6.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "stage_tags.h"
#include "SimpleAudioEngine.h"

@implementation Stage5

-(int) getStageTag
{
    return STAGE5_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE5_TIME_SECONDS;
}

-(id)init
{
    if(self=[super init])
    {
        // background
        isGoal1Visible = NO;
        
		[self initBackgroundSprites:@"" movingBack:@"dungeon_bg_ver2.png" movingForeground:@""];
	    [self loadTileMap:@"stage5.tmx" layerName:@"Ground"];   
    }
    return self;
}

-(void) dealloc
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [super dealloc];
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
        {@"dengi.mp3",0.1f},
        {@"mandaty2.mp3",0.1f},
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

-(id<IStage>*)  getNextStage
{
    return (id<IStage>*)[Stage6 node];
}

-(NSString*)    getStageTitle
{
    return NSLocalizedString(@"Briefing5Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing5",@"");
}

-(void) goalIsVisible:(NSString*)objectName
             distance:(CGFloat)distance
               object:(id)object
     isVerticalVisible:(BOOL)isVerticalVisible
{

}

-(id)        getCurrentDialogue
{
    return nil;
}

@end
