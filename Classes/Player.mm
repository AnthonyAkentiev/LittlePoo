#include "Player.h"
#include "NPCs.h"
#include "triggers.h"
#include "helpers.h"
#include "SpriteTags.h"
#include "WinScreen.h"
#include "MainMenu.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#import "SimpleAudioEngine.h"

@implementation Player

#define PLAYER_MAX_SPRITE_IDLE_ANIM 6
#define PLAYER_MAX_SPRITE_WALK_ANIM 7

#define PLAYER_MAX_JUMP_JETPACK 4

#define PLAYER_SPRITE_WALK_FORMAT   @"run_0%d.png"
#define PLAYER_SPRITE_IDLE_FORMAT   @"standby_0%d.png"
#define PLAYER_JUMP                 @"jump01.png"
#define PLAYER_JUMP_JETPACK         @"jetpack%d.png"
#define PLAYER_PLIST                @"Player.plist"
#define PLAYER_INITIAL_SPRITE       @"standby_01.png"     
#define PLAYER_INITIAL_FLIP         NO

#define PLAYER_SPRITE_TALK_FORMAT   @"speak%d.png"
#define PLAYER_MAX_SPRITE_TALK_ANIM 32

#define ACTION_PLAYER_BLINK  1

#define TOUCH_ENEMY_TIME_DELTA (10 * SINGLE_BLOCK_MOVE_TIMING)

#define MAX_VERTICAL_DIFF_IS_GOAL_VISIBLE 5

-(BOOL) isDead
{
    return isDead || (hitPoints<=0);  
}

- (unsigned int) getHitPoints
{
    return hitPoints;
}

- (void) setHitPoints:(unsigned int)hits
{
    hitPoints = hits;
}


- (unsigned int) getTimeElapsed
{
    return timeElapsed;
}

- (void) setTimeElapsed:(unsigned int)time
{
    timeElapsed = time;
}

- (unsigned int) getScore
{
    return score;
}

- (void) setScore:(unsigned int)s
{
    score = s;
}

- (void) setDialogueMode:(BOOL)value
{
    dialogueMode = value;
}

- (BOOL) isDialogueMode
{
    return dialogueMode;
}

-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:PLAYER_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:PLAYER_INITIAL_SPRITE];
    rightFlip = PLAYER_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
    [spriteOut setFlipX:rightFlip];
    return spriteOut;
}

- (void)dealloc
{
    [world removeChild:sprite cleanup:YES];
    [super dealloc];
}

- (id)initWithWorld:(StageBase<IStage>*)w;
{
    CCSpriteEx* spriteIn = [self initSprite];
    
    ObjectParams        staticParamsIn;    
    
    staticParamsIn.spriteSize.width       = RESIZE_X(64);
    staticParamsIn.spriteSize.height      = RESIZE_Y(88);
    //staticParamsIn.spriteSize.height      = 0;
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name                   = [[NSString stringWithString:@"Player"]retain];
    
    MovingObjectParams  objectParams;
    objectParams.maxSpriteIdle          = PLAYER_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = PLAYER_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = PLAYER_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = PLAYER_SPRITE_WALK_FORMAT;
    objectParams.jumpPixelsPerSecond    = JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump             = PLAYER_JUMP;
    
    objectParams.lookingLeft            = NO;
    objectParams.movingRight            = YES;
    
    objectParams.patrolAction           = 0;
    objectParams.flyAction              = 0;
    objectParams.autoTurn               = NO;
    
    objectParams.stringFormatTalk       = PLAYER_SPRITE_TALK_FORMAT;
    objectParams.maxSpriteTalk          = PLAYER_MAX_SPRITE_TALK_ANIM;
    objectParams.talkAnimNextFrameTime  = TALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.maxSpriteJump          = 1;
    objectParams.repeatTalkTimes        = 1;
    
    // Already scaled!
    CGPoint pnt;
    if(![w getObjectPos:@"Spawn" pnt:&pnt])
    {
        //NSAssert(false, @"Can't get spawn point for current stage!");
        pnt.x = 0;
        pnt.y = 4* BLOCK_SIZE_Y;
    }
    
#ifdef SCROLL_TO_SPAWN
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    
    pnt.x = screen.size.width/2;
#endif
    
	if(self=[super initWithWorld:w 
                             pos:pnt 
                    staticParams:staticParamsIn
                          params:objectParams
                        spriteIn:spriteIn
                playerControlled:YES])
	{             
        // initialize stuff        
        timeElapsed             = 0;
        score                   = 0;
        flyingMode              = YES;
        bikerMode               = NO;
        
        lastTouchedEnemyLeft    = 0;
        hitPoints               = INITIAL_HITPOINTS;
    }
	
	return self;
}

