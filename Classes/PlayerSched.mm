#import "Player.h"
#import "PlayerSched.h"

/*
// pass coords.difference
-(void) scheduleMovePlayerLeftRight:(CGFloat)diff 
    timing:(ccTime)timing 
    tag:(NSInteger)tag
{    
    if([sprite getActionByTag:tag])
        return;
    
    const CGPoint delta = ccp(diff,0);
    
    // check screen margins
    const CGFloat after = sprite.position.x + diff;
    const CGFloat leftMargin = after - [sprite getContentSize].width/2;
    const CGFloat rightMargin= after + [sprite getContentSize].width/2;
    
    const CGSize screen = [[CCDirector sharedDirector] winSize];
    
    if(IS_NEAR(leftMargin,0.0f) || leftMargin<0.0f)
        return;
    
    if(IS_NEAR(rightMargin,screen.width) || rightMargin>screen.width)
        return;
    
    CCMoveBy* action = [CCMoveBy actionWithDuration:timing position:delta];
    [action setTag:tag];
    [sprite runAction:action];
}

- (void) scheduleMovePlayerRight
{
    const CGFloat timing = (LEFTRIGHT_MOVE/BLOCK_SIZE) * SINGLE_BLOCK_MOVE_TIMING;
    [self scheduleMovePlayerLeftRight:LEFTRIGHT_MOVE timing:timing tag:ACTION_MOVE_TAG];
}

- (void) scheduleMovePlayerLeft
{
    const CGFloat timing = (LEFTRIGHT_MOVE/BLOCK_SIZE) * SINGLE_BLOCK_MOVE_TIMING;
    [self scheduleMovePlayerLeftRight:-LEFTRIGHT_MOVE timing:timing tag:ACTION_MOVE_TAG];
}

-(void) scheduleJumpTo:(CGPoint)jumpTo timing:(ccTime)timing
{
     if([sprite getActionByTag:ACTION_JUMP_TAG])
        return;
     
     unsigned int sY  = abs(sprite.position.y);
     unsigned int opY = abs(jumpToPoint.y);
     
     const CGPoint jumpOne = ccp((jumpTo.x + sprite.position.x)/2,jumpTo.y);
     const CGPoint jumpTwo = ccp(jumpTo.x,sprite.position.y);
     
     if(sY==opY)
     {
         // jump is alowed!            
         CCJumpTo* actionJump = [CCJumpTo actionWithDuration:timing
         position:jumpOne
         height:2.5f
         jumps:1];
         
         // This doesn't work :-(
         CCJumpTo* actionBack = [CCJumpTo actionWithDuration:timing 
         position:jumpTwo
         height:2.5f
         jumps:1];
         
         // up, then down
         [actionJump setTag:ACTION_JUMP_TAG];
         [sprite runAction:[CCSequence actions:actionJump,actionBack,nil]];
     }
}

- (void) scheduleJump
{   
    const CGFloat timing = (JUMP_AMOUNT_Y/BLOCK_SIZE) * SINGLE_BLOCK_JUMP_TIMING;
    
    [self scheduleJumpTo:ccp(sprite.position.x,sprite.position.y + JUMP_AMOUNT_Y)
                  timing:timing];
}

- (void) scheduleJumpLeft
{
    const CGFloat timing = (JUMP_AMOUNT_Y/BLOCK_SIZE) * SINGLE_BLOCK_JUMP_TIMING;
    
    [self scheduleJumpTo:ccp(sprite.position.x - JUMP_AMOUNT_X,sprite.position.y + JUMP_AMOUNT_Y)
                  timing:timing];
}

- (void) scheduleJumpRight
{
    CGFloat timing = (JUMP_AMOUNT_Y/BLOCK_SIZE) * SINGLE_BLOCK_JUMP_TIMING;
    
    [self scheduleJumpTo:ccp(sprite.position.x + JUMP_AMOUNT_X,sprite.position.y + JUMP_AMOUNT_Y)
                  timing:timing];
}

- (void) scheduleWalkAnimation
{
    if(![sprite getActionByTag:ACTION_ANIM_WALK])
    {      
        NSMutableArray* walkAnimFrames = [NSMutableArray array];
        
        for(unsigned int i = 1; i <= 8; ++i) 
        {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"bear%d.png", i]]];
        }        
        
        CCAnimation* walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:SINGLE_QUANTUM];
        
        CCAction* walkAction = [CCAnimate actionWithAnimation:walkAnim];
        
        [walkAction setTag:ACTION_ANIM_WALK];
        [sprite runAction:walkAction];
    }
}
*/

