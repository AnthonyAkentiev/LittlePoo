#import "ControlLayer.h"
#import "SpriteEx.h"
#import "Game.h"
#import "Button.h"

#include "helpers.h"
#include "buttons.h"
#include "SpriteTags.h"
#include "timings.h"
#include "triggers.h"
#include "fonts.h"

@implementation LayerControl

#define BUTTON_Z        10
#define SCORE_LABLE_Z   10
#define TIMELEFT_LABLE_Z 10
#define HITPOINT_Z 10

#define ACTION_TIME_BLINK 1

#define LOW_TIME_THRESHOLD 35

#define TIMELEFT_LABEL_COLOR    ccc3(50,128,30)
#define SCORE_LABEL_COLOR       ccc3(255,0,0) 

#define TIMELEFT_LABEL_COLOR_ALT ccc3(255,255,255)
#define SCORE_LABEL_COLOR_ALT    ccc3(255,0,0) 

-(void) initWithGame:(Game*)g
    alternativeHudColor:(BOOL)alternativeHudColor
{
    // init stuff
    game            = g;  
    disableControls = NO;
    dialogueMode    = NO;
    showJumpButton  = YES;
    alternativeColor = alternativeHudColor;
}

-(void) disableControls:(BOOL) disable
{
    disableControls = disable;
    if(disableControls)
    {
        // workaround for bug when pressing Pause
        [leftButton depress];
        [rightButton depress];
        [jumpButton depress];
        
        [muteButton depress];
        [pauseButton depress];
    }
}

-(void) update: (ccTime) delta
{
    if(disableControls)
        return;
        
    if([jumpButton isPressed])
    {
        // jump priority is very high!
        [game jumpButton:[leftButton isPressed] 
             rightButton:[rightButton isPressed]
                   delta:delta
        ];
        
#ifdef _DEBUG
        // DEBUG only!!!
        //[game rightButton:delta];
#endif
        // "notify" :-)
        if(dialogueMode)
            [game screenIsTouched];
    }
    
    if([rightButton isPressed])
    {
        [game rightButton:delta];
    }else if([leftButton isPressed])
    {
        [game leftButton:delta];
    }

    if([attackButton isPressed])
    {
        [game attackButton];
    }
    if([weaponChangeButton isPressed])
    {
        [game weaponButton];
    }
         
    // additional buttons
    if([muteButton isPressed])
    {
        [game muteButton];
    }
    if([pauseButton isPressed])
    {
        [game pauseButton];
    }
}

-(BOOL) jumpButton
{
    return [jumpButton isPressed];
}

-(BOOL) attackButton
{
    return [attackButton isPressed];
}

-(BOOL) weaponButton
{
    return [weaponChangeButton isPressed];
}

-(BOOL) leftButton
{
    return [leftButton isPressed];
}

-(BOOL) rightButton
{
    return [rightButton isPressed];
}

-(BOOL) pauseButton
{
    return [muteButton isPressed];
}

-(BOOL) muteButton
{
    return [muteButton isPressed];
}

-(void) showLabels:(BOOL)show
{
    const CGFloat opacity = (show?255:0);
    
    [labelTimeLeft setOpacity:opacity];
    [labelScore setOpacity:opacity];
    
    for(int i=0; i<[hitPointsControls count]; ++i)
    {
        CCSpriteEx* sprite = [hitPointsControls objectAtIndex:i];
        [sprite setOpacity:opacity];
    }
}

-(void) dialogueMode:(BOOL)dm
{
    const CGFloat opacity = (dm?0:255);
    
    [leftButton setOpacity:opacity];
    [rightButton setOpacity:opacity];
    [weaponChangeButton setOpacity:opacity];
    [attackButton setOpacity:opacity]; 
    
    [muteButton setOpacity:opacity];
    [pauseButton setOpacity:opacity];
    
    dialogueMode = dm;
}

