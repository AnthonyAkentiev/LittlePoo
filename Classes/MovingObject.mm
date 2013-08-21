#import "MovingObject.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"
#import "Ai.h"
#import "SimpleAudioEngine.h"

@implementation MovingObject

- (void)  die
{
    [sprite setVisible:NO];
    isDead = YES;
}

// TODO: refactor - move all animation into single class
-(void) playWalkAnimationInternal:(ccTime)delta
{
    // adjust
    if(animationWalkLeft - delta<0.0f)
        delta = animationWalkLeft;
    
    animationWalkElapsed+=delta;
    animationWalkLeft-=delta;
    
    const CGFloat singleFrameTime = params.walkAnimNextFrameTime;
    unsigned int currentWalkFrame = (unsigned int) (animationWalkElapsed / singleFrameTime);
    currentWalkFrame = (currentWalkFrame % params.maxSpriteWalk);
    
    CCSpriteFrame* newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [params.spritesWalk objectAtIndex:currentWalkFrame]];
    
    //if(!aiControlled)
    //    NSLog(@"Frame:%d (delta - %f; animationWalkLeft=%f)",currentWalkFrame,delta,animationWalkLeft);
    
    [sprite setDisplayFrame:newFrame];
    
    // stop?
    if(animationWalkLeft<0.0f)
        animationWalkLeft = 0.0f;
}

-(void) playTalkAnimationInternal:(ccTime)delta
{
    // adjust
    if(animationTalkLeft - delta<0.0f)
        delta = animationTalkLeft;
    
    animationTalkElapsed+=delta;
    animationTalkLeft-=delta;
    
    const CGFloat singleFrameTime = params.talkAnimNextFrameTime;
    unsigned int currentWalkFrame = (unsigned int) (animationTalkElapsed / singleFrameTime);
    currentWalkFrame = (currentWalkFrame % params.maxSpriteTalk);
    
    CCSpriteFrame* newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [params.spritesTalk objectAtIndex:currentWalkFrame]];
    
    [sprite setDisplayFrame:newFrame];
    
    // stop?
    if(animationTalkLeft<0.0f)
        animationTalkLeft = 0.0f;
}

-(void) playIdleAnimationInternal:(ccTime)delta
{
    // always draw idle animation if no actions specified!
    idleAnimationElapsed+=delta;
    
    // 0..n
    const CGFloat singleFrameTime = params.idleAnimNextFrameTime;
    unsigned int currentWalkFrame = (unsigned int) (idleAnimationElapsed / singleFrameTime);
    currentWalkFrame = (currentWalkFrame % params.maxSpriteIdle);
    
    NSString* strSprite = [params.spritesIdle objectAtIndex:currentWalkFrame];
    
    //if(!aiControlled)
    //    NSLog(@"***Idle frame:%d",currentWalkFrame);
    
    CCSpriteFrame* newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:strSprite];        
    [sprite setDisplayFrame:newFrame];
}

-(void) playJumpAnimation:(ccTime)delta
{
    // always draw idle animation if no actions specified!
    jumpAnimationElapsed+=delta;
    
    // 0..n
    const CGFloat singleFrameTime = params.walkAnimNextFrameTime;
    unsigned int currentFrame = (unsigned int) (jumpAnimationElapsed / singleFrameTime);
    currentFrame = (currentFrame % params.maxSpriteJump);
    
    NSString* strSprite = [params.spritesJump objectAtIndex:currentFrame];
    
    CCSpriteFrame* newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:strSprite];        
    [sprite setDisplayFrame:newFrame];
}

-(void) drawAnimations:(ccTime)delta
{
    // WALK animation
    if(doJump && ([params.stringFormatJump length] || aiControlled) )
    {
        // ai controlled NPC can only patrol (left-right) or fly(jump up-down)
        // so jump animation is really "Walk" animation (less variables to program :-)))
        if(aiControlled)
        {
            animationWalkLeft = 1000;   // forever!
            [self playWalkAnimationInternal:delta];
        }else
        {
            [self playJumpAnimation:delta];
        }
    }else if(animationWalkLeft>0.0 && params.maxSpriteWalk)
    {
        [self playWalkAnimationInternal:delta];
    }else if(animationTalkLeft>0.0 && params.maxSpriteTalk)
    {
        [self playTalkAnimationInternal:delta];
    }
    else if(params.maxSpriteIdle)
    {      
        [self playIdleAnimationInternal:delta];
    }    
}

