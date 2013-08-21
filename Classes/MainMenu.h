// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface MainMenu: CCLayer
{
	CCMenu* menu;
	CCMenu* menu2;
    
    unsigned int currentRunningStringIndex;
    unsigned int multiStringIndex;
    
    //CCLabelTTF*     label;
    NSMutableArray* labelsNotShown;
    
    time_t          touchBegin; 
    int             touchCounter;
    
    // "cache" 
    BOOL            specialMusicModeUpdated;
    BOOL            specialMusicMode;
}

-(void) menuCallbackStartNew:(id) sender;
-(void) menuCallbackDisclaimer:(id) sender;
-(void) menuCallbackContinue:(id) sender;
-(void) menuCallbackQuit:(id) sender;

-(void) showLabel;

@end