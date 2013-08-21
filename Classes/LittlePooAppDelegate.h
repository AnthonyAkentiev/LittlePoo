#import <UIKit/UIKit.h>
#import "Game.h"

@class RootViewController;

@interface LittlePooAppDelegate : NSObject <UIApplicationDelegate> 
{
	UIWindow*           window;
	RootViewController* viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
