#import "Chick.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#include "StageBase.h"

@implementation Chick

#define CHICK_MAX_SPRITE_IDLE_ANIM 0
#define CHICK_MAX_SPRITE_WALK_ANIM 7

#define CHICK_SPRITE_WALK_FORMAT   @"walk%d.png"
#define CHICK_SPRITE_IDLE_FORMAT   @""
#define CHICK_PLIST                @"Punks.plist"
#define CHICK_INITIAL_SPRITE       @"walk1.png"     
#define CHICK_INITIAL_FLIP         YES

#define CHICK_JUMP_PIXELS_PER_SECOND  ((BLOCK_SIZE_Y / SINGLE_BLOCK_JUMP_TIMING)/2)
#define CHICK_MOVE_PIXELS_PER_SECOND  ((BLOCK_SIZE / SINGLE_BLOCK_MOVE_TIMING)/8)


-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:CHICK_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:CHICK_INITIAL_SPRITE];
    rightFlip = CHICK_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
    [spriteOut setFlipX:rightFlip];
    return spriteOut;
}

- (void)dealloc
{  
    [super dealloc];
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    CCSpriteEx* spriteIn = [self initSprite];     
    
    ObjectParams staticParamsIn;
    staticParamsIn.spriteSize.width       = RESIZE_X(50);
    staticParamsIn.spriteSize.height      = 0;      // auto
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams objectParams;
    
    const BOOL bOrientation = [[props valueForKey:@"orientationLeft"] boolValue];
    const BOOL autoTurn     = [[props valueForKey:@"autoTurn"] boolValue];
    
    objectParams.maxSpriteIdle          = CHICK_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = CHICK_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = CHICK_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = CHICK_SPRITE_WALK_FORMAT;
    objectParams.maxSpriteTalk          = 0;
    
    objectParams.jumpPixelsPerSecond    = CHICK_JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = CHICK_MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump             = @"";
    
    objectParams.lookingLeft            = bOrientation;
    objectParams.movingRight            = !bOrientation;    
    objectParams.patrolAction           = [[props valueForKey:@"patrol"]intValue];
    objectParams.flyAction              = [[props valueForKey:@"fly"]intValue];
    
    objectParams.stringFormatTalk       = @"";
    objectParams.maxSpriteTalk          = 0;
    objectParams.repeatTalkTimes       = 0;
    objectParams.talkAnimNextFrameTime  = 0;
    
    objectParams.autoTurn               = autoTurn;    
    
    NSAssert(!objectParams.flyAction,@"Chick can't fly :-), use patrol property!");
    
    if(self=[super initWithWorld:stageBase 
                             pos:pos 
                    staticParams:staticParamsIn
                          params:objectParams
                        spriteIn:spriteIn
                playerControlled:NO])
    {   
        
    }
    
    return self;
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end
