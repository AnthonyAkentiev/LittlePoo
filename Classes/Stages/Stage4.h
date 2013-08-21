#import "cocos2d.h"
#import "StageBase.h"
#import "Dialogue.h"
#import "Snow.h"

// City2
@interface Stage4: StageBase<IStage>
{
    BOOL isGoal1Visible;
    BOOL isGoal2Visible;
    
    //Snow*          snow;
}

-(void) dealloc;

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