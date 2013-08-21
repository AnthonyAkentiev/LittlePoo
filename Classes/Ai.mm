#import "Ai.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"

@implementation  Ai

-(CGRect) getTargetPatrolRect:(MovingObject*)obj
              patrolActionVal:(int)patrolActionVal
{    
    CGRect rectOut = [obj getCurrentPositionWorld];
    if([obj isLookingLeft])
    {
        // player should move left
        CGFloat wantedOffset = (patrolActionVal * BLOCK_SIZE);
        if([obj getMovingParams]->autoTurn)
        {
            CGFloat moveVal = abs([obj getMaximumMoveValLeft:wantedOffset]);
            if(moveVal<wantedOffset)
                wantedOffset = moveVal;
        }
        rectOut.origin.x-=wantedOffset;
    }else
    {
        // player should move right
        CGFloat wantedOffset = (patrolActionVal * BLOCK_SIZE);
        if([obj getMovingParams]->autoTurn)
        {
            CGFloat moveVal = abs([obj getMaximumMoveValRight:wantedOffset]);
            if(moveVal<wantedOffset)
                wantedOffset = moveVal;
        }
        rectOut.origin.x+=wantedOffset;
    }
    return rectOut;
}

-(CGRect) getTargetFlyRect:(MovingObject*)obj
              flyActionVal:(int)flyActionVal
{   
    CGRect rectOut = [obj getCurrentPositionWorld];
    if(![obj isFlyingUp])
    {
        // player should move down
        rectOut.origin.y-=(flyActionVal * BLOCK_SIZE_Y);
    }else
    {
        // player should move up
        rectOut.origin.y+=(flyActionVal * BLOCK_SIZE_Y);
    }
    return rectOut;
}

-(void) initActions:(MovingObject*)obj
{      
    if([obj getMovingParams]->patrolAction)
    {
        [obj setShouldReach:[self getTargetPatrolRect:obj 
                                      patrolActionVal:[obj getMovingParams]->patrolAction]];
    }
    
    if([obj getMovingParams]->flyAction)
    {
        [obj setShouldReach:[self getTargetFlyRect:obj 
                                      flyActionVal:[obj getMovingParams]->flyAction]];
    }
}

-(BOOL) isReached:(CGRect)rectCurrPos 
           target:(CGRect)target
              obj:(MovingObject*)obj
{    
    if(![obj isLookingLeft])
    {
        // should move right
        return CGRectGetMaxX(rectCurrPos)>=CGRectGetMaxX(target);
    }else
    {
        // should move left
        return CGRectGetMinX(rectCurrPos)<=CGRectGetMinX(target);
    }
    return NO;
}

-(BOOL) isReachedFly:(CGRect)rectCurrPos 
              target:(CGRect)target
                 obj:(MovingObject*)obj
{    
    if([obj isFlyingUp])
    {
        // should move up
        return IS_BIGGER(CGRectGetMaxY(rectCurrPos)+1,CGRectGetMaxY(target));
    }else
    {
        // should move down
        return IS_SMALLER(CGRectGetMinY(rectCurrPos),CGRectGetMinY(target)+1);
    }
    return NO;
}

-(void) moveOpposite:(MovingObject*)obj
{    
    // move into opposite direction
    if([obj isLookingLeft])
        [obj setLookRight];
    else
        [obj setLookLeft];
    
    // recalculate target rect
    [obj setShouldReach:[self getTargetPatrolRect:obj 
                                  patrolActionVal:[obj getMovingParams]->patrolAction]];
}

-(void) doAiActions:(MovingObject*)obj
{     
    // process all actions
    if([obj getMovingParams]->patrolAction)
    {
        NSAssert(![obj getMovingParams]->flyAction,@"Either fly or patrol should be used!");
        
        // check if we reached maximum value
        CGRect rectCurrPos = [obj getCurrentPositionWorld];
        
        if(![self isReached:rectCurrPos 
                     target:[obj getShouldReach]
                        obj:obj])
        {
            // continue move
            if([obj isLookingLeft])
                [obj doLeft];
            else
                [obj doRight];
        }else
        {
            [self moveOpposite:obj];
        }
    }
    
    if([obj getMovingParams]->flyAction)
    {
        NSAssert(![obj getMovingParams]->patrolAction,@"Either fly or patrol should be used!");
        
        // check if we reached maximum value
        CGRect rectCurrPos = [obj getCurrentPositionWorld];
        
        if(![self isReachedFly:rectCurrPos 
                        target:[obj getShouldReach] 
                           obj:obj])
        {
            // continue move
            if([obj isFlyingUp])
                [obj doJumpInternal:([obj getMovingParams]->flyAction * BLOCK_SIZE_Y)];
            // ... gravity will move us down.
        }else
        {
            [obj setIsFlyingUp:![obj isFlyingUp]];
            
            // recalculate target rect
            [obj setShouldReach:
                [self getTargetFlyRect:obj
                          flyActionVal:[obj getMovingParams]->flyAction]
            ];
        }        
    }
}


@end