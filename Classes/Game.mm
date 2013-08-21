// Import the interfaces
#import "Game.h"
#import "Helpers/SpriteEx.h"
#import "SpriteTags.h"
#import "Stage0.h"
#import "Stage5.h"
#import "Briefing.h"

#import "helpers.h"
#include "fonts.h"
#include "timings.h"
#include "movements.h"
#include "triggers.h"
#include "animations.h"
#include "WinScreen.h"
#include "stage_tags.h"

#import "CCParticleSystem.h"
#import "Dialogue.h"
#import "SimpleAudioEngine.h"

#import "Stage1.h"
#import "Stage2.h"
#import "Stage3.h"
#import "Stage4.h"
#import "Stage5.h"
#import "Stage6.h"

#define STAGE_LAYER_Z -1
#define CONTROL_LAYER_Z 1

// wait N seconds before counting down!
#define INITIAL_TIME_LEFT_VAL 146   // :-)) 146 % 

#define TIME_WAIT_SEC 4
#define SCORE_LABEL_SHOW_WAIT_SEC 1

// no difference in colors
#define DIALOGUE_LABEL_TEXT_COLOR ccc3(230,75,9)
#define DIALOGUE_LABEL_TEXT_COLOR_ALT ccc3(230,75,9)

#define DIAL_LABEL_SCREEN_OFFSET_X 20
#define DIAL_LABEL_SCREEN_OFFSET_Y 20
#define DIAL_CLOUD_INCREASE_SIZE_X 40
#define DIAL_CLOUD_INCREASE_SIZE_Y 40

// Marker Felt
#define DIALOGUE_TEXT_FONT @"Marker Felt"


@implementation Game

+(NSString*) getMusicFilePath
{
    //make path to file
     // This is for non-Jailbroken devices only!
     //
     NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString* filePath = [documentsPath stringByAppendingPathComponent:    
                           [NSString stringWithFormat:@"pu_music"]];
    
    //return @"/private/var/mobile/Applications/pu_music";
    return filePath;
}

+(NSString*) getStagesFilePath
{
    //make path to file
     // This is for non-Jailbroken devices only!
     //
     NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString* filePath = [documentsPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"pu_stages"]];
    
    // This is for jail-broken devices
    //return @"/private/var/mobile/Applications/pu_stages";
    return filePath;
}

+(BOOL) isSpecialMusicMode
{
    /*
    //read from the file
    NSError* err;
    NSString* string = [[NSString alloc] initWithContentsOfFile:[self getMusicFilePath]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&err];    
    NSLog(@"Opened music string: %@ from file %@",string,[self getMusicFilePath]);
    
    //scan the integers from the file
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    while([scanner isAtEnd]==NO)
    {
        NSInteger integer;
        [scanner scanInt:&integer];
        if(integer==1)
        {
            [scanner release];
            [string release];
            return YES;
        }
    }    
    
    [string release];
    [scanner release];
    return NO;
    */
    
    return YES; // always enabled in this version
}

+(void) enableSpecialMusicMode
{
    /*
    // write single char to file :-)
    //store them into file
    NSMutableString* mutstr = [[NSMutableString alloc] init];
    [mutstr appendFormat:@"1"];
    
    NSString* filePath = [Game getMusicFilePath];
    NSLog(@"Writing music %@ to file %@",mutstr,filePath);
    
    //write to file
    NSError* error;
    if(![mutstr writeToFile:filePath
                 atomically:YES
                   encoding:NSUTF8StringEncoding 
                      error:&error])
    {
        NSLog(@"err=%@",[error description]);        
    }
    
    [mutstr release];
    */
}

+(BOOL)            isFirstRun
{ 
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
    //read from the file
    NSError* err;
    NSString* string = [[NSString alloc] initWithContentsOfFile:[self getStagesFilePath]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&err];    
    NSLog(@"Opened stages string: %@ from file %@",string,[self getStagesFilePath]);
    
    //scan the integers from the file
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    while([scanner isAtEnd]==NO)
    {
        NSInteger integer;
        [scanner scanInt:&integer];
        NSLog(@"Opened stage: %d", integer);
        [arr addObject:[NSNumber numberWithInt:integer]];
    }    
    
    [scanner release];
    
    BOOL ret = ([arr count]<=1);
    [arr release];
    return ret;
}