-(void) showJumpButton:(BOOL)show
{
    showJumpButton = show;
    
    const CGFloat opacity = (show?255:0);
    [jumpButton setOpacity:opacity];
}

-(void) addButton:(ButtonControl*)button 
             posX:(CGFloat)posX 
           tagVal:(int)tagVal;
{   
    //spr.opacity = 0.0f;
    [button makeEnabled];
    const CGSize screen = [[CCDirector sharedDirector] winSize];
    
    if( screen.width>=1024 || screen.height>=1024 )
    {
        button.position = ccp(posX, RESIZE_Y_RAW(BUTTONS_Y_OFFSET_IPAD) + RESIZE_Y_RAW(BUTTON_HEIGHT_IPAD)/2 );
        [button setWidth:RESIZE_X_RAW(BUTTON_WIDTH_IPAD)];
        [button setHeight:RESIZE_Y_RAW(BUTTON_HEIGHT_IPAD)];
    }else
    {
        button.position = ccp(posX, RESIZE_Y_RAW(BUTTONS_Y_OFFSET) + RESIZE_Y_RAW(BUTTON_HEIGHT)/2);
        [button setWidth:RESIZE_X_RAW(BUTTON_WIDTH)];
        [button setHeight:RESIZE_Y_RAW(BUTTON_HEIGHT)];
    }
    [self addChild:button z:BUTTON_Z tag:tagVal];
}

-(CCTexture2D*) createLabel:(NSString*)text
                   textSize:(CGFloat)textSize
                   fontName:(NSString*)fontName
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    // get needed size
    CGSize actualSize = [text sizeWithFont:[UIFont fontWithName:fontName
                                                           size:textSize]
                                            constrainedToSize:screen
                             lineBreakMode:UILineBreakModeMiddleTruncation];
    
    glColor4f(1.0,0.0,0.0,1.0f);
    CCTexture2D* label = [[CCTexture2D alloc] initWithString:text
                                                  dimensions:actualSize
                                                   alignment:UITextAlignmentCenter 
                                                    fontName:fontName 
                                                    fontSize:textSize];
    
    return label;
}

-(void) addAdditionalButton:
                (ButtonControl*)button
                posX:(CGFloat)posX
		   tagVal:(int)tagVal
{
    [button makeEnabled];
    
    const CGSize screen = [[CCDirector sharedDirector] winSize];

	button.position = ccp(posX, screen.height - RESIZE_Y_RAW(PAUSE_BUTTON_Y_OFFSET));
	
    [button setWidth:RESIZE_X_RAW(PAUSE_BUTTON_WIDTH)];
	[button setHeight:RESIZE_Y_RAW(PAUSE_BUTTON_HEIGHT)];

	[self addChild:button z:BUTTON_Z tag:tagVal];
}

