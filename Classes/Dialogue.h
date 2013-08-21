#import "StageBase.h"
#import "Player.h"
#import "ObjectBase.h"

enum DialogueStage
{
    initialWait = 1,
    showPhrase,
    waitSomeTime,
    waitUserInput
};

struct DialogPhraseTuple
{
    BOOL        saidByPlayer;
    NSString*   str;
};

@protocol IDialogue<NSObject>

-(void) playDialogue:(StageBase<IStage>*)stage 
             player:(Player*)player 
             object:(ObjectBase*)object;

-(void) stopDialogue:(StageBase<IStage>*)stage 
              player:(Player*)player;

/// return NO to stop dialogue
-(BOOL) getString:(unsigned int)index 
           string:(NSString**)string
     saidByPlayer:(BOOL*)saidByPlayer;

-(BOOL)         isEndStageAfterDialogue;
-(ObjectBase*)  getObject;      // who are you talking with?

@end