- (BOOL) isAiShouldBeActive
{
    CGRect pos = [self getCurrentPositionWorld];
    
    CGRect screen;
    screen.origin.x = 0;
    screen.origin.y = 0;
    screen.size = [[CCDirector sharedDirector] winSize];    
    screen.size.height= TO_WORLD_COORDS_X(screen.size.height);
    screen.size.width = TO_WORLD_COORDS_X(screen.size.width);
    
    screen = [world toWorldCoords:screen];
    
    screen.origin.y     = -500;
    screen.size.height  = INT_MAX;
    screen.origin.x-=TO_WORLD_COORDS_X(screen.size.width);
    screen.size.width+=TO_WORLD_COORDS_X(2*screen.size.width);       // 1 screens to the left, 1 to the right
    
    if(!CGRectIntersectsRect(pos,screen))
        return NO;
    
    return YES;
}

// world coords
-(CGRect) getJumpDiagonalRect:(BOOL)jumpRight
                       goDown:(BOOL)goDown
                         step:(ccTime)step
{
    CGRect rectPos = [self getCurrentPositionWorld];
    
    // we should allow player to move AT LEAST 1 block to the right or to the left.
    const CGFloat speedX = SINGLE_BLOCK_MOVE_TIMING;
    const CGFloat speedY = SINGLE_BLOCK_JUMP_TIMING;    
    
    const CGFloat willGetX      = step * speedX;
    const CGFloat willGetHigher = step * speedY;
    
    if(goDown)
        rectPos.origin.y-=willGetHigher;    
    else
        rectPos.origin.y+=willGetHigher;
    
    // moving right!
    if(jumpRight)
        rectPos.origin.x+=+willGetX;
    else
        rectPos.origin.x-=willGetX;
    
    return rectPos;
}

- (BOOL) isCollidesWhileJumping:(CGPoint)resultingAction
                         goDown:(BOOL)goDown
                           step:(ccTime)step
{
    CGRect rect = [self getCurrentPositionWorld];
    const BOOL isJumpingRight = (wantedMovePoint.x > rect.origin.x);    
    const BOOL isJumpingLeft  = (wantedMovePoint.x < rect.origin.x);    
    
    if(isJumpingRight)
    {
        NSAssert(!isJumpingLeft,@"Bad logics");
        CGRect rectToCollide = [self getJumpDiagonalRect:YES
                                                  goDown:goDown
                                                    step:step];
        return [world isIntersectingSomething:rectToCollide];
    }else if(isJumpingLeft)
    {
        NSAssert(!isJumpingRight,@"Bad logics");
        CGRect rectToCollide = [self getJumpDiagonalRect:NO
                                                  goDown:goDown
                                                    step:step];
        return [world isIntersectingSomething:rectToCollide];
    }else
    {
        // jumping up
    }
    
    return NO;
}

- (void) cancelActions:(CGPoint)resultingAction
                  step:(ccTime)step
{  
    // Cancel actions
    // X
    CGRect rect = [self getCurrentPositionWorld];
    if(wantedMovePoint.x>=rect.origin.x)
    {
        // moved to the right
        if(IS_BIGGER(rect.origin.x,wantedMovePoint.x))
        {
            moving = NO;
        }else
        {
            // check if collides with wall
            CGFloat moveVal = [self getMaximumMoveValRight:LEFTRIGHT_MOVE];
            //NSLog(@"moveVal=%f",moveVal);
            if(IS_NEAR(moveVal,0.0))
                moving = NO;
        }
    }else
    {
        if(IS_SMALLER(rect.origin.x,wantedMovePoint.x))
        {
            moving = NO;
        }else
        {
            // check if collides with wall
            CGFloat moveVal = [self getMaximumMoveValLeft:LEFTRIGHT_MOVE];
            if(IS_NEAR(moveVal,0.0))
                moving = NO;
        }
    }
    
    // Y
    // if while jumping -> revert if reached highest position
    if(doJump)
    {
         // make sure we would not go into the wall :-))
         if(jumpUp)
         {
             if([self isCollidesWhileJumping:resultingAction
                                      goDown:NO
                                        step:step])
             {
                 wantedMovePoint.y = -10000; // go down!
                 jumpUp            = NO;
             }
         }else
         {
             if([self isCollidesWhileJumping:resultingAction
                                      goDown:YES
                                        step:step])
             {
                 doJump            = NO;
                 //NSLog(@"position1");
             }
         }
        
        if(jumpUp && IS_BIGGER(rect.origin.y, wantedMovePoint.y ))
        {
            wantedMovePoint.y = -10000; // go down!
            jumpUp            = NO;
        }    
        
        if(!jumpUp && IS_NEAR(resultingAction.y,0))
        {
            doJump = NO;
            //NSLog(@"position2");
        }
    }

    // DIE?
    if(rect.origin.y<-100)
    {
        [self die];        
    }    
}

