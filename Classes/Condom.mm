#import "Condom.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#include "StageBase.h"

@implementation Condom

-(CCSpriteEx*) initSprite
{    
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:@"condom.png"];
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
    staticParamsIn.spriteSize.width       = RESIZE_X(32);
    staticParamsIn.spriteSize.height      = 0;      // auto
    
    staticParamsIn.scoreModifier          = 0;
    staticParamsIn.timeModifier           = 0;
    staticParamsIn.hitPointModifier       = 0;
    staticParamsIn.name   = [[NSString stringWithString:name]retain];
    
    MovingObjectParams objectParams;    
    
    objectParams.maxSpriteIdle          = 0;
    objectParams.stringFormatIdle       = 0;
    objectParams.maxSpriteWalk          = 0;
    objectParams.stringFormatWalk       = 0;
    objectParams.maxSpriteTalk          = 0;
    
    objectParams.jumpPixelsPerSecond    = 0;
    objectParams.movePixelsPerSecond    = 0;
    objectParams.walkAnimNextFrameTime  = 0;
    objectParams.idleAnimNextFrameTime  = 0;   
    
    objectParams.stringFormatJump       = @"";
    
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
        
    }
    
    return self;
}

- (void)step:(ccTime)delta
{
    [super step:delta];
}

@end