+(NSMutableArray*) getOpenStagesArray
{
    NSMutableArray* arr = [[NSMutableArray alloc]init];

    //read from the file
    NSError* err;
    NSString* string = [[NSString alloc] initWithContentsOfFile:[self getStagesFilePath]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&err];    
    NSLog(@"Opened stages string: %@ from file %@",string,[self getStagesFilePath]);
    
    //scan the integers from the file
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    while([scanner isAtEnd]==NO)
    {
        NSInteger integer;
        [scanner scanInt:&integer];
        NSLog(@"Opened stage: %d", integer);
        [arr addObject:[NSNumber numberWithInt:integer]];
    }    
    
    [scanner release];
    
    if([arr count]==0)
    {
        // always enable first stage!
        Stage0* tmp = [Stage0 alloc];
        const int indexOfFirstStage = [tmp getStageTag];
        [tmp release];
        
        [arr addObject:[NSNumber numberWithInt:indexOfFirstStage]];
        [string release];
        return arr;
    }
    
    [string release];
    return arr;
}

struct StageTuple
{
    NSString* stageName;
    NSString* className;
};

// Playable stages.
// TODO: unite with array from StageSelect :-)
StageTuple stagesPlayable[] =
{
    {NSLocalizedString(@"Briefing0Name",@""),@"Stage0"},
    {NSLocalizedString(@"Briefing1Name",@""),@"Stage1"},
    {NSLocalizedString(@"Briefing2Name",@""),@"Stage2"},
    {NSLocalizedString(@"Briefing3Name",@""),@"Stage3"},
    {NSLocalizedString(@"Briefing4Name",@""),@"Stage4"},
    {NSLocalizedString(@"Briefing5Name",@""),@"Stage5"},
    {NSLocalizedString(@"Briefing6Name",@""),@"Stage6"},
};

+(int) getLastStageTag
{
    int lastOne = -1;
    
    NSMutableArray* opened = [Game getOpenStagesArray];
    
    for(size_t i=0; i<_countof(stagesPlayable); ++i)
    {       
        Class currentStage  = NSClassFromString(stagesPlayable[i].className);
        StageBase<IStage>* tmp = [currentStage alloc];
        int tag = [tmp getStageTag];
        [tmp release];
        
        if(![Game isPresentStage:opened
                       stageTag:tag] && i!=0)
        {
            break;
        }
        
        lastOne = tag;
    }
    
    [opened release];
    
    NSAssert(lastOne!=-1,@"First stage should be always available!");
    
    if(lastOne>STAGE6_TAG)  // TODO: tags (STAGE0_TAG...STAGE6_TAG) are spread all over the code
        lastOne=STAGE6_TAG;
    
    return lastOne;
}

+(StageBase<IStage>*) getStageByTag:(int)tagIn
{
    for(size_t i=0; i<_countof(stagesPlayable); ++i)
    {
        Class currentStage  = NSClassFromString(stagesPlayable[i].className);
        StageBase<IStage>* tmp = [currentStage alloc];
        const int tag = [tmp getStageTag];
        
        if(tag==tagIn)
        {
            return tmp;            
        }else
            [tmp release];
    }

    NSAssert(false,@"Stage not found!");
    return nil;
}

+(BOOL) isPresentStage:(NSMutableArray*)openedStages
              stageTag:(int)stageTag
{
#ifdef UNLOCK_ALL_STAGES
    return YES;
#endif 
    
    for(id obj in openedStages)
    {
        NSNumber* num = (NSNumber*)obj;
        int x = [num intValue];
        if(x==stageTag)
            return YES;
    }
    return NO;
}

+(void) enableAllStages
{
    //store them into file
    NSMutableString* mutstr = [[NSMutableString alloc] init];
    NSMutableArray*  openedStagesLocal = [[NSMutableArray alloc]init ];
    
    // add to array index of this stage
    // FUNNY shit-code :-)) i don't care!
    for(int i=STAGE0_TAG; i<=STAGE6_TAG; ++i)
        [openedStagesLocal addObject:[NSNumber numberWithInt:i]];
    
    // get items from openedStages array
    for(id obj in openedStagesLocal)
    {
        NSNumber* num = (NSNumber*)obj;
        [mutstr appendFormat:@"%i\n",[num intValue]];
    }
    
    NSString* filePath = [Game getStagesFilePath];
    NSLog(@"Writing opened stages %@ to file %@",mutstr,filePath);
    
    //write to file
    NSError* error;
    if(![mutstr writeToFile:filePath
                 atomically:YES
                   encoding:NSUTF8StringEncoding 
                      error:&error])
    {
        NSLog(@"err=%@",[error description]);        
    }
    
    [openedStagesLocal release];
    [mutstr release];
}


