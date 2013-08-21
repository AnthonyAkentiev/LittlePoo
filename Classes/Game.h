// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "StageBase.h"
#import "Player.h"
#import "ControlLayer.h"
#import "Dialogue.h"

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
@interface Game: CCLayer
{		
	Player*             player;
    LayerControl*       controlLayer;    
    StageBase<IStage>*  currentStage;
    
    NSMutableArray*     openedStages;
    NSMutableArray*     collectedObjects;
@private
    // Game data
    // seconds
    BOOL         stopTimeTicking;
    BOOL         gameOverTrigger;
    BOOL         nextStageTriggered;
    
    unsigned int timeNeededForCurrentStage;

// Camera
    CGPoint currentCameraPosition;
    CGPoint wantedMovePoint;
    
// Dialogue stuff
    BOOL             playingDialogue;
    unsigned int     currentDialoguePhraseIndex;
    DialogueStage    currentDialogueState;
    ccTime           waitTimeElapsed;
    
    ccTime           muteLastPressed;
    
    CCLabelTTF*      dialogueLabel;
    CCSpriteEx*      cloudSprite;
    
    NSMutableArray*  objsJump;
}

// read from file
+(BOOL)            isFirstRun;
+(NSMutableArray*) getOpenStagesArray;
+(NSString*)       getStagesFilePath;
+(int)             getLastStageTag;    // returns tag
+(BOOL)            isPresentStage:(NSMutableArray*)openedStages
                         stageTag:(int)stageTag;

+(NSString*) getMusicFilePath;
+(BOOL)      isSpecialMusicMode;
+(void)      enableSpecialMusicMode;
+(void)      enableAllStages;

+(StageBase<IStage>*) getStageByTag:(int)tag;


-(StageBase<IStage>*) getCurrentStage;
-(id) initWithStage:(StageBase<IStage>*)stage;
-(void)dealloc;

-(void) updateStatsTimer: (ccTime) delta;

// callbacks
-(void) screenIsTouched;
-(void) muteButton;
-(void) pauseButton;
-(void) weaponButton;
-(void) attackButton;
-(void) jumpButton:(BOOL)leftButton 
       rightButton:(BOOL)rightButtonPressed
             delta:(ccTime)delta;

-(void) leftButton:(ccTime)delta;
-(void) rightButton:(ccTime)delta;

-(void) continueDialogue;

// main loop callback
-(void) update: (ccTime) delta;
//-(void) cameraStep:(ccTime) delta;

//-(void) draw;
-(void) nextStage;

-(void) moveCamera:(CGPoint)diff;
-(void) moveCameraToPoint:(CGFloat)pntX;        // TODO: handle CGPoint

-(void) followCamera:(ccTime) delta;

-(BOOL) isReachedGoal;

- (void) playDialogue:(ccTime)delta;

@end

