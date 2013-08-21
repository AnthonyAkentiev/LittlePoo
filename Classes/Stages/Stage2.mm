#import "Stage2.h"
#include "helpers.h"
#include "triggers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "SpriteTags.h"
#import "Stage3.h"
#import "Game.h"
#include "stage_tags.h"
#import "SimpleAudioEngine.h"

@implementation DialogueSobchak
-(void) playDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player 
              object:(ObjectBase*)obj
{
    object = obj;
    //[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.01];
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"dom2.mp3" 
                                                     loop:YES];
    
    [player setDialogueMode:YES]; 
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
        {YES, NSLocalizedString(@"SobchakDialog1", @"")},
        
        {NO, NSLocalizedString(@"SobchakDialog3", @"")},        
        {NO, NSLocalizedString(@"SobchakDialog4", @"")},
        
        {YES,NSLocalizedString(@"SobchakDialog5", @"")},
        {YES,NSLocalizedString(@"SobchakDialog6", @"")},
        
        {NO,NSLocalizedString(@"SobchakDialog7", @"")},
        
        {YES,NSLocalizedString(@"SobchakDialog8", @"")},
        {YES,NSLocalizedString(@"SobchakDialog9", @"")},
        
        {NO,NSLocalizedString(@"SobchakDialog10", @"")},
        
        {YES,NSLocalizedString(@"SobchakDialog11", @"")},
        {YES,NSLocalizedString(@"SobchakDialog11_2", @"")},
        {YES,NSLocalizedString(@"SobchakDialog12", @"")},
        
        {NO,NSLocalizedString(@"SobchakDialog13", @"")},
        
        {YES,NSLocalizedString(@"SobchakDialog14", @"")},
        
        {NO,NSLocalizedString(@"SobchakDialog15", @"")},
        
        {YES,NSLocalizedString(@"SobchakDialog16", @"")},
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



@implementation Stage2

-(int) getStageTag
{
    return STAGE2_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE2_TIME_SECONDS;
}

-(id) init
{
    if(self=[super init])
    {       
        // init stuff
        isGoal1Visible = NO;
        
        // background
		[self initBackgroundSprites:@"" movingBack:@"stage1_bg.png" movingForeground:@""];
        [self loadTileMap:@"stage2.tmx" layerName:@"Ground"];       
        
        snow = [Snow node];
        [self addChild:snow z:10];
        
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
    [snow dealloc];
    [dial1 release];
	[super dealloc];
}

-(id<IStage>*)  getNextStage
{
    return (id<IStage>*)[Stage3 node];
}

-(NSString*) getStageTitle
{
    return NSLocalizedString(@"Briefing2Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing2",@"");
}

-(BOOL)               isBackgroundDark
{
    return  NO;
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
    if([objectName compare:@"Sobchak1"]==NSOrderedSame 
       && isGoal1Visible==NO && isVerticalVisible )
    {
        // play dialogue1
        const CGSize screen = [[CCDirector sharedDirector] winSize];
        
        const CGFloat startDialogueDistance = DIALOGUE_START_WHEN_REACHED * (screen.width);
        if(distance<startDialogueDistance)
        {
            NSLog(@"Object is visible: %@",objectName);
            NSAssert(dial1==nil,@"Error - object already created");
            
            dial1 = [[DialogueSobchak alloc]init];
            [dial1 playDialogue:self 
                         player:(Player*)[self getPlayer]
                         object:object];
            
            isGoal1Visible = YES;
        }
    }

}
@end