-(void) addButtons
{	
	// add as sprites, but hide them in case of Release.
	const CGSize screen = [[CCDirector sharedDirector] winSize];
	
    // init all buttons
    CCTexture2D* textureNormal  = [[CCTextureCache sharedTextureCache] addImage:@"left.png"];
    CCTexture2D* textureNormal2  = [[CCTextureCache sharedTextureCache] addImage:@"right.png"];    
    CCTexture2D* textureNormal3  = [[CCTextureCache sharedTextureCache] addImage:@"action_red.png"];
    
    leftButton          = [ButtonControl buttonWithTextures:textureNormal litTexture:textureNormal];
    rightButton         = [ButtonControl buttonWithTextures:textureNormal2 litTexture:textureNormal2];
    jumpButton          = [ButtonControl buttonWithTextures:textureNormal3 litTexture:textureNormal3];
    

    CCTexture2D* texturePause = [self createLabel:@"||" 
                                    textSize:RESIZE_FONT(PAUSE_FONT)
                                    fontName:@"Chalkduster"];
    
    CCTexture2D* textureMute = [self createLabel:@"mute" 
                                         textSize:RESIZE_FONT(PAUSE_FONT)
                                         fontName:@"Chalkduster"];
    
    muteButton          = [ButtonControl buttonWithTextures:textureMute litTexture:textureMute];
    pauseButton         = [ButtonControl buttonWithTextures:texturePause litTexture:texturePause];
    
    // Shit code
    if( screen.width>=1024 || screen.height>=1024 )
    {
        [self addButton:leftButton 
                   posX:RESIZE_X_RAW(BUTTON_WIDTH_IPAD)/2 + RESIZE_X_RAW(BUTTONS_X_OFFSET_IPAD) 
                 tagVal:LEFT_BUTTON_TAG];
        
        [self addButton:rightButton 
                   posX:RESIZE_X_RAW(BUTTON_WIDTH_IPAD)/2 + RESIZE_X_RAW(BUTTONS_X_OFFSET_IPAD) 
                        + RESIZE_X_RAW(BUTTON_WIDTH_IPAD) + RESIZE_X_RAW(BUTTONS_X_GAP_IPAD)
                 tagVal:RIGHT_BUTTON_TAG];
        
        [self addButton:jumpButton 
                   posX:screen.width - RESIZE_X_RAW(BUTTONS_X_OFFSET_IPAD) - RESIZE_X_RAW(BUTTON_WIDTH_IPAD)/2 
                 tagVal:JUMP_BUTTON_TAG];        
    }else
    {
        [self addButton:leftButton 
                   posX:RESIZE_X_RAW(BUTTON_WIDTH)/2 + RESIZE_X_RAW(BUTTONS_X_OFFSET) 
                 tagVal:LEFT_BUTTON_TAG];
        
        [self addButton:rightButton 
                   posX:RESIZE_X_RAW(BUTTON_WIDTH)/2 + RESIZE_X_RAW(BUTTONS_X_OFFSET) 
         + RESIZE_X_RAW(BUTTON_WIDTH) + RESIZE_X_RAW(BUTTONS_X_GAP)
                 tagVal:RIGHT_BUTTON_TAG];
        
        [self addButton:jumpButton 
                   posX:screen.width - RESIZE_X_RAW(BUTTONS_X_OFFSET) - RESIZE_X_RAW(BUTTON_WIDTH)/2 
                 tagVal:JUMP_BUTTON_TAG];        
    }
    
    /*
#ifdef _DEBUG
    attackButton        = [ButtonControl buttonWithTextures:textureNormal litTexture:textureLit];
    [self addButton:attackButton posX:screen.width - RESIZE_X_RAW(BUTTONS_X_OFFSET) - RESIZE_X_RAW(BUTTONS_X_GAP_SMALL) 
             tagVal:ATTACK_BUTTON_TAG];
#endif
    */
    
    /*
    [self addButton:weaponChangeButton posX:screen.width - RESIZE_X_RAW(BUTTONS_X_OFFSET) - RESIZE_X_RAW(BUTTONS_X_GAP_SMALL) - RESIZE_X_RAW(BUTTONS_X_GAP_SMALL) 
             tagVal:CHANGE_WEAPON_BUTTON_TAG];
    */
    
    // pause button
    [self addAdditionalButton:muteButton  posX:screen.width - RESIZE_X_RAW(PAUSE_BUTTON_X_OFFSET) tagVal:PAUSE_BUTTON_TAG];
    [self addAdditionalButton:pauseButton posX:screen.width - RESIZE_X_RAW(PAUSE_BUTTON_X_OFFSET) -RESIZE_X_RAW(PAUSE_BUTTON_X_GAP) 
                       tagVal:MUTE_BUTTON_TAG];
}

