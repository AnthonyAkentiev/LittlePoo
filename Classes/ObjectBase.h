#import "cocos2d.h"
#import "SpriteEx.h"
#import "StageBase.h"

struct ObjectParams
{
    NSString*   name;
    CGSize      spriteSize;
    
    unsigned int scoreModifier;
    unsigned int timeModifier;
    unsigned int hitPointModifier;
};

@interface ObjectBase: NSObject
{
@protected
    StageBase<IStage>*  world;
    CCSpriteEx*         sprite;
    
    ObjectParams        staticParams;
    
    CGSize              playerSize;	
}

- (id)initWithWorld:(StageBase<IStage>*)w 
                pos:(CGPoint)pos 
             params:(ObjectParams)p
           spriteIn:(CCSpriteEx*)spriteIn
            zValue:(int)zValue;
-(void)dealloc;

-(CCAction*) runAction:(CCAction*) action;

// direct sprite manipulation!!!
- (void) moveSprite:(CGFloat)x y:(CGFloat)y;
- (CGRect) getCurrentPositionWorld;

- (NSString*) getName;

// screen coordinates
- (CGPoint) getCenterPos;
- (CGPoint) getLeftAnchorPos;
- (CGRect)  getLeftAnchorPosRect;
- (CGSize)  getObjectSize;

- (void) playerTouched:(id)player;
- (BOOL) isVisible;

@end

// This is generic object that can get you money or time (for example)
// When player collide with it -> it disappears.
@interface CollectableObject: ObjectBase
{
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props;

-(BOOL) isScoreModifier;
-(BOOL) isTimeModifier;

@end

// This object is used as simple background sprite (with no animation yet). 
@interface BackgroundObject: ObjectBase
{
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props;

@end

// This is fake object but we will use it as a GOAL. When player would see
// it -> "script" actions would occur!
@interface GoalObject: ObjectBase
{
    
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props;

@end