-(void) saveOpenStagesArray
{
    //store them into file
    NSMutableString* mutstr = [[NSMutableString alloc] init];
    
    // get items from openedStages array
    for(id obj in openedStages)
    {
        NSNumber* num = (NSNumber*)obj;
        [mutstr appendFormat:@"%i\n",[num intValue]];
    }
    
    NSString* filePath = [Game getStagesFilePath];
    NSLog(@"Writing opened stages %@ to file %@",mutstr,filePath);
    
    //write to file
    NSError* error;
    if(![mutstr writeToFile:filePath
             atomically:YES
               encoding:NSUTF8StringEncoding 
                  error:&error])
    {
        NSLog(@"err=%@",[error description]);        
    }
    
    [mutstr release];
}

-(void)setStageIsOpened:(StageBase<IStage>*)stage
{
    // add to array index of this stage
    const int index = [stage getStageTag];
    [openedStages addObject:[NSNumber numberWithInt:index]];
}

-(StageBase<IStage>*) getCurrentStage
{
    return currentStage;
}

-(void) nextStage
{
    if(nextStageTriggered)
        return;
    
    nextStageTriggered = YES; 
    
    [self saveOpenStagesArray];
    
    StageBase<IStage>* nextStage = (StageBase<IStage>*)[currentStage getNextStage];      

    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    CCScene* nextScene;
    if(nil==nextStage)
    {
        // game over!!!
        WinScreen* sc = [WinScreen node];
        [sc initialize:NO 
            isNoTimeLeft:NO];    // success!
        nextScene = (CCScene*) sc;
    }else
    {
        Briefing* br = [[[Briefing alloc] initWithStage:nextStage]autorelease];
        nextScene = (CCScene*) br;
        
        [self setStageIsOpened:nextStage];
    }
    
    [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION
                                              scene:nextScene]];
}

-(void) gameOver:(BOOL)isNoTimeLeft
{
#ifdef TEST_STAGE_MODE
    return;
#endif
    [self saveOpenStagesArray];
    
    // end game!
    WinScreen* sc = [WinScreen node];
    [sc initialize:YES 
        isNoTimeLeft:isNoTimeLeft];    // failure
    
    [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:DEATH_TRANSITION_DURATION 
                                        scene:(CCScene*)sc]];
}

-(unsigned int) timeLeft
{   
    // 146 % is initial (maximum) value, then time goes down!
    float percentsElapsed  = 
    ([player getTimeElapsed]-TIME_WAIT_SEC) / (float)timeNeededForCurrentStage;
    
    percentsElapsed = percentsElapsed * (float)INITIAL_TIME_LEFT_VAL;
    
    int percentLeft = INITIAL_TIME_LEFT_VAL - (int)percentsElapsed;
    if(percentLeft<0)
        percentLeft=0;
        
    return (unsigned int) percentLeft;
}

-(void) updateStatsTimer: (ccTime) delta
{    
    if(stopTimeTicking)
        return;
    
    muteLastPressed-=delta;
    
    [player setTimeElapsed:[player getTimeElapsed]+1];
    
    if([player getTimeElapsed]<TIME_WAIT_SEC)
    {
        [controlLayer updateTimeLeft:INITIAL_TIME_LEFT_VAL];
        return;
    }
    
    // Wait several seconds...
    if([player getTimeElapsed]>=SCORE_LABEL_SHOW_WAIT_SEC)
    {
        [controlLayer updateScore:[player getScore]];
    }
    
    const unsigned int leftTime = [self timeLeft];
    
#ifndef DONT_COUNT_TIME
    if(leftTime<=0 && !gameOverTrigger)
    {
        gameOverTrigger = YES;
        [self gameOver:YES];
    }
#endif
    [controlLayer updateTimeLeft:leftTime];
}


