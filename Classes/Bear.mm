#import "Bear.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#include "StageBase.h"

@implementation Bear

#define BEAR_MAX_SPRITE_IDLE_ANIM 0
#define BEAR_MAX_SPRITE_WALK_ANIM 6

#define BEAR_SPRITE_WALK_FORMAT   @"walk%d.png"
#define BEAR_SPRITE_IDLE_FORMAT   @""
#define BEAR_PLIST                @"bear.plist"
#define BEAR_INITIAL_SPRITE       @"walk1.png"     
#define BEAR_INITIAL_FLIP         YES

#define BEAR_JUMP_PIXELS_PER_SECOND  ((BLOCK_SIZE_Y / SINGLE_BLOCK_JUMP_TIMING)/8)
#define BEAR_MOVE_PIXELS_PER_SECOND  ((BLOCK_SIZE / SINGLE_BLOCK_MOVE_TIMING)/8)

// slower
#define BEAR_WALK_ANIMATION_NEXT_FRAME_TIME (WALK_ANIMATION_NEXT_FRAME_TIME * 2)

-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:BEAR_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:BEAR_INITIAL_SPRITE];
    rightFlip = BEAR_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
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
    staticParamsIn.spriteSize.width       = RESIZE_X(92);
    staticParamsIn.spriteSize.height      = 0;      // auto
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams objectParams;    
    const BOOL bOrientation = [[props valueForKey:@"orientationLeft"] boolValue];
    const BOOL autoTurn     = [[props valueForKey:@"autoTurn"] boolValue];
    
    objectParams.maxSpriteIdle          = BEAR_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = BEAR_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = BEAR_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = BEAR_SPRITE_WALK_FORMAT;
    
    objectParams.jumpPixelsPerSecond    = BEAR_JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = BEAR_MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = BEAR_WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;

    
    objectParams.stringFormatJump             = @"";
    
    objectParams.lookingLeft            = bOrientation;
    objectParams.movingRight            = !bOrientation;
    
    objectParams.patrolAction           = [[props valueForKey:@"patrol"]intValue];
    objectParams.flyAction              = [[props valueForKey:@"fly"]intValue];
    objectParams.autoTurn               = autoTurn;
    
    NSAssert(!objectParams.flyAction,@"Bears can't fly :-), use patrol property!");
        
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
