#import "cocos2d.h"
#import "StageBase.h"

// Underground
@interface Stage5 : StageBase<IStage>
{
    BOOL isGoal1Visible;
}

-(id<IStage>*)  getNextStage;

-(NSString*)    getStageTitle;
-(NSString *)   getBriefingText;
-(void)         goalIsVisible:(NSString*)objectName
                     distance:(CGFloat)distance
                       object:(id)object
             isVerticalVisible:(BOOL)isVerticalVisible;

-(id)        getCurrentDialogue;

-(int)       getStageTag;
-(void)      startStage;
-(BOOL)      isBackgroundDark;
@end