///////// Processing loop
- (void) step:(ccTime)delta
{
    if(isDead)
        return;
    
    jumpEffectTimeLeft-=delta;
    
    // check if this object is visible on screen
    if(aiControlled)
    {
        if(![self isAiShouldBeActive])
        {
            //NSLog(@"Stop actions for object: %@",params.name);
            return;
        }
        [((Ai*)ai) doAiActions:self];
    }
    
    // left-anchored!
    const CGRect rectCurr = [self getCurrentPositionWorld];
    CGPoint currPos = rectCurr.origin;
    
    const CGFloat xDiffPerStep = params.movePixelsPerSecond  * delta;
    CGFloat yDiffPerStep = params.jumpPixelsPerSecond  * delta;
    
    CGPoint resultingAction;
    resultingAction.x = (wantedMovePoint.x - currPos.x);
    resultingAction.y = (wantedMovePoint.y - currPos.y);
    
    if(!gravity && resultingAction.y<0)
    {
        // if in special mode
        yDiffPerStep/=4;
    }
    
    //NSLog(@"Player diff is = %f",resultingAction.x);
    
    // Trnucate to what we can increase in this step only! 
    if(resultingAction.x<0)
        resultingAction.x = MAX(resultingAction.x,-xDiffPerStep);
    else
        resultingAction.x = MIN(resultingAction.x,xDiffPerStep);
    
    if(resultingAction.y<0)
        resultingAction.y = MAX(resultingAction.y,-yDiffPerStep);
    else
        resultingAction.y = MIN(resultingAction.y,yDiffPerStep);
    
    // now find collisions!   
    // Y (gravity)
    if(resultingAction.y<0)
    {        
        // left-anchored!     
        const CGFloat untilNextFloor = [world getDiffGround:rectCurr];
        
        if(IS_BIGGER(-resultingAction.y,untilNextFloor-1))
        {
            resultingAction.y = -untilNextFloor + 1;
        }
    }
    
    CGPoint newPosition = ccp(currPos.x + resultingAction.x,
                              currPos.y + resultingAction.y);
      
    // apply!
    if(!IS_NEAR(resultingAction.x,0.0) || !IS_NEAR(resultingAction.y,0.0))
    {
        [self moveSpriteOrWorld:newPosition diff:resultingAction];
    }
    
    [self cancelActions:resultingAction
                   step:delta];
    
    // MOVE
    // if getting to close to gap -> move to it so it will look like player falls while getting near!
#ifdef FALL_IN_GAP_IF_GOT_NEAR
    if(!moving)
    {
        [self checkAndFallInGap];
    }
#endif
    
    [self drawAnimations:delta];
}

