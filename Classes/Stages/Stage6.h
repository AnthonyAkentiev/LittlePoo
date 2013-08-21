#import "cocos2d.h"
#import "StageBase.h"
#import "Dialogue.h"
#import "ObjectBase.h"

@interface DialogueNavalny: NSObject<IDialogue>
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


// Underground2
@interface Stage6: StageBase<IStage>
{
    BOOL             isGoal1Visible;
    DialogueNavalny* dial1;
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