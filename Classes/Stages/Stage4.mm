#import "Stage4.h"
#include "helpers.h"
#include "triggers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "SpriteTags.h"
#import "Stage5.h"
#import "Game.h"
#include "stage_tags.h"
#import "SimpleAudioEngine.h"

@implementation Stage4

-(int) getStageTag
{
    return STAGE4_TAG;
}

-(unsigned int) getTimeNeeded
{
    return STAGE4_TIME_SECONDS;
}

-(id) init
{
    if(self=[super init])
    {       
        // init stuff       
        isGoal1Visible = NO;
        isGoal2Visible = NO;
        
        // background
		[self initBackgroundSprites:@"" movingBack:@"city_bg_ver2.png" movingForeground:@""];
        [self loadTileMap:@"stage4.tmx" layerName:@"Ground"];
        
        //snow = [Snow node];
        //[self addChild:snow z:10];
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
        {@"mandaty2.mp3",0.1f},
    };
    
    unsigned int index = (rand() % _countof(music));    
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                     loop:YES];
#endif
}

-(void) startStage
{
    [self playRandomMusic];
}

-(void)dealloc
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    //[snow release];
	[super dealloc];
}

-(id<IStage>*)  getNextStage
{
    return (id<IStage>*)[Stage5 node];
}

-(NSString*) getStageTitle
{
    return NSLocalizedString(@"Briefing4Name",@"");
}

-(NSString *)getBriefingText
{
    return NSLocalizedString(@"Briefing4",@"");
}

-(id)        getCurrentDialogue
{
    return nil;
}

-(BOOL)       isBackgroundDark
{
    return  YES;
}

-(void)      goalIsVisible:(NSString*)objectName
                  distance:(CGFloat)distance
                    object:(id)object
         isVerticalVisible:(BOOL)isVerticalVisible
{   
    if([objectName compare:@"goal1"]==NSOrderedSame 
       && isGoal1Visible==NO && isVerticalVisible )
    {
        CGRect screen;
        screen.origin.x = 0;
        screen.origin.y = 0;
        screen.size = [[CCDirector sharedDirector] winSize];
        
        if(distance<screen.size.width/4)
        {
            // bring satellite to action!
            isGoal1Visible = YES;
            
            ObjectBase* sat = [self getObject:@"sat1"];
            NSAssert(sat!=nil,@"Satellite object doesn't exist");
            
            ObjectBase* objGoal = (ObjectBase*)object;
            CGRect rectGoalWorld = [objGoal getCurrentPositionWorld];
            CGRect rectGoalScreen = rectGoalWorld;
            
            [self toScreenCoords:&rectGoalScreen];
            
            // Fall down :-))
            CCMoveTo* moveTo = [CCMoveTo actionWithDuration:SATELLITE_FALL_TIME 
                                                   position:rectGoalScreen.origin];
            
            
            [sat runAction:moveTo];
        }        
    }
    
    if([objectName compare:@"goal2"]==NSOrderedSame 
             && isGoal2Visible==NO)
    {
        // stop flying mode
        isGoal2Visible = YES;
        
        Player* p = (Player*)[self getPlayer];
        [p setFlyingMode:NO];
    }
}
@end