-(void) addTimeLabel:(unsigned int)val
{
    NSString* str = [NSString stringWithFormat:NSLocalizedString(@"TimeLeft",@""),val];   
    
    // 0 - Get needed size
    CGSize constrained; 
    constrained.height = RESIZE_Y(100);
    constrained.width  = RESIZE_X(230);    
    // Verdana
    const CGSize actualSize = [str sizeWithFont:[UIFont fontWithName:@"DB LCD Temp"
                                                    size:RESIZE_FONT(TIME_LABLE_FONT)]
                              constrainedToSize:constrained
                                  lineBreakMode:UILineBreakModeMiddleTruncation];

    
    labelTimeLeft = [CCLabelTTF labelWithString:str 
                             dimensions:CGSizeMake(actualSize.width,actualSize.height) 
                              alignment:UITextAlignmentCenter 
                               fontName:@"DB LCD Temp" 
                               fontSize:RESIZE_FONT(TIME_LABLE_FONT)];
    
    CGSize screen = [[CCDirector sharedDirector] winSize];        
    
    [labelTimeLeft setPosition: ccp(RESIZE_X_RAW(120), 
                                    screen.height - RESIZE_Y_RAW(SCORE_LABEL_OFFSET_Y) - labelTimeLeft.contentSize.height/2)];
    
    if(alternativeColor)
        labelTimeLeft.color = TIMELEFT_LABEL_COLOR_ALT;
    else
        labelTimeLeft.color = TIMELEFT_LABEL_COLOR;
    
    [self addChild:labelTimeLeft z:TIMELEFT_LABLE_Z];
    
    CCScaleTo* actionZoomIn = [CCScaleTo actionWithDuration:1.5f scale:1.5f];
    CCScaleTo* actionZoomOut= [CCScaleTo actionWithDuration:1.5f scale:1.0f];
    [labelTimeLeft runAction:[CCSequence actions:actionZoomIn,actionZoomOut,nil]];   
}

-(void) addScore:(unsigned int)val
{
    NSString* str = [NSString stringWithFormat:NSLocalizedString(@"GotScore",@""),val];
    
    labelScore = [CCLabelTTF  labelWithString:str 
                                 dimensions:CGSizeMake(RESIZE_X(230), RESIZE_Y(100)) 
                                  alignment:UITextAlignmentCenter 
                                   fontName:@"DB LCD Temp" 
                                   fontSize:RESIZE_FONT(SCORE_LABLE_FONT)];
    
    CGSize screen = [[CCDirector sharedDirector] winSize];        
    
    [labelScore setPosition: ccp(RESIZE_X_RAW(120) + RESIZE_X_RAW(150), 
                               screen.height - RESIZE_Y_RAW(SCORE_LABEL_OFFSET_Y) - labelScore.contentSize.height/2)];
    
    if(alternativeColor)
        labelScore.color = SCORE_LABEL_COLOR_ALT;
    else
        labelScore.color = SCORE_LABEL_COLOR;
    
    [self addChild: labelScore z:SCORE_LABLE_Z];
    
    CCScaleTo* actionZoomIn = [CCScaleTo actionWithDuration:2.0f scale:1.5f];
    CCScaleTo* actionZoomOut= [CCScaleTo actionWithDuration:2.0f scale:1.0f];
    [labelScore runAction:[CCSequence actions:actionZoomIn,actionZoomOut,nil]];   
}

-(CGPoint) getScorePos
{
    return labelScore.position;
}

-(CGPoint) getTimePos
{
    return labelTimeLeft.position;
}


-(void) startBlinkAction:(CCSprite*)object
{
    // play action!
    if(![object getActionByTag:ACTION_TIME_BLINK])
    {
        CCScaleTo* actionZoomIn = [CCScaleTo actionWithDuration:0.3f scale:1.5f];
        CCScaleTo* actionZoomOut= [CCScaleTo actionWithDuration:0.3f scale:1.0f];
        
        [actionZoomIn setTag:ACTION_TIME_BLINK];
        
        [object runAction:
          [CCSequence actions:actionZoomIn,actionZoomOut,nil]
         ];
    }
}

-(void) blinkScore
{
    [self startBlinkAction:labelScore];
}