// world coords, left anchored
-(void) moveSpriteOrWorld:(CGPoint)newPosition
                     diff:(CGPoint)diff
{        
    // to world coords
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    screen = [world toWorldCoords:screen];
    
    CGRect currentPos = [self getCurrentPositionWorld];    
    const CGFloat center = currentPos.origin.x + currentPos.size.width/2;
    
    BOOL isInFirstHalfOfFirstScreen = NO;
    BOOL isInLastHalfOfLastScreen   = NO;
    
    const CGFloat l = [world getGoalObjPos].origin.x 
        + [world getGoalObjPos].size.width - screen.size.width/2;   
    if( newPosition.x > currentPos.origin.x )
    {
        // going to the right
        isInFirstHalfOfFirstScreen = IS_STRICT_SMALLER(center, screen.size.width/2);
        isInLastHalfOfLastScreen   = IS_BIGGER(center, l );
    }else
    {
        // going left
        isInFirstHalfOfFirstScreen = IS_SMALLER(center, screen.size.width/2);
        isInLastHalfOfLastScreen   = IS_STRICT_BIGGER(center, l );
    }
    
    BOOL moveSprite = NO;
    
    // Send "command" :-)
    // X
    if(!aiControlled && !isInFirstHalfOfFirstScreen && !isInLastHalfOfLastScreen )
    {
        if(![world moveLayerDirectX:LRINT(-diff.x)])
        {
            // if can't move world -> then just move sprite!
            moveSprite = YES;
        }
    }else
    {
        moveSprite = YES;
    }  
    
    if(moveSprite)
    {
        // move sprite!
        CGPoint pntMoveHor = newPosition;
        [world toScreenCoordsPoint:&pntMoveHor];
        
        // move only X
        pntMoveHor.y = sprite.position.y;
        [sprite setPosition:pntMoveHor];
    }
    
    CGPoint pntMoveVert = newPosition;
    [world toScreenCoordsPoint:&pntMoveVert];
    pntMoveVert.x = sprite.position.x;
    
    // Y
    //NSLog(@"Moving sprite %f",pntMoveVert.y);
    [sprite setPosition:pntMoveVert];
}

- (void) playWalkAnimation
{    
    if(animationWalkLeft>0.0f)
        return;    
    
    animationWalkLeft = params.walkAnimNextFrameTime;
}

-(void) playTalkAnimation
{
    if(animationTalkLeft>0.0f)
        return;    
    
    animationTalkLeft = params.maxSpriteTalk * params.talkAnimNextFrameTime * params.repeatTalkTimes;
}

- (id)initWithWorld:(StageBase<IStage>*)w 
                pos:(CGPoint)pos 
     staticParams:(ObjectParams)sp
             params:(MovingObjectParams)p
           spriteIn:(CCSpriteEx*)spriteIn
   playerControlled:(BOOL)playerControlled
{    
    self = [super initWithWorld:w 
                     pos:pos 
                  params:sp
                spriteIn:spriteIn
                  zValue:2];
     
    if(self)
    {
        params = p;
        [self unpackStringParams];  // expand params strings into arrays for optimization
        
        // Init stuff
        objsMove           = [[NSMutableArray alloc]init];
        objsJmp            = [[NSMutableArray alloc]init];
        jumpEffectTimeLeft = 0;
        
        moving          = NO;
        lookingLeft     = params.lookingLeft;
        if(lookingLeft)
            [self setLookLeft];
        else
            [self setLookRight];
        
        movingRight     = params.movingRight;
        isDead          = NO;
        gravity         = YES;
        
        wantedMovePoint = ccp([self getCurrentPositionWorld].origin.x,-1000.0f);        
        doJump          = NO;
        jumpUp          = NO;
        flyUp           = YES;  // start flying up
        
        // 8 frames per single animation
        animationWalkLeft      = 0.0;
        animationWalkElapsed   = 0.0;
        idleAnimationElapsed   = 0.0;
        animationTalkLeft      = 0.0;
        animationTalkElapsed   = 0.0;
        jumpAnimationElapsed   = 0.0;
        
        aiControlled = !playerControlled;
        
        ai = (id)[[Ai alloc]init];
        
        if(aiControlled)
            [((Ai*)ai) initActions:self];
    }
    
    return self;
}

-(void)dealloc
{
    [ai release];
    [objsMove release];
    [objsJmp release];
    
    [params.spritesIdle release];
    [params.spritesWalk release];
    [params.spritesJump release];
    [params.spritesTalk release];
    
    [super dealloc];
}

- (void) unpackString:(NSMutableArray**) array
               format:(NSString*)format
             maxIndex:(unsigned char)maxIndex
{
    *array = [[NSMutableArray alloc]init];
    
    for(unsigned char i=1; i<=maxIndex; ++i)
    {
        NSString* str = [NSString stringWithFormat:format, i];
        [*array addObject:str];
    }    
}

