#import "cocos2d.h"
#include "triggers.h"
#import "SpriteEx.h"
#import "StageBase.h"
#import "MovingObject.h"

@interface Player: MovingObject
{   
@private
// Behavior Modifiers
    BOOL        flyingMode;
    BOOL        bikerMode;    
    BOOL        dialogueMode;
    
    unsigned int hitPoints;
    
    ccTime      lastTouchedEnemyLeft;
    
    unsigned int timeElapsed;
    unsigned int score;
}

- (id)initWithWorld:(StageBase<IStage>*)world;
- (void)dealloc;

- (void) step:(ccTime)delta;

- (BOOL) isDead;

- (unsigned int) getHitPoints;
- (void) setHitPoints:(unsigned int)hitPoints;

- (unsigned int) getTimeElapsed;
- (void) setTimeElapsed:(unsigned int)time;

- (unsigned int) getScore;
- (void) setScore:(unsigned int)score;

- (void) setDialogueMode:(BOOL)value;
- (BOOL) isDialogueMode;

-(void) touchedEnemy:(ObjectBase*)enemy;
-(void) startBlinkAction;
- (BOOL)isStillTouching;

// called when object is collected. Use only special modifiers (do not update score/time)!
-(void) updateSpecialModifiers:(ObjectBase*)object;
-(void) setFlyingMode:(BOOL)enabled;

#ifdef TEST_STAGE_MODE
-(void) goToEnd;
#endif

@end