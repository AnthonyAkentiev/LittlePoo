#import "cocos2d.h"
#import "SpriteEx.h"
#import "StageBase.h"
#import "ObjectBase.h"

// TODO: optimize - make static for all objects!!!
struct MovingObjectParams
{    
    // Animations
    unsigned char maxSpriteIdle;
    unsigned char maxSpriteWalk;
    unsigned char maxSpriteTalk;
    unsigned char maxSpriteJump;
    
    NSMutableArray* spritesIdle;
    NSMutableArray* spritesWalk;
    NSMutableArray* spritesTalk;
    NSMutableArray* spritesJump;
 
    NSString*   stringFormatIdle;
    NSString*   stringFormatWalk;
    NSString*   stringFormatTalk;
    NSString*   stringFormatJump;
    
    ccTime      walkAnimNextFrameTime;
    ccTime      idleAnimNextFrameTime;
    ccTime      talkAnimNextFrameTime;
    char        repeatTalkTimes;
    
    CGFloat     jumpPixelsPerSecond;
    CGFloat     movePixelsPerSecond;
    
    BOOL        lookingLeft;
    BOOL        movingRight;            // Flag to move player to the right (othrwise - to the left :-))! 
    
    // AI :-)
    int         patrolAction;          // moving left and right. provided in SINGLE_BLOCK 
    int         flyAction;             // flying up and down. provided in SINGLE_BLOCK
    BOOL        autoTurn;
};

@interface MovingObject: ObjectBase
{
@protected
    // This is initialized when Sprite is loaded from file.
    // do we need to flip sprite for it to look to the right?
    BOOL        rightFlip;
    CGPoint     spawnPoint;             // this is loaded from tilemap
@protected       
// Different
    BOOL        isDead;   
    BOOL        moving;
    BOOL        gravity;
    
    BOOL        lookingLeft;
    BOOL        movingRight;            // Flag to move player to the right (otherwise - to the left :-))! 
    
    MovingObjectParams params;
    
// Animations
    ccTime       animationWalkLeft;     // stop the animation when reaches Zero
    ccTime       animationWalkElapsed;  // to get current frame    
    ccTime       idleAnimationElapsed;    
    ccTime       jumpAnimationElapsed;
    
    ccTime       animationTalkLeft;
    ccTime       animationTalkElapsed;
    ccTime       jumpEffectTimeLeft;
// Movements
    // world coords:
    CGPoint     jumpFromPoint;
    CGPoint     jumpToPoint;
    CGPoint     wantedMovePoint;        // world coordinates, left anchored
    
    BOOL        doJump;  
    BOOL        jumpUp;
    
    BOOL        flyUp;
    // Actions internal logics
    BOOL        aiControlled;
    BOOL        freeze;
    CGRect      shouldReach;
    
    // DIFF
    NSMutableArray* objsMove;
    NSMutableArray* objsJmp;
    
    id          ai;
}

// Will convert string formats into sprite names
- (void) unpackStringParams;
- (void) unpackString:(NSMutableArray**) array
               format:(NSString*)format
             maxIndex:(unsigned char)maxIndex;

- (void) moveSpriteOrWorld:(CGPoint) newPosition
                     diff:(CGPoint) diff;

- (void) step: (ccTime) delta;
- (id)initWithWorld:(StageBase<IStage>*)w 
                pos:(CGPoint)pos 
       staticParams:(ObjectParams)sp
             params:(MovingObjectParams)p
           spriteIn:(CCSpriteEx*)spriteIn
   playerControlled:(BOOL)playerControlled;

- (void)dealloc;

// basic actions
-(void) doJumpInternal:(CGFloat)jumpHeight;
-(void) doJump;
-(void) doLeft;
-(void) doRight;

// Access methods
- (void)    setLookRight;
- (void)    setLookLeft;
- (BOOL)    isLookingLeft;
- (BOOL)    isFlyingUp;
- (void)    setIsFlyingUp:(BOOL)doFlyUp;
- (void)    setShouldReach:(CGRect)shouldReachRect;
- (CGRect)  getShouldReach;
- (MovingObjectParams*) getMovingParams;

// AI
- (void)    setFreeze:(BOOL)param;
- (BOOL)    isAiControlled;
- (int)     getPatrolAction:(CGRect*) shouldReachOut;
- (int)     getFlyAction:(CGRect*) shouldReachOut;
- (void)    die;

// in world coordinates
- (CGRect) getJumpDiagonalRect:(BOOL)jumpRight;
- (CGRect) getJumpDiagonalRect:(BOOL)jumpRight
                        goDown:(BOOL)goDown
                          step:(ccTime)step;

- (CGRect) getFallDiagonalRect:(BOOL)fallDown;
- (BOOL)   isCollidesWhileJumping:(CGPoint)resultingAction
                           goDown:(BOOL)goDown
                             step:(ccTime)step;

- (CGFloat) getMaximumMoveValLeft:(CGFloat)wantedMove;
- (CGFloat) getMaximumMoveValRight:(CGFloat)wantedMove;

// Check that player are within screen 
// This method deals with screen coordinates (little optimization ;-))
- (CGFloat) checkScreenMargins:(CGFloat)wantedOffset;
- (void)    checkAndFallInGap;
- (BOOL)    checkIfJumpAllowed;
- (BOOL)    checkIfFallAllowed;

- (BOOL) isIntersectingSomething:(CGPoint)atPosition;
- (BOOL) isFallingDown;

- (void) moveObject:(CGFloat)amount;
- (void) moveSpriteDirectX:(CGFloat)x;
- (void) moveSpriteDirectY:(CGFloat)y;

- (void) stopMoving;

- (void) jump:(CGFloat)height;
- (BOOL) isMoving:(BOOL*)movingRightOut;
- (BOOL) isJumping:(BOOL*)movingRightOut;
- (void) setGravity:(BOOL)enabled;

// Animations:
- (void) playWalkAnimation;
- (void) playTalkAnimation;

@end