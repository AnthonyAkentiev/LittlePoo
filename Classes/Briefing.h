// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "StageBase.h"

@interface Briefing : CCLayer
{
    StageBase<IStage>* startThisStageAfterBriefing;
}

-(id)initWithStage:(StageBase<IStage>*)stage;

@end