-(id) initWithStage:(StageBase<IStage>*)stage
{
    if(self=[super init])
    {                     
        // Init stuff
        gameOverTrigger            = NO;    
        nextStageTriggered         = NO;
        currentDialoguePhraseIndex = 0;
        currentDialogueState       = initialWait;
        playingDialogue            = NO;
        waitTimeElapsed            = 0;
        dialogueLabel              = nil;
        cloudSprite                = nil;
        
        muteLastPressed            = 0;
        
        objsJump = [[NSMutableArray alloc]init];
        collectedObjects = [[NSMutableArray alloc]init];
        
        // own stage!
        currentStage = [stage retain];
        
        controlLayer = [LayerControl node];
                
        [controlLayer initWithGame:self 
               alternativeHudColor:[currentStage isBackgroundDark]];

        
        [self addChild:currentStage z:STAGE_LAYER_Z];
        // current layer is z:0
        [self addChild:controlLayer z:CONTROL_LAYER_Z];
        
        player = [Player alloc];
		[player initWithWorld:currentStage];
        [currentStage setPlayer:(id)player];
        
#ifdef TEST_STAGE_MODE
        //[player goToEnd];
#endif
        
        // seconds:
        stopTimeTicking           = NO;
        timeNeededForCurrentStage = [currentStage getTimeNeeded];        
        
        // Camera
        currentCameraPosition  = ccp(0,0);
        wantedMovePoint        = ccp(0,0);
        
        [self scheduleUpdateWithPriority:0];
        
		//[self schedule: @selector(step:)  interval: 1.0 / 60.0f ]; 
        [self schedule: @selector(updateStatsTimer:) interval: 1.0f];
        
        // read from file
        openedStages = [Game getOpenStagesArray];  
        [self saveOpenStagesArray];
    }
    return self;
}

-(void)dealloc
{
    [self saveOpenStagesArray];
    [openedStages release];
    
    [objsJump release];
    [collectedObjects release];
    [currentStage release];
    [player release];
}

-(BOOL) isTouchingObject:(ObjectBase**)objTouched
               arr:(NSMutableArray*)arr
{       
    CGRect currPlayerRect = [player getCurrentPositionWorld];
    
    // iterate
    for( ObjectBase* obj in arr )
    {
        CGRect enemyRect = [obj getCurrentPositionWorld];
        
        const CGFloat collisionRectWidth = ENEMY_COLLISION_RECT_WIDTH;
        if(enemyRect.size.width>collisionRectWidth)
        {
            // loosen collision
            CGFloat widthPrev = enemyRect.size.width/2;  
            
            enemyRect.origin.x= enemyRect.origin.x + widthPrev/2 - (collisionRectWidth/2);
            enemyRect.size.width=collisionRectWidth;
        }
        
        if(CGRectIntersectsRect(currPlayerRect,enemyRect))
        {
            *objTouched = obj;
            return YES;
        }
    }
    return NO;
}

- (void) collectObject:(CollectableObject*)object
{
    CGPoint pos;    
    if([object isScoreModifier])
    {
        pos = [controlLayer getScorePos];
        [controlLayer blinkScore];
    }else
    {
        pos = [controlLayer getTimePos];
        [controlLayer blinkTime];
    }
    
    // start moving 
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:COLLECT_OBJECT_MOVE_TIME 
                                           position:pos];
    
    CCFadeTo* escapeToVoid   = [CCFadeTo actionWithDuration:0.5];

    
    [collectedObjects addObject:object];
    [currentStage removeObject:object];
    
    [object runAction: 
     [CCSequence actions:moveTo,escapeToVoid/*,removeObject*/,nil]
    ];
}


-(void) touchStep:(ccTime)delta
{
    // check if collide with enemy
    MovingObject* enemyTouched = nil;
    if(![player isStillTouching])
    {
        if([self isTouchingObject:&enemyTouched 
                             arr:[currentStage getEnemies]] && enemyTouched)
        {       
            [player touchedEnemy:enemyTouched];        
            [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.mp3" pitch:0.8f 
                                                     pan:0.0f 
                                                    gain:0.1f];        
        }
    }
    
    ObjectBase* objectTouched = nil;    
    if([self isTouchingObject:&objectTouched 
                          arr:[currentStage getObjects]] && objectTouched)
    {
        Class c = NSClassFromString(@"CollectableObject");
        if([objectTouched isKindOfClass:c])
        {
            [objectTouched playerTouched:player];
            [self collectObject:(CollectableObject*)objectTouched];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"get.mp3" pitch:0.8f 
                                                     pan:0.0f 
                                                    gain:0.1f];
        }
    }
}

-(void) update: (ccTime) delta
{       
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        [self playDialogue:delta];
    }
    
#ifdef DO_FOLLOW_PLAYER_CAMERA_Y
    if(!dialogueIsRunningNow)
        [self followCamera:delta];
#endif
    
    [controlLayer updateHitPoints:[player getHitPoints]];
        
    if([self isReachedGoal])
    {
        [self nextStage];
    }
    
    if([player isDead])
    {
        [self gameOver:NO];
        return;
    }
    
    [self touchStep:delta];     
    
    [player       step:delta];
    [currentStage step:delta];
}

