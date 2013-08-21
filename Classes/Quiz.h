#import "cocos2d.h"

@interface Quiz : CCLayer 
{
@private
    CCMenu* menu;
    
    int     correctAnswer_;
    BOOL    isShowStageSelect_;
}

-(id)init;

// BAD DESIGN but i don't care :-)
// Call this method if need to show stage selection after quiz
-(id)initIfStageSelect;

@end