- (void) unpackStringParams
{
    if(params.maxSpriteIdle)
    {
        [self unpackString:&(params.spritesIdle) 
                    format:params.stringFormatIdle
                  maxIndex:params.maxSpriteIdle];
    }

    if(params.maxSpriteWalk)
    {
        [self unpackString:&(params.spritesWalk) 
                    format:params.stringFormatWalk
                  maxIndex:params.maxSpriteWalk];
    }
    
    if(params.maxSpriteTalk)
    {
        [self unpackString:&(params.spritesTalk)
                    format:params.stringFormatTalk
                  maxIndex:params.maxSpriteTalk];
    }
    
    if(params.maxSpriteJump)
    {
        [self unpackString:&(params.spritesJump) 
                    format:params.stringFormatJump
                  maxIndex:params.maxSpriteJump];
    }
}

- (void) setLookLeft
{
    lookingLeft = YES;
    [sprite setFlipX:!rightFlip];
}

- (void) setLookRight
{
    lookingLeft = NO;
    [sprite setFlipX:rightFlip];
}

- (BOOL)     isLookingLeft
{
    return lookingLeft;
}

- (BOOL)    isFlyingUp
{
    return flyUp;
}

- (void)    setIsFlyingUp:(BOOL)doFlyUp
{
    flyUp = doFlyUp;
}

- (CGRect)  getShouldReach
{
    return shouldReach;
}

- (void)    setShouldReach:(CGRect)shouldReachRect
{
    shouldReach = shouldReachRect;
}

- (void)    setFreeze:(BOOL)param
{
    freeze = param;
}

- (BOOL)    isAiControlled
{
    return aiControlled;
}

- (MovingObjectParams*) getMovingParams
{
    return &params;
}

- (int)     getPatrolAction:(CGRect*) shouldReachOut
{
    if(!aiControlled)
        return 0;
    
    *shouldReachOut = shouldReach;
    return params.patrolAction;
}

- (int)     getFlyAction:(CGRect*) shouldReachOut
{
    if(!aiControlled)
        return 0;
    
    *shouldReachOut = shouldReach;
    return params.flyAction;
}

// world coords
-(CGRect) getJumpDiagonalRect:(BOOL)jumpRight
{
    CGRect rectPos = [self getCurrentPositionWorld];
    
    // we should allow player to move AT LEAST 1 block to the right or to the left.
    const CGFloat speedX = SINGLE_BLOCK_MOVE_TIMING;
    const CGFloat speedY = SINGLE_BLOCK_JUMP_TIMING;    
    const CGFloat secondsElapsedToMove = BLOCK_SIZE / speedX;
    const CGFloat willGetHigher = secondsElapsedToMove * speedY;
    
    CGRect rectResultingAfterSingleMove = rectPos;
    rectResultingAfterSingleMove.origin.y  = rectPos.origin.y + rectPos.size.height + willGetHigher;
    
    // moving right!
    if(jumpRight)
    {
        rectResultingAfterSingleMove.origin.x  = rectPos.origin.x+rectPos.size.width;
        // adjust rect
        rectResultingAfterSingleMove.origin.x-=2;
        rectResultingAfterSingleMove.size.width+=4;
    }
    else
    {
        rectResultingAfterSingleMove.origin.x  = rectPos.origin.x-rectPos.size.width;
        // adjust rect
        rectResultingAfterSingleMove.size.width+=4;
    }
    
    return rectResultingAfterSingleMove;
}

-(CGRect) getFallDiagonalRect:(BOOL)fallRight
{
    CGRect rectPos = [self getCurrentPositionWorld];
    
    // we should allow player to move AT LEAST 1 block to the right or to the left.
    const CGFloat speedX = SINGLE_BLOCK_MOVE_TIMING;
    const CGFloat speedY = SINGLE_BLOCK_JUMP_TIMING;    
    const CGFloat secondsElapsedToMove = BLOCK_SIZE / speedX;
    const CGFloat willGetLower = secondsElapsedToMove * speedY;
    
    CGRect rectResultingAfterSingleMove = rectPos;
    rectResultingAfterSingleMove.origin.y  = rectPos.origin.y - willGetLower;
    
    // moving right!
    if(fallRight)
    {
        rectResultingAfterSingleMove.origin.x  = rectPos.origin.x+5;
        // adjust rect
        rectResultingAfterSingleMove.origin.x-=2;
        rectResultingAfterSingleMove.size.width+=4;
    }
    else
    {
        rectResultingAfterSingleMove.origin.x  = rectPos.origin.x-5;
        // adjust rect
        rectResultingAfterSingleMove.size.width+=4;
    }
    
    return rectResultingAfterSingleMove;    
}

