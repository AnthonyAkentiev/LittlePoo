#import "Stage6.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "stage_tags.h"
#include "movements.h"
#include "SimpleAudioEngine.h"
#import "Player.h"

@implementation DialogueNavalny
-(void) playDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player 
              object:(ObjectBase*)obj
{
    object = obj;
    //[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.01];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"dubstep.mp3" 
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
        {NO, NSLocalizedString(@"NavalnyDialog2", @"")},
        {YES,NSLocalizedString(@"NavalnyDialog1", @"")},
        {YES,NSLocalizedString(@"NavalnyDialog3", @"")},
        
        {NO, NSLocalizedString(@"NavalnyDialog4", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog4_2", @"")},
        
        {NO, NSLocalizedString(@"NavalnyDialog5", @"")},

        {YES, NSLocalizedString(@"NavalnyDialog6", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog7", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog8", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog8_2", @"")},
        
        {NO, NSLocalizedString(@"NavalnyDialog9", @"")},
        {NO, NSLocalizedString(@"NavalnyDialog10", @"")},
        {NO, NSLocalizedString(@"NavalnyDialog11", @"")},        
        
        {YES,NSLocalizedString(@"NavalnyDialog12", @"")},
        
        {NO, NSLocalizedString(@"NavalnyDialog13", @"")},
        {NO, NSLocalizedString(@"NavalnyDialog13_2", @"")},
        
        {YES, NSLocalizedString(@"NavalnyDialog14", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog14_2", @"")},
        {YES, NSLocalizedString(@"NavalnyDialog15_2", @"")},
        
        // for great justice!
        {NO, NSLocalizedString(@"NavalnyDialog16", @"")},
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



@implementation Stage6

-(int) getStageTag
{
    return STAGE6_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE6_TIME_SECONDS;
}

-(id)init
{
    if(self=[super init])
    {
        // Stuff
        isGoal1Visible = NO;
        
        // background        
		[self initBackgroundSprites:@"" movingBack:@"dungeon_bg_ver2.png" movingForeground:@""];
	    [self loadTileMap:@"stage6.tmx" layerName:@"Ground"];   
    }
    return self;
}

-(void) dealloc
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [dial1 release];
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
        {@"mandaty2.mp3",0.1f},
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

-(id<IStage>*)  getNextStage
{
    return nil;
}

-(NSString*)    getStageTitle
{
    return NSLocalizedString(@"Briefing6Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing6",@"");
}

-(void) goalIsVisible:(NSString*)objectName
             distance:(CGFloat)distance
               object:(id)object
     isVerticalVisible:(BOOL)isVerticalVisible
{
    if([objectName compare:@"Navalny1"]==NSOrderedSame 
       && isGoal1Visible==NO && isVerticalVisible)
    {
        // play dialogue1
        const CGSize screen = [[CCDirector sharedDirector] winSize];
        
        const CGFloat startDialogueDistance = DIALOGUE_START_WHEN_REACHED * (screen.width);
        if(distance<startDialogueDistance)
        {
            NSLog(@"Object is visible: %@",objectName);
            NSAssert(dial1==nil,@"Error - object already created");
            
            dial1 = [[DialogueNavalny alloc]init];
            [dial1 playDialogue:self 
                         player:(Player*)[self getPlayer]
                         object:object];
            
            isGoal1Visible = YES;
        }
    }
}

-(id)        getCurrentDialogue
{
    return dial1;
}

@end