-(void) drawRect:(CGRect)rect
{
    const CGPoint vertices[] = 
    { 
        ccp(rect.origin.x,rect.origin.y),
        ccp(rect.origin.x,rect.origin.y + rect.size.height),
        ccp(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height),
        ccp(rect.origin.x + rect.size.width,rect.origin.y),
    };    
    
    ccDrawPoly(vertices, _countof(vertices), YES);
}

-(void) draw
{
    // DRAW
#ifdef DRAW_PHYSICS_OBJS
    // Draw player jump rect
    // screen coords...
    CGRect rectPlayerPos = [player getLeftAnchorPosRect];
    
    glEnable(GL_LINE_SMOOTH);
    glColor4ub(255, 0, 255, 255);
    glLineWidth(2);
    
    // determine objects that we'd cross if we would jump now.
    CGRect playerWorldCoords = [currentStage toWorldCoords:rectPlayerPos];
        
    [objsJump removeAllObjects];
    const CGFloat jumpHeight = [currentStage getNearestObjectTop:playerWorldCoords
                                                          wantedHeight:JUMP_AMOUNT_Y
                                                   objectsIntersecting:objsJump];
    
    rectPlayerPos.size.height+=jumpHeight;
    [self drawRect:rectPlayerPos];    
    
    if(![player isFallingDown])
    {
        // draw player single jump rect
        CGRect singleJumpRectWorld = [player getJumpDiagonalRect:YES];
        if([currentStage toScreenCoords:&singleJumpRectWorld])
        {
            [self drawRect:singleJumpRectWorld];
        } 
        
        // draw player single jump rect
        CGRect singleJumpRectWorldLeft = [player getJumpDiagonalRect:NO];
        if([currentStage toScreenCoords:&singleJumpRectWorldLeft])
        {
            [self drawRect:singleJumpRectWorldLeft];
        }
    }else
    {
        // draw player single jump rect
        CGRect singleFallRectWorld = [player getFallDiagonalRect:YES];
        if([currentStage toScreenCoords:&singleFallRectWorld])
        {
            [self drawRect:singleFallRectWorld];
        } 
        
        // draw player single jump rect
        CGRect singleFallRectWorldLeft = [player getFallDiagonalRect:NO];
        if([currentStage toScreenCoords:&singleFallRectWorldLeft])
        {
            [self drawRect:singleFallRectWorldLeft];
        }

    }
    
    // draw TARGET rect
    glColor4f(255, 255, 0, 255);
    for(MovingObject* object in [currentStage getEnemies])
    {
        if([object isAiControlled])
        {
            CGRect rectTarget;
            const int patrol = [object getPatrolAction:&rectTarget];
            if(patrol)
            {
                [currentStage toScreenCoords:&rectTarget];
                [self drawRect:rectTarget];
            }
            
            const int fly = [object getFlyAction:&rectTarget];
            if(fly)
            {
                [currentStage toScreenCoords:&rectTarget];
                [self drawRect:rectTarget];
            }
        }
    }
#endif
}

-(void) attackButton
{
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    
#ifdef _DEBUG
    [self moveCamera:ccp(0,50)];
#endif    
}

-(void) weaponButton
{
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
}

-(void) moveObject:(CGFloat)amount
{
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    
    [player moveObject:amount];
}

/*
-(void)moveWorld:(CGFloat)amount
{     
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    [currentStage moveWorld:LRINT(amount)];
}*/

-(void) leftButton:(ccTime)delta
{   
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    [player doLeft];
}

-(void) rightButton:(ccTime)delta
{  
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    [player doRight];
}

-(void) jumpButton:(BOOL)leftButton 
       rightButton:(BOOL)rightButton
             delta:(ccTime)delta
{    
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow)
    {
        return;
    }
    [player doJump];
}

-(void) screenIsTouched
{
    const BOOL dialogueIsRunningNow = [player isDialogueMode];
    if(dialogueIsRunningNow && currentDialogueState==waitUserInput)
    {
        [self continueDialogue];
        return;
    }
}

-(void) alertView:(UIAlertView *)alertView 
        didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    [controlLayer disableControls:NO];
	[[CCDirector sharedDirector]resume];    
}