-(CGFloat) getMaximumMoveValLeft:(CGFloat)wantedMove
{
#ifdef TEST_STAGE_MODE
    return -wantedMove;
#endif 

    // Collision detection!
    [objsMove removeAllObjects];    
    CGRect rectPlayerTmp = [self getCurrentPositionWorld];
    
    CGRect screenRect;
    screenRect.origin = ccp(0,0);
    screenRect.size   = [[CCDirector sharedDirector] winSize];
    screenRect = [world toWorldCoords:screenRect];
    
    CGFloat nearestObject = [world getNearestObjectLeft:rectPlayerTmp
                                              worldRect:screenRect
                                    objectsIntersecting:objsMove];
    
    // calculate maximum move until WALL
    CGFloat moveVal = wantedMove;   // max
    if( rectPlayerTmp.origin.x - moveVal<nearestObject)
        moveVal = rectPlayerTmp.origin.x - nearestObject;
    
    //NSLog(@"Wanted to move (left): pos=%f; nearest=%f; original=%f; calculated=%f",
    //      rectPlayerTmp.origin.x + rectPlayerTmp.size.width,nearestObject,
    //      -LEFTRIGHT_MOVE,-moveVal);
    
    return -moveVal;
}

// adjusted with vector
-(CGRect) getCurrentPositionWorldMoving
{
    // screen coordinates!
    CGRect playerPos = [self getCurrentPositionWorld];
    
    //
    // 450 pixels per second at 60fps means 7,5 pixels per frame
    // (speed of falling down or jumping up)
    // 
    const CGPoint currPos= playerPos.origin;
    const int resultingAction  = (wantedMovePoint.y - currPos.y);
    
    const BOOL isFallingDown = (resultingAction<0);
    const BOOL isJumpingUp   = (resultingAction>0);
    
    NSAssert(!(isFallingDown && isJumpingUp),@"Bad logics - can't jump and fall at once");
    
    // full lenght - 57 pixels on iPhone retina
    //const int increaseRect   = playerPos.size.height / 10;
    const int increaseRect = 10;
    
    // adjust
    if(isFallingDown)
    {
        playerPos.origin.y-=increaseRect;
        playerPos.size.height+=increaseRect;
    }else if(isJumpingUp)
    {
        playerPos.size.height+=increaseRect;
    }
    
    return playerPos;
}

-(CGFloat) getMaximumMoveValRight:(CGFloat)wantedMove
{
#ifdef TEST_STAGE_MODE
    return wantedMove;
#endif 
    // Collision detection!
    [objsMove removeAllObjects];    
    CGRect rectPlayerTmp = [self getCurrentPositionWorldMoving];
    
    // Get intersecting physical objects  
    CGRect screenRect;
    screenRect.origin = ccp(0,0);
    screenRect.size   = [[CCDirector sharedDirector] winSize];
    screenRect = [world toWorldCoords:screenRect];
    
    CGFloat nearestObject = [world getNearestObjectRight:rectPlayerTmp
                                               worldRect:screenRect
                                     objectsIntersecting:objsMove];
    
    // calculate maximum move until WALL
    CGFloat moveVal = wantedMove;   // max
    if( nearestObject!=INT_MAX && (rectPlayerTmp.origin.x + rectPlayerTmp.size.width) + moveVal>nearestObject)
        moveVal = nearestObject - (rectPlayerTmp.origin.x + rectPlayerTmp.size.width);
    
    //NSLog(@"Wanted to move (right): pos=%f; nearest=%f; original=%f; calculated=%f",
    //      rectPlayerTmp.origin.x + rectPlayerTmp.size.width,nearestObject,
    //      LEFTRIGHT_MOVE,moveVal);
    
    return moveVal;
}

