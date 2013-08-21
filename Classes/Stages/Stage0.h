#import "cocos2d.h"
#import "StageBase.h"
#import "Snow.h"
#import "Dialogue.h"

@interface DialogueTimoty: NSObject<IDialogue>
{
    ObjectBase* object;  // who are we talking with?
}

-(void) playDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player 
              object:(ObjectBase*)object;

-(void) stopDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player;

-(BOOL) getString:(unsigned int)index 
           string:(NSString**)string
     saidByPlayer:(BOOL*)saidByPlayer;

-(BOOL)         isEndStageAfterDialogue;
-(ObjectBase*)  getObject;
@end


// London
@interface Stage0: StageBase<IStage>
{
    BOOL            isGoal1Visible;
    DialogueTimoty* dial1;
}

// seconds
-(unsigned int) getTimeNeeded;
-(id<IStage>*)  getNextStage;

-(NSString*) getStageTitle;
-(NSString*) getBriefingText;
-(id)        getCurrentDialogue;
-(void)      goalIsVisible:(NSString*)objectName
                  distance:(CGFloat)distance
                    object:(id)object
          isVerticalVisible:(BOOL)isVerticalVisible;

-(int)                getStageTag;
-(void)               startStage;
-(BOOL)               isBackgroundDark;
@end
