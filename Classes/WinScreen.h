// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"


@interface WinScreen: CCLayer
{
}

/// \brief Called by us, instead of init method
/// \param failure Win or Loose?
-(void)	initialize:(BOOL)failure
      isNoTimeLeft:(BOOL)isNoTimeLeft;

@end