// Check that player are within screen 
// This method deals with screen coordinates (little optimization ;-))
-(CGFloat) checkScreenMargins:(CGFloat)wantedOffset
{
    if(aiControlled)
        return wantedOffset;    // do not forbid object to move further
    
    // check screen margins
    const CGFloat after = [self getCenterPos].x + wantedOffset;
    
    const CGFloat leftMargin  = after - [self getObjectSize].width/2;
    const CGFloat rightMargin = after + [self getObjectSize].width/2;        
    // TODO: Optimize?
    const CGSize  screen = [[CCDirector sharedDirector] winSize];
    
    // left screen margin
    if(IS_NEAR(leftMargin,0.0f) || leftMargin<0.0f)
    {
        return -([self getCenterPos].x - [self getObjectSize].width/2);
    }
    
    // right screen margin
    if(IS_NEAR(rightMargin,screen.width) || rightMargin>screen.width)
    {        
        return screen.width - ([self getCenterPos].x + [self getObjectSize].width/2);
    }
    
    return wantedOffset;
}

- (BOOL) checkIfFallAllowed
{
    CGRect rectResAfterSingleMove = [self getFallDiagonalRect:movingRight];
    CGRect rectCurrent = [self getCurrentPositionWorld];
    
    if([world isIntersectingSomething:rectResAfterSingleMove 
                          rectCurrent:rectCurrent] )
    {
        //NSLog(@"Do not allow move");
        return NO;
    }
    return YES;

}

- (BOOL) checkIfJumpAllowed
{
    CGRect rectResAfterSingleMove = [self getJumpDiagonalRect:movingRight];
    CGRect rectCurrent = [self getCurrentPositionWorld];
    
    if([world isIntersectingSomething:rectResAfterSingleMove 
                          rectCurrent:rectCurrent] )
    {
        //NSLog(@"Do not allow move");
        return NO;
    }
    return YES;
}

- (void) stopMoving
{
    moving = NO;
}

- (BOOL) isJumping:(BOOL*)movingRightOut
{
    *movingRightOut = movingRight;
    return doJump;
}

-(BOOL) isMoving:(BOOL*)movingRightOut
{
    *movingRightOut = movingRight;
    return moving;
}

// in screen coords!!
-(BOOL) isIntersectingSomething:(CGPoint)atPosition
{
    // screen coords, anchor is centered     
    CGRect rectAtPosition;
    rectAtPosition.size  = [self getObjectSize];
    rectAtPosition.origin= atPosition;
    
    // here we got screen rect
    rectAtPosition = [world toWorldCoords:rectAtPosition]; 
    return [world isIntersectingSomething:rectAtPosition];
}

-(BOOL) isTooCloseToGap:(BOOL*)gapIsToTheRightOut
{
    CGRect pos = [self getLeftAnchorPosRect];
    pos = [world toWorldCoords:pos];
    
    CGFloat untilNextFloor = [world getDiffGround:pos];
    if(!IS_NEAR(untilNextFloor,0.0f))   // we are just falling down!
        return NO;
    
    // check gap to the right! These calculations are too tough!
    CGRect posRight = pos;
    posRight.origin.x+=playerSize.width/2;
    untilNextFloor = [world getDiffGround:posRight];
    if(untilNextFloor>100.0f)
    {
        //NSLog(@"GAP is to the right! Fall!");
        *gapIsToTheRightOut = YES;
        return YES;
    }   
    
    // check gap to the left
    CGRect posLeft = pos;
    posLeft.origin.x-=playerSize.width/2;
    posLeft.size.width-=playerSize.width/2;
    untilNextFloor = [world getDiffGround:posLeft];
    if(untilNextFloor>100.0f)
    {
        //NSLog(@"GAP is to the left! Fall!");
        *gapIsToTheRightOut = NO;
        return YES;
    }   
    
    return NO;
}

