#import "Stage0.h"
#import "Stage1.h"
#include "helpers.h"
#include "triggers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "SpriteTags.h"
#import "Game.h"
#include "stage_tags.h"
#import "SimpleAudioEngine.h"


@implementation DialogueTimoty
-(void) playDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player 
              object:(ObjectBase*)obj
{
    object = obj;
    [player setDialogueMode:YES]; 
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"timaty.mp3" 
                                                     loop:YES];
}

-(void) stopDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player
{
    [player setDialogueMode:NO];
}

-(BOOL) getString:(unsigned int)index 
           string:(NSString**)string
     saidByPlayer:(BOOL*)saidByPlayer
{    
    // Navalny dialog!
    DialogPhraseTuple phrases[] =
    {
        {YES,   NSLocalizedString(@"TimotyDialog1", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog2", @"")},
        
        {YES,   NSLocalizedString(@"TimotyDialog3", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog4", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog4_2", @"")},
        
        {YES,   NSLocalizedString(@"TimotyDialog5", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog6", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog6_2", @"")},
        
        {YES,   NSLocalizedString(@"TimotyDialog7", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog8", @"")},
        
        {YES,   NSLocalizedString(@"TimotyDialog9", @"")},
        {YES,   NSLocalizedString(@"TimotyDialog9_2", @"")},
        {NO,    NSLocalizedString(@"TimotyDialog10", @"")},
    };
    
    if(index>=_countof(phrases))
        return NO;  // stop dialogue
    
    *string       = phrases[index].str;
    *saidByPlayer = phrases[index].saidByPlayer;
    return YES;     // continue dialogue!
}

-(BOOL) isEndStageAfterDialogue
{
    return YES;
}

-(ObjectBase*)  getObject
{
    return object;
}
@end


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
@implementation Stage0

-(int) getStageTag
{
    return STAGE0_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE0_TIME_SECONDS;
}

-(id) init
{
    if(self=[super init])
    {       
        // init stuff
        isGoal1Visible = NO;
        
        // background
        // london_bg.png
		[self initBackgroundSprites:@"" 
                         movingBack:@"london_bg.png" 
                   movingForeground:@""];
        
        [self loadTileMap:@"stage0.tmx" layerName:@"Ground"];
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
    [dial1 release];
	[super dealloc];
}

-(id<IStage>*)  getNextStage
{
    return (id<IStage>*)[Stage1 node];
}

-(NSString*) getStageTitle
{
    return NSLocalizedString(@"Briefing0Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing0",@"");
}

-(BOOL)               isBackgroundDark
{
    return  YES;
}

-(id)        getCurrentDialogue
{
    return dial1;
}

-(void)      goalIsVisible:(NSString*)objectName
                  distance:(CGFloat)distance
                    object:(id)object
          isVerticalVisible:(BOOL)isVerticalVisible
{   
    if([objectName compare:@"Timoty1"]==NSOrderedSame 
       && isGoal1Visible==NO && isVerticalVisible)
    {
        // play dialogue1
        const CGSize screen = [[CCDirector sharedDirector] winSize];
        
        const CGFloat startDialogueDistance = DIALOGUE_START_WHEN_REACHED * (screen.width);
        if(distance<startDialogueDistance)
        {
            NSLog(@"Object is visible: %@",objectName);
            NSAssert(dial1==nil,@"Error - object already created");
            
            dial1 = [[DialogueTimoty alloc]init];
            [dial1 playDialogue:self 
                         player:(Player*)[self getPlayer]
                         object:object];
            
            isGoal1Visible = YES;
        }
    }
    
}
@end