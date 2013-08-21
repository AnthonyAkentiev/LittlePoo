#include "cocos2d.h"
#import "Button.h"

@class Game;

@interface LayerControl: CCLayer
{    
    Game* game;
        
    BOOL disableControls;
    BOOL dialogueMode;
    BOOL showJumpButton;    // for dialogue mode only
    BOOL alternativeColor;
    
    ButtonControl* leftButton;
    ButtonControl* rightButton;
    ButtonControl* weaponChangeButton;
    ButtonControl* attackButton;
    ButtonControl* jumpButton;
    
    ButtonControl* muteButton;
    ButtonControl* pauseButton;
    
    unsigned int    timeLeftPrevValue;
    CCLabelTTF*     labelTimeLeft;
    
    CCLabelTTF*     labelScore;
    
    NSMutableArray* hitPointsControls;
}

-(void) initWithGame:(Game*)game
 alternativeHudColor:(BOOL)alternativeHudColor;

-(void) disableControls:(BOOL) disable;

-(void) showLabels:(BOOL)show;
-(void) dialogueMode:(BOOL)dialogMode;
-(void) showJumpButton:(BOOL)show;

// This methods return YES if button is pressed (polling)
-(BOOL) jumpButton;
-(BOOL) attackButton;
-(BOOL) weaponButton;
-(BOOL) leftButton;
-(BOOL) rightButton;
-(BOOL) pauseButton;
-(BOOL) muteButton;

-(void) updateTimeLeft:(unsigned int)value;
-(void) updateScore:(unsigned int)value;
-(void) updateHitPoints:(unsigned int)value;

-(CGPoint) getScorePos;
-(CGPoint) getTimePos;
-(void) blinkScore;
-(void) blinkTime;
@end