- (void) checkAndFallInGap
{
#ifdef FALL_IN_GAP_IF_GOT_NEAR
    BOOL moveRight = YES;
    if([self isTooCloseToGap:&moveRight])
    {
        // check screen margins
        // problem with jumping from left to right but falling down into the left gap :-)
        if(moveRight)
        {
            if(lookingLeft)
                return;
        }else
        {
            if(!lookingLeft)
                return;
        }
        
        const CGFloat diff = [self checkScreenMargins:(moveRight?LEFTRIGHT_MOVE:-LEFTRIGHT_MOVE)];        
        if(!IS_NEAR(diff,0))
            [self moveObject:diff];
    }  
#endif
}

- (void) moveSpriteDirectX:(CGFloat)x
{
    wantedMovePoint.x+=x;
    // move only X
    CGPoint pnt = ccp(sprite.position.x + x,sprite.position.y);
    [sprite setPosition:pnt];
}

- (void) moveSpriteDirectY:(CGFloat)y 
{
    //wantedMovePoint.y+=y;
    
    CGPoint pnt = ccp(sprite.position.x,sprite.position.y + y);
    [sprite setPosition:pnt];
}

// TODO: make one method! What the hack?
- (void) jump:(CGFloat)height
{
    if(gravity && doJump)
        return;     // previous jump not finished
    if(jumpEffectTimeLeft>0)
        return;     // previous jump not finished
    
    if(moving)
    {
        if(![self checkIfJumpAllowed])
            return;
    }
    
    // world coords    
    CGPoint pntWanted = ccp(sprite.position.x,sprite.position.y + height);
    wantedMovePoint =  [world toWorldCoordsPoint:pntWanted];    
    
    doJump       = YES;
    jumpUp       = YES;    
}

-(void) doJumpInternal:(CGFloat)jumpHeight
{ 
    if(gravity && doJump)
        return;     // previous jump not finished
    if(jumpEffectTimeLeft>0)
        return;     // previous jump not finished
    
    // Optimization :-)
    [objsJmp removeAllObjects];
    
    // determine objects that we'd cross if we would jump now. 
    jumpHeight = [world getNearestObjectTop:[self getCurrentPositionWorld]
                               wantedHeight:jumpHeight
                        objectsIntersecting:objsJmp];
    
    [self jump:jumpHeight];
    
    doJump       = YES;
    jumpUp       = YES;
    
    if(!aiControlled && gravity)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"jump.mp3" pitch:0.8f 
                                                 pan:0.0f 
                                                gain:0.1f];
        jumpEffectTimeLeft = MINIMUM_JUMP_TIME;
    }
}

-(void) doJump
{
    [self doJumpInternal:JUMP_AMOUNT_Y];
}

- (BOOL) isFallingDown
{
    const CGRect rectCurrent = [self getCurrentPositionWorld];
    
    BOOL isFallingDown = (wantedMovePoint.y < rectCurrent.origin.y);
    if(isFallingDown)
    {
        const CGFloat untilNextFloor = [world getDiffGround:rectCurrent];
        
        if(untilNextFloor < 0 || IS_SMALLER(untilNextFloor,2))
            isFallingDown = NO;
    }
    return isFallingDown;
}

- (void) moveObject:(CGFloat)amount
{    
    if(moving)
        return;
    
    movingRight     = (amount>0.0f);   
      
    CGPoint wanted = ccp(sprite.position.x + amount,0);    
    wantedMovePoint.x = [world toWorldCoordsPoint:wanted].x;

    // fix error that occures while moving through center!
    const CGFloat blocks = wantedMovePoint.x/BLOCK_SIZE;    
    wantedMovePoint.x = lrint(blocks) * BLOCK_SIZE;
    
    moving            = YES; 
}

-(void) doLeft
{          
    [self setLookLeft];
    [self playWalkAnimation];
    
    CGFloat moveVal = [self getMaximumMoveValLeft:LEFTRIGHT_MOVE]; 
    moveVal = [self checkScreenMargins:moveVal];    
    [self moveObject:LRINT(moveVal)];
}

-(void) doRight
{          
    [self setLookRight];
    [self playWalkAnimation];
    
    CGFloat moveVal = [self getMaximumMoveValRight:LEFTRIGHT_MOVE];    
    moveVal = [self checkScreenMargins:moveVal];
    [self moveObject:LRINT(moveVal)];
}

- (void) setGravity:(BOOL)enabled
{
    gravity = enabled;
}
@end