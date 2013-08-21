#include "NPCs.h"
#include "triggers.h"
#include "helpers.h"
#include "SpriteTags.h"
#include "WinScreen.h"
#include "MainMenu.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"

@implementation NPC

- (void)dealloc
{
    [super dealloc];
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end

@implementation Navalny

#define NAVALNY_MAX_SPRITE_IDLE_ANIM 5
#define NAVALNY_MAX_SPRITE_WALK_ANIM 0
#define NAVALNY_SPRITE_WALK_FORMAT   @""
#define NAVALNY_SPRITE_IDLE_FORMAT   @"nav_standby0%d.png"
#define NAVALNY_JUMP                 @""
#define NAVALNY_PLIST                @"Navalny.plist"
#define NAVALNY_INITIAL_SPRITE       @"nav_standby01.png"     
#define NAVALNY_INITIAL_FLIP         YES

#define NAVALNY_SPRITE_TALK_FORMAT   @"nav_speak%d.png"
#define NAVALNY_MAX_SPRITE_TALK_ANIM 20

-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:NAVALNY_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:NAVALNY_INITIAL_SPRITE];
    rightFlip = NAVALNY_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
    [spriteOut setFlipX:rightFlip];
    return spriteOut;
}

- (void)dealloc
{
    [world removeChild:sprite cleanup:YES];
    [super dealloc];
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    CCSpriteEx* spriteIn = [self initSprite];
    
    ObjectParams        staticParamsIn;    
    
    staticParamsIn.spriteSize.width       = RESIZE_X(75);
    staticParamsIn.spriteSize.height      = 0;
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name                   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams  objectParams;
    objectParams.maxSpriteIdle          = NAVALNY_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = NAVALNY_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = NAVALNY_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = NAVALNY_SPRITE_WALK_FORMAT;
    objectParams.jumpPixelsPerSecond    = JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump             = NAVALNY_JUMP;
    
    objectParams.stringFormatTalk       = NAVALNY_SPRITE_TALK_FORMAT;
    objectParams.maxSpriteTalk          = NAVALNY_MAX_SPRITE_TALK_ANIM;
    objectParams.talkAnimNextFrameTime  = TALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.repeatTalkTimes        = 2;
    
    objectParams.lookingLeft            = YES;
    objectParams.movingRight            = NO;    
    objectParams.patrolAction           = 0;
    objectParams.flyAction              = 0;
    objectParams.autoTurn               = NO;
       
	if(self=[super initWithWorld:stageBase 
                             pos:pos 
                    staticParams:staticParamsIn
                          params:objectParams
                        spriteIn:spriteIn
                playerControlled:NO])
	{             
        // initialize stuff        

    }
	
	return self;
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end

////
@implementation Sobchak

#define SOBCHAK_MAX_SPRITE_IDLE_ANIM 1
#define SOBCHAK_MAX_SPRITE_WALK_ANIM 0
#define SOBCHAK_SPRITE_WALK_FORMAT   @""
#define SOBCHAK_SPRITE_IDLE_FORMAT   @"sobchak_standby.png"
#define SOBCHAK_JUMP                 @""
#define SOBCHAK_PLIST                @"Sobchak.plist"
#define SOBCHAK_INITIAL_SPRITE       @"sobchak_standby.png"     
#define SOBCHAK_INITIAL_FLIP         YES

#define SOBCHAK_SPRITE_TALK_FORMAT   @"sobchak_speak%d.png"
#define SOBCHAK_MAX_SPRITE_TALK_ANIM 12

-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:SOBCHAK_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:SOBCHAK_INITIAL_SPRITE];
    rightFlip = SOBCHAK_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
    [spriteOut setFlipX:rightFlip];
    return spriteOut;
}

- (void)dealloc
{
    [world removeChild:sprite cleanup:YES];
    [super dealloc];
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    CCSpriteEx* spriteIn = [self initSprite];
    
    ObjectParams        staticParamsIn;    
    
    staticParamsIn.spriteSize.width       = RESIZE_X(64);
    staticParamsIn.spriteSize.height      = 0;
    //staticParamsIn.spriteSize.height      = RESIZE_Y(95);
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name                   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams  objectParams;
    objectParams.maxSpriteIdle          = SOBCHAK_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = SOBCHAK_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = SOBCHAK_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = SOBCHAK_SPRITE_WALK_FORMAT;
    objectParams.jumpPixelsPerSecond    = JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump             = SOBCHAK_JUMP;
    
    objectParams.stringFormatTalk       = SOBCHAK_SPRITE_TALK_FORMAT;
    objectParams.maxSpriteTalk          = SOBCHAK_MAX_SPRITE_TALK_ANIM;
    objectParams.talkAnimNextFrameTime  = TALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.repeatTalkTimes        = 2;
    
    objectParams.lookingLeft            = YES;
    objectParams.movingRight            = NO;    
    objectParams.patrolAction           = 0;
    objectParams.flyAction              = 0;
    objectParams.autoTurn               = NO;
    
	if(self=[super initWithWorld:stageBase 
                             pos:pos 
                    staticParams:staticParamsIn
                          params:objectParams
                        spriteIn:spriteIn
                playerControlled:NO])
	{             
        // initialize stuff        
        
    }
	
	return self;
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end


//// TODO
@implementation Timoty

#define TIMOTY_MAX_SPRITE_IDLE_ANIM 1
#define TIMOTY_MAX_SPRITE_WALK_ANIM 0
#define TIMOTY_SPRITE_WALK_FORMAT   @""
#define TIMOTY_SPRITE_IDLE_FORMAT   @"timati_standby.png"
#define TIMOTY_JUMP                 @""
#define TIMOTY_PLIST                @"timoty.plist"
#define TIMOTY_INITIAL_SPRITE       @"timati_standby.png"     
#define TIMOTY_INITIAL_FLIP         YES

#define TIMOTY_SPRITE_TALK_FORMAT   @"timati_speak%d.png"
#define TIMOTY_MAX_SPRITE_TALK_ANIM 23

-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:TIMOTY_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:TIMOTY_INITIAL_SPRITE];
    rightFlip = TIMOTY_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
    [spriteOut setFlipX:rightFlip];
    return spriteOut;
}

- (void)dealloc
{
    [world removeChild:sprite cleanup:YES];
    [super dealloc];
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    CCSpriteEx* spriteIn = [self initSprite];
    
    ObjectParams        staticParamsIn;    
    
    staticParamsIn.spriteSize.width       = RESIZE_X(96);
    staticParamsIn.spriteSize.height      = 0;
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name                   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams  objectParams;
    objectParams.maxSpriteIdle          = TIMOTY_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = TIMOTY_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = TIMOTY_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = TIMOTY_SPRITE_WALK_FORMAT;
    objectParams.jumpPixelsPerSecond    = JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump       = TIMOTY_JUMP;
    
    objectParams.stringFormatTalk       = TIMOTY_SPRITE_TALK_FORMAT;
    objectParams.maxSpriteTalk          = TIMOTY_MAX_SPRITE_TALK_ANIM;
    objectParams.talkAnimNextFrameTime  = TALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.repeatTalkTimes        = 2;
    
    objectParams.lookingLeft            = YES;
    objectParams.movingRight            = NO;    
    objectParams.patrolAction           = 0;
    objectParams.flyAction              = 0;
    objectParams.autoTurn               = NO;
    
	if(self=[super initWithWorld:stageBase 
                             pos:pos 
                    staticParams:staticParamsIn
                          params:objectParams
                        spriteIn:spriteIn
                playerControlled:NO])
	{             
        // initialize stuff        
        
    }
	
	return self;
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end