-(void) blinkTime
{
    [self startBlinkAction:labelTimeLeft];    
}

-(void) addHitPoints:(unsigned int)value
{    
    const CGSize screen = [[CCDirector sharedDirector] winSize];    

    const int currCount = [hitPointsControls count];
    
    int heightCurrent = 
        screen.height - RESIZE_Y_RAW(HITPOINT_Y_OFFSET) - RESIZE_Y_RAW(HITPOINT_HEIGHT/2) -
                (currCount * (RESIZE_Y_RAW(HITPOINT_Y_OFFSET) + RESIZE_Y_RAW((HITPOINT_HEIGHT))));
    
    for(unsigned int i=0; i<value; i++)
    {
        CCSpriteEx* h1 = [[CCSpriteEx alloc]initWithFile:@"star.png"];
        [h1 autorelease];
        
        h1.position = ccp(RESIZE_X_RAW(HITPOINT_X_OFFSET), heightCurrent);
        
        [h1 setWidth:RESIZE_X_RAW(HITPOINT_WIDTH)];
        [h1 setHeight:RESIZE_Y_RAW(HITPOINT_HEIGHT)];
        
        [h1 setTag:HITPOINT_TAG + i + currCount];
        [self addChild:h1 z:HITPOINT_Z tag:HITPOINT_TAG + i + currCount];
        
        heightCurrent-=RESIZE_Y_RAW(HITPOINT_Y_OFFSET);
        heightCurrent-=RESIZE_Y_RAW(HITPOINT_HEIGHT);
        
        [hitPointsControls addObject:h1];
    }
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) 
	{		              
        self.isTouchEnabled = YES;    
        timeLeftPrevValue = 0;
       
        hitPointsControls = [[NSMutableArray alloc]init];
        
        // controls
		[self addButtons];
        [self addHitPoints:INITIAL_HITPOINTS];
        
        //[self schedule: @selector(buttonReplicator:) interval: REPLICATOR_SINGLE_ITERATION];
        [self scheduleUpdateWithPriority:0];
	}
	
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [hitPointsControls release];
	[super dealloc];
}

-(void) updateTimeLeft:(unsigned int)value;
{
    if(timeLeftPrevValue==value)
        return;
    
    if(!labelTimeLeft)
    {
        // first time
        [self addTimeLabel:value];
    }else
    {
        // Show it on label
        NSString* strNewVal = [NSString stringWithFormat:@"%d %%",value];
        [labelTimeLeft setString:strNewVal];
        
        if(value<LOW_TIME_THRESHOLD)
        {
            // play action!
            [self startBlinkAction:labelTimeLeft];
        }
    }
    
    timeLeftPrevValue = value;
}

-(void) updateScore:(unsigned int)value
{    
    if(!labelScore)
    {
        // first time
        [self addScore:value];
    }else
    {
        // Show it on label
        NSString* strNewVal = [NSString stringWithFormat:NSLocalizedString(@"ScoreLabelVal",@""),value];
        [labelScore setString:strNewVal];        
    }
}

-(void) updateHitPoints:(unsigned int)value
{
    if(![hitPointsControls count])
        return;
    
    int toRemove = ([hitPointsControls count] - value);
    if(toRemove>=0)
    {
        // remove n hit points
        for(int i=0; i<toRemove; ++i)
        {
            CCSpriteEx* sprite = [hitPointsControls objectAtIndex:[hitPointsControls count]-1-i];
            
            const int t = [sprite tag];
            [self removeChildByTag:t cleanup:NO];
            [hitPointsControls removeObject:sprite];
        }
    }else
    {
        // add hitpoints!
        [self addHitPoints:-toRemove];
    }
    
    // blink if last hit point left!
    /*
    if([hitPointsControls count]==1)
    {
        CCSpriteEx* sprite = [hitPointsControls objectAtIndex:0];
        [self startBlinkAction:sprite];
    }*/
}

@end