-(void) pauseButton
{
    if([CCDirector sharedDirector].isPaused)
    {
       [[CCDirector sharedDirector]resume]; 
    }else
    {
        [controlLayer disableControls:YES];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pause",@"") 
                                                message:NSLocalizedString(@"PauseMessage", @"")
                                                delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Resume",@"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[CCDirector sharedDirector]pause];        
    }
}

-(void) muteButton
{
    // invert
    if(muteLastPressed<=0)
    {
        muteLastPressed = 1;        
        const BOOL wasMute = [[SimpleAudioEngine sharedEngine]mute];
        [[SimpleAudioEngine sharedEngine]setMute:!wasMute];
    }
}

// positive - move camera up!
-(void) moveCamera:(CGPoint)diff
{   
    if([currentStage moveLayerDirectX:LRINT(-diff.x)])
    {
        [player moveSpriteDirectX:LRINT(-diff.x)];
    }
    
    //const CGRect rectCurr = [player getCurrentPositionWorld];
    //const CGFloat untilNextFloor = [currentStage getDiffGround:rectCurr];
    //if(untilNextFloor>=30)
    
    //const CGFloat beforeMoveCamera = [player getCurrentPositionWorld].origin.y;
    {
        if([currentStage moveLayerDirectY:LRINT(-diff.y)])
        {
            [player moveSpriteDirectY:LRINT(-diff.y)];
        }
    }

    //const CGFloat afterMoveCamera = [player getCurrentPositionWorld].origin.y;
    //NSLog( @"curr move diff: %f; playerPos: %f; moving player=%d; before=%f; after=%f", 
    //      diff.y, [player getCurrentPositionWorld].origin.y, movedPlayer,
    //      beforeMoveCamera, afterMoveCamera);
}

-(void) moveCameraToPoint:(CGFloat)pntX
{
    // get current middle screen point (in world coords)
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    screen = [currentStage toWorldCoords:screen];
    
    const CGFloat diff = pntX - (screen.origin.x + screen.size.width/2);
    NSLog(@"Move camera because dialogue is started: %f",diff);
    [self moveCamera:ccp(diff,0)];
}

// following only up and down!
-(void) followCamera:(ccTime) delta
{       
    // get the player diff from the center of screen
    CGSize  screenSize = [[CCDirector sharedDirector] winSize];
    CGPoint playerPos = [player getCenterPos];
    
    // positive -> jumping up
    // negative -> falling down
    CGFloat diff = playerPos.y - screenSize.height/2;
    
    // calculate speed according to diff
    // more diff -> more speed of camera moving back!
    //const CGFloat pixelsPerSecond = ((CAMERA_MOVEMENT_SPEED_Y) / ( screenSize.height / 2));
    
    const CGFloat pixelsPerSecond = CAMERA_MOVEMENT_SPEED_Y;
    CGFloat moveCamera = pixelsPerSecond * delta * (diff>0.0?1.0:-1.0);
    
    //NSLog(@"diff=%f; delta=%f; moveCamera=%f; playerPos.y=%f",
    //      diff,delta,moveCamera,playerPos.y);
    
    if(abs(diff)>3.0f && !IS_NEAR(moveCamera, 0.0))
    {        
        if(abs(moveCamera)>abs(diff))
        {
            // truncate
            moveCamera = diff;
        }
        [self moveCamera:ccp(0,moveCamera)];        
    }
}

-(BOOL) isReachedGoal
{
    if([currentStage isIntersection:[player getCurrentPositionWorld] 
                               obj2:[currentStage getGoalObjPos]])
        return YES;    
    return NO;
}

-(CGSize) getLabelSize:(NSString*)strPhrase
           constrained:(CGSize)constrained
{
    NSAssert([strPhrase length],@"Bad phrase!");
    
    CGSize actualSize = [strPhrase sizeWithFont:[UIFont fontWithName:DIALOGUE_TEXT_FONT
                                                                size:RESIZE_FONT(DIALOGUE_TEXT_SIZE)]
                              constrainedToSize:constrained
                                  lineBreakMode:UILineBreakModeMiddleTruncation];
    return actualSize;
}

