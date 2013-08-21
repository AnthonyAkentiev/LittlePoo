#import "cocos2d.h"
#import "StageBase.h"
#import "Snow.h"
#import "Dialogue.h"

// City
@interface Stage3: StageBase<IStage>
{
    BOOL       isGoal1Visible;
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
