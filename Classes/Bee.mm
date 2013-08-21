#import "Bee.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#include "StageBase.h"

@implementation Bee

#define BEE_MAX_SPRITE_IDLE_ANIM 0
#define BEE_MAX_SPRITE_WALK_ANIM 5

// TODO
#define BEE_SPRITE_WALK_FORMAT   @"fly%d.png"
#define BEE_SPRITE_IDLE_FORMAT   @""
#define BEE_PLIST                @"bee.plist"
#define BEE_INITIAL_SPRITE       @"fly1.png"     
#define BEE_INITIAL_FLIP         YES

#define BEE_JUMP_PIXELS_PER_SECOND  ((BLOCK_SIZE_Y / SINGLE_BLOCK_JUMP_TIMING)/8)
#define BEE_MOVE_PIXELS_PER_SECOND  ((BLOCK_SIZE / SINGLE_BLOCK_MOVE_TIMING)/8)


-(CCSpriteEx*) initSprite
{    
    // Init player sprite
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:BEE_PLIST];  
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:BEE_INITIAL_SPRITE];
    rightFlip = BEE_INITIAL_FLIP;   // this sprite is drawn looking to the left, so by default flip it!
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
    staticParamsIn.spriteSize.width       = RESIZE_X(64);
    staticParamsIn.spriteSize.height      = 0;      // auto
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams objectParams;
    
    const BOOL bOrientation = [[props valueForKey:@"orientationLeft"] boolValue];
    const BOOL autoTurn     = [[props valueForKey:@"autoTurn"] boolValue];
    
    objectParams.maxSpriteIdle          = BEE_MAX_SPRITE_IDLE_ANIM;
    objectParams.stringFormatIdle       = BEE_SPRITE_IDLE_FORMAT;
    objectParams.maxSpriteWalk          = BEE_MAX_SPRITE_WALK_ANIM;
    objectParams.stringFormatWalk       = BEE_SPRITE_WALK_FORMAT;
    
    objectParams.jumpPixelsPerSecond    = BEE_JUMP_PIXELS_PER_SECOND;
    objectParams.movePixelsPerSecond    = BEE_MOVE_PIXELS_PER_SECOND;
    objectParams.walkAnimNextFrameTime  = WALK_ANIMATION_NEXT_FRAME_TIME;
    objectParams.idleAnimNextFrameTime  = IDLE_ANIMATION_NEXT_FRAME_TIME;
    objectParams.stringFormatJump             = @"";
    
    objectParams.lookingLeft            = bOrientation;
    objectParams.movingRight            = !bOrientation;    
    objectParams.patrolAction           = [[props valueForKey:@"patrol"]intValue];
    objectParams.flyAction              = [[props valueForKey:@"fly"]intValue];
    
    objectParams.stringFormatTalk       = @"";
    objectParams.maxSpriteTalk          = 0;
    objectParams.repeatTalkTimes        = 0;
    objectParams.talkAnimNextFrameTime  = 0;
    
    NSAssert(!objectParams.patrolAction,@"Bees can't patrol, use fly property!");
    
    objectParams.autoTurn               = autoTurn;    

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