- (CGSize) getMaximumLabelSize:(NSObject<IDialogue>*)dialogue 
                  saidByPlayer:(BOOL)saidByPlayer
{
    CGSize sizeBiggest;
    sizeBiggest.width = 0;
    sizeBiggest.height= 0;
    
    // iterate all phrases and calculate biggest Cloud size!
    int phraseIndex = 0;
    
    // we use this one as initial size!
    CGSize rectConstrained;
    const CGSize screen = [[CCDirector sharedDirector] winSize];
    rectConstrained.width = screen.width/2;
    rectConstrained.height= screen.height/2;
    
    while(true)
    {
        BOOL isThisPhraseIsSaidByPlayer = YES;
        NSString* strPhrase             = nil;
        
        if(![dialogue getString:phraseIndex
                         string:&strPhrase 
                   saidByPlayer:&isThisPhraseIsSaidByPlayer])
        {
            break;      // stop
        }    
        
        if(isThisPhraseIsSaidByPlayer==saidByPlayer)
        {
            const CGSize actualSize = [self getLabelSize:strPhrase 
                                             constrained:rectConstrained];
            
            // area
            const CGFloat areaBiggest = sizeBiggest.width* sizeBiggest.height;
            const CGFloat areaCurrent = actualSize.width * actualSize.height;
            
            if(areaCurrent>areaBiggest)
                sizeBiggest = actualSize;
        }
        
        ++phraseIndex;  // continued
    }
    
    return sizeBiggest;
}


-(void) showPhrase:(NSString*)strPhrase
          dialogue:(NSObject<IDialogue>*)dialogue 
      saidByPlayer:(BOOL)saidByPlayer
          opponent:(ObjectBase*)opponent
{
    CGRect rect;
    if(saidByPlayer)
    {
        rect = [player getCurrentPositionWorld];
    }else
    {
        rect = [opponent getCurrentPositionWorld];
    }
        
    // 0 - Get Size
    CGSize rectConstrained;
    const CGSize screen = [[CCDirector sharedDirector] winSize];
    rectConstrained.width = screen.width/2;
    rectConstrained.height= screen.height/2;
    const CGSize cloudSize = [self getLabelSize:strPhrase 
                                    constrained:rectConstrained];
    
    // 1 - show label
    [self removeChild:dialogueLabel
              cleanup:YES];
    [self removeChild:cloudSprite
              cleanup:YES];
    
    dialogueLabel = [CCLabelTTF labelWithString:strPhrase
                                         dimensions:cloudSize
                                          alignment:UITextAlignmentCenter
                                      lineBreakMode:UILineBreakModeMiddleTruncation 
                                           fontName:DIALOGUE_TEXT_FONT 
                                           fontSize:RESIZE_FONT(DIALOGUE_TEXT_SIZE)];
    
    if([currentStage isBackgroundDark])
        dialogueLabel.color = DIALOGUE_LABEL_TEXT_COLOR_ALT;
    else
        dialogueLabel.color = DIALOGUE_LABEL_TEXT_COLOR;

    
    NSAssert([player getCurrentPositionWorld].origin.x<[opponent getCurrentPositionWorld].origin.x,
             @"The position of enemy is wrong!");
    
    // 2 - position label
    const CGFloat yPos = CGRectGetMaxY(rect) + (cloudSize.height/2) + RESIZE_X(20);
    NSAssert(yPos + cloudSize.height/2 < screen.height,@"The label is too big!");
    
    CGPoint pntPos;
    if(saidByPlayer)
    {
        CGRect rectScreen = rect;
        [currentStage toScreenCoords:&rectScreen];        
    
        if(rectScreen.origin.x<cloudSize.width/2 + RESIZE_X(DIAL_LABEL_SCREEN_OFFSET_X))
            rectScreen.origin.x = (cloudSize.width/2 + RESIZE_X(DIAL_LABEL_SCREEN_OFFSET_Y));
        
        pntPos = ccp( rectScreen.origin.x + (rectScreen.size.width/2), yPos );
    }else
    {
        CGRect rectScreen = [opponent getCurrentPositionWorld];
        [currentStage toScreenCoords:&rectScreen];        
        pntPos =  ccp( rectScreen.origin.x, yPos );
    }
    
    dialogueLabel.position = pntPos;
    
    [self addChild:dialogueLabel];
    
    // 3 - play talk animation!
    if(saidByPlayer)
    {
        [player playTalkAnimation];
    }else
    {
        MovingObject* mo = (MovingObject*)opponent;
        [mo playTalkAnimation];
    }
}