-(void) touchedEnemy:(ObjectBase*)enemy
{
    hitPoints--;     
    
#ifdef REMOVE_ENEMY_IF_TOUCHED
    [worl removeEnemy:enemy];
#endif
    
    [self startBlinkAction];
    lastTouchedEnemyLeft = TOUCH_ENEMY_TIME_DELTA;
}

- (BOOL)isStillTouching
{
    return (lastTouchedEnemyLeft>0);
}

-(void) searchVisibleGoalsInternal:(NSMutableArray*)arr
{
    for(ObjectBase* obj in arr)
    {
        Class c = NSClassFromString(@"GoalObject");
        Class c2= NSClassFromString(@"NPC");
        
        if([obj isKindOfClass:c] || [obj isKindOfClass:c2])
        {
            if([obj isVisible])
            {
                CGPoint curr = [obj getCurrentPositionWorld].origin;
                
                const CGFloat distance = curr.x - [self getCurrentPositionWorld].origin.x;
                
                // y 
                BOOL isVerticalVisible = 
                    (abs(curr.y - [self getCurrentPositionWorld].origin.y)< RESIZE_X(MAX_VERTICAL_DIFF_IS_GOAL_VISIBLE));
                
                [world goalIsVisible:[obj getName] 
                            distance:distance
                              object:obj
                    isVerticalVisible:isVerticalVisible];
            }
        }
    }
}

-(void) searchVisibleGoals
{
    [self searchVisibleGoalsInternal:[world getObjects]];
    [self searchVisibleGoalsInternal:[world getEnemies]];
}

-(void) startBlinkAction
{
    // play action!
    if(![sprite getActionByTag:ACTION_PLAYER_BLINK])
    {
        CCBlink* blink = [CCBlink actionWithDuration:TOUCH_ENEMY_TIME_DELTA blinks:6];
        [blink setTag:ACTION_PLAYER_BLINK];
        [sprite runAction:blink];
    }
}

- (void)step:(ccTime)delta
{     
    [self searchVisibleGoals];    
    lastTouchedEnemyLeft-=delta;
    [super step:delta];
}

#ifdef TEST_STAGE_MODE
-(void) goToEnd
{
    [world moveWorld:LRINT(-100000)];    
}
#endif

-(void) setFlyingMode:(BOOL)enabled
{
    flyingMode = YES;
    [self setGravity:!enabled];

    if( enabled )
    {        
        params.maxSpriteJump    = PLAYER_MAX_JUMP_JETPACK;
        params.stringFormatJump = PLAYER_JUMP_JETPACK;
    }else
    {
        params.maxSpriteJump    = 1;
        params.stringFormatJump = PLAYER_JUMP;
    }
    
    [params.spritesJump release];        
    [self unpackString:&(params.spritesJump) 
                format:params.stringFormatJump
              maxIndex:params.maxSpriteJump];
}

-(void) updateSpecialModifiers:(ObjectBase*)object
{
    if([[object getName] compare:@"sat1"]==NSOrderedSame)
    {
        [self setFlyingMode:YES];
    }
}

@end