- (void) startingDialogEvent:(NSObject<IDialogue>*)dialogue
{
    // first time
    // get the middle point between player and object!
    CGFloat playerMaxX = CGRectGetMaxX([player getCurrentPositionWorld]);
    CGFloat objectMinX = CGRectGetMinX([[dialogue getObject]getCurrentPositionWorld]);
    CGFloat middlePlayerAndObject = (objectMinX + playerMaxX)/2;
    
    [player stopMoving];
    [self moveCameraToPoint:middlePlayerAndObject];
    [currentStage stopMoving];
    
    // start Fade
    id actionFadeIn = [CCFadeIn actionWithDuration:DIALOGUE_FADE_IN_TIMING];
    [currentStage runAction:[CCSequence actions:actionFadeIn, nil]];
    
    // stop time
    stopTimeTicking = YES;
    
    // rotate player
    [player setLookRight];
    
    // darken background
    [currentStage darkenBackground]; 
    
    [controlLayer showLabels:NO];
    [controlLayer dialogueMode:YES];
}

- (void) stopDialogueEvent:(NSObject<IDialogue>*)dialogue
{
    stopTimeTicking = NO;
        
    currentDialogueState = initialWait;
    [dialogue stopDialogue:currentStage 
                    player:player];
    
    playingDialogue = NO;
    [self removeChild:dialogueLabel
              cleanup:YES];
    [self removeChild:cloudSprite
              cleanup:YES];
    
    if([dialogue isEndStageAfterDialogue])
        [self nextStage];
    
    [controlLayer showLabels:YES];
    [controlLayer showJumpButton:YES];
    [controlLayer dialogueMode:NO];
}

// SIMPLE STATE MACHINE:
-(void)showDialoguePhrase:(NSObject<IDialogue>*)dialogue 
                    delta:(ccTime)delta
{
    //NSLog(@"showDialoguePhrase");
    
    [controlLayer showJumpButton:NO];
    
    NSString* strPhrase = nil;
    BOOL saidByPlayer   = YES;
    
    if(![dialogue getString:currentDialoguePhraseIndex
                      string:&strPhrase 
                 saidByPlayer:&saidByPlayer])
    {
        // end dialogue!
        [self stopDialogueEvent:dialogue];
        return;
    }    
    
    // show player string first!
    if(strPhrase && [strPhrase length])
    {
        [self showPhrase:strPhrase 
                dialogue:dialogue
            saidByPlayer:saidByPlayer
                opponent:[dialogue getObject]
         ];
    }
    
    // move next stage!
    currentDialogueState    = waitSomeTime;
    ++currentDialoguePhraseIndex;       // select next phrase!
}
      
-(void)waitDialogueTimeInitial:(NSObject<IDialogue>*)dialogue 
                         delta:(ccTime)delta
{
    //NSLog(@"waitDialogueTime");
    
    // do not touch it!
    [controlLayer showJumpButton:NO];
    
    // move next state!
    waitTimeElapsed+=delta;
    if(waitTimeElapsed>INITIAL_DIALOGUE_WAIT_TIME)
    {
        waitTimeElapsed      = 0;
        currentDialogueState = showPhrase;
    }
}

-(void)waitDialogueTime:(NSObject<IDialogue>*)dialogue 
                    delta:(ccTime)delta
{
    //NSLog(@"waitDialogueTime");
    
    // move next state!
    waitTimeElapsed+=delta;
    if(waitTimeElapsed>SHOW_DIALOGUE_PHRASE_TIME)
    {
        waitTimeElapsed      = 0;
        currentDialogueState = waitUserInput;
        
        // let user touch it!
        [controlLayer showJumpButton:YES];
    }
}

-(void)waitDialogueInput:(NSObject<IDialogue>*)dialogue 
                    delta:(ccTime)delta
{

    
}

-(void) continueDialogue
{
    if(waitUserInput==currentDialogueState)
    {
        //NSLog(@"Got user input, continuing dialog");
        currentDialogueState = showPhrase;
    }
}

- (void) playDialogue:(ccTime)delta
{
    NSAssert([player isDialogueMode],@"Not in dialogue mode!");
    
    NSObject<IDialogue>* dialogue = (NSObject<IDialogue>*)[currentStage getCurrentDialogue];
    if(nil==dialogue)
        return;
    
    // Dialogue just started? 
    if(!playingDialogue)
    {
        [self startingDialogEvent:dialogue];
        playingDialogue = YES;
    }
    
    // currentDialoguePhraseIndex
    switch(currentDialogueState)
    {
        case initialWait:
            [self waitDialogueTimeInitial:dialogue delta:delta];
            break;
        case showPhrase:
            [self showDialoguePhrase:dialogue delta:delta];
            break;
        case waitSomeTime:
            [self waitDialogueTime:dialogue delta:delta];
            break;
        case waitUserInput:
            [self waitDialogueInput:dialogue delta:delta];
            break;
    }    
}

@end


