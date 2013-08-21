#include "Quiz.h"
#import "MainMenu.h"
#import "WinScreen.h"
#import "StageSelect.h"
#import "SimpleAudioEngine.h"

#import "Briefing.h"
#import "helpers.h"
#import "SpriteEx.h"
#import "Game.h"
#include "fonts.h"
#include "timings.h"
#include "stdlib.h"

@implementation Quiz

#define QUESTION_TEXT_COLOR ccc3(0,0,0)
#define ANSWER_TEXT_COLOR ccc3(255,255,255)

#define MAX_QUESTION_NUM 13

-(void)moveBack
{    
	// move to MainMenu scene!
	// HACK: else NSClassFromString will fail
	[CCTransitionRadialCCW node];
	
	Class transition  = NSClassFromString(NSLocalizedString(@"_TransitionToMainMenu",""));
	
	CCScene* mainMenu = [MainMenu node];
	[[CCDirector sharedDirector] replaceScene: [transition 
                                                transitionWithDuration:STAGE_TRANSITION_DURATION 
                                                scene:mainMenu]];
}

-(void) showStageSelect
{
     [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
     
     [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
     scene:[StageSelect node]]];
}

-(void) moveToLastStage 
{
    // move to next last stage!
    const int tag = [Game getLastStageTag];
    NSAssert(tag!=-1,@"Bad tag!");
    
    StageBase<IStage>* currentStage = [Game getStageByTag:tag];
    [currentStage init];
    
    Briefing* br = [[[Briefing alloc] initWithStage:currentStage]autorelease];
    CCScene* nextScene = (CCScene*) br;    
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [[CCDirector sharedDirector] replaceScene: 
     [CCTransitionFade transitionWithDuration:STAGE_TRANSITION_DURATION 
                                        scene:nextScene]]; 

}

-(void) menuCallback:(id) sender
{
    NSLog(@"StageSeelct-menuCallback");
    
    CCMenuItem* item = (CCMenuItem*) sender;
    NSLog(@"Selected item: %d",item.tag);
    
    if(item.tag==correctAnswer_)
    {
        if( isShowStageSelect_ )
            [self showStageSelect];
        else 
            [self moveToLastStage];
    }else
    {
        // incorrect
        [[SimpleAudioEngine sharedEngine] playEffect:@"hit1.mp3" pitch:0.8f 
                                                 pan:0.0f 
                                                gain:0.1f];
    }
}

-(NSMutableArray*) getQuizStrings:(NSString**)questionOut
                    correctAnswer:(int*)correctAnswer
{
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
    *questionOut = @"question";
    
    const unsigned int x = (rand() % MAX_QUESTION_NUM)+1;

    // read from resources
    NSString* strQuestionFormat = [NSString stringWithFormat:@"Question%d",x];
    NSAssert([strQuestionFormat length],@"Bad string");
    
    *questionOut = NSLocalizedString(strQuestionFormat,@"No question");
    
    // read answers
    for(size_t sz=0; sz<3; ++sz)
    {
        NSString* strAnswerFormat = [NSString stringWithFormat:@"Answer%d_%d",x,sz+1];
        NSString* str = NSLocalizedString(strAnswerFormat,@"No answer");
        [arr addObject:str];
    }

    // read correct answer
    NSString* strCorrectAnswer = [NSString stringWithFormat:@"Question%d_answ",x];
    NSString* correctAnswerStr = NSLocalizedString(strCorrectAnswer,@"Bad string");

    NSScanner* scanner = [[NSScanner alloc] initWithString:correctAnswerStr];
    NSInteger integer;
    [scanner scanInt:&integer];
    *correctAnswer = integer;
    [scanner release];
    
    return arr;
}

-(CCLabelTTF*)createLabel:(NSString*)text
                 textSize:(CGFloat)textSize
                 fontName:(NSString*)fontName
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    // get needed size
    CGSize actualSize = [text sizeWithFont:[UIFont fontWithName:fontName
                                                           size:textSize]
                         constrainedToSize:screen
                             lineBreakMode:UILineBreakModeMiddleTruncation];
    // add label
    CCLabelTTF* label = [CCLabelTTF labelWithString:text
                                         dimensions:actualSize
                                          alignment:UITextAlignmentCenter
                                      lineBreakMode:UILineBreakModeMiddleTruncation 
                                           fontName:fontName
                                           fontSize:textSize];
    return label;
}

-(void) addMenu
{
    NSLog(@"Quiz-addMenu");
    NSString* question = [[NSString alloc]init];
    
    correctAnswer_ = 0;
    NSMutableArray* strings = [self getQuizStrings:&question
                                     correctAnswer:&correctAnswer_];

    // add Question
    CCLabelTTF* labelTitle = [self createLabel:question
                                      textSize:RESIZE_FONT(QUESTION_TEXT_SIZE)
                                      fontName:@"Marker Felt"];
    [labelTitle setColor:QUESTION_TEXT_COLOR];
    
    NSLog(@"%f - %f",labelTitle.contentSize.width, labelTitle.contentSize.height );
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    labelTitle.position =  ccp(screen.width /2 , 
                               screen.height - labelTitle.contentSize.height/2 - RESIZE_Y(5) );
    
    [self addChild: labelTitle];
    
    
	// add menu1
	[CCMenuItemFont setFontSize:DEFAULT_MENU_BIGFONT];
	[CCMenuItemFont setFontName: @"Marker Felt"];

    
    int dummyList[2] = {0, 0};
    menu = [[CCMenu alloc]initWithItems:nil 
                                 vaList:(va_list)dummyList];
    
    int i = 1;
    for(id obj in strings)
    {
        NSString* answer = (NSString*)obj;
        
        NSString* strFormatted = [NSString stringWithFormat:@"%d. %@",
                                      i,
                                      answer];
            
        CCMenuItem* item   = [CCMenuItemFont itemFromString:strFormatted 
                                                     target:self     
                                                   selector:@selector(menuCallback:)];
        
        [item setTag:i];
        [menu addChild:item];
        
        ++i;
    }    
    
    [strings release];
    //[question release];
	[menu alignItemsVertically];
    
	menu.position = ccp(screen.width/2 , screen.height/2 );
	[self addChild: menu];
}

-(void) playRandomMusic
{   
    NSLog(@"StageSeelct-playRandomMusic");
    struct MusicTuple
    {
        NSString* file;
        float volume;
    };
    
#ifdef PLAY_BACKGROUND_MUSIC
    if([Game isSpecialMusicMode])
    {
        MusicTuple music[] = 
        {
            {@"sektor1.mp3",0.1f},
            {@"sektor2.mp3",0.2f},
            {@"sektor3.mp3",0.2f},
            {@"how_to_be.mp3",0.1f},
            {@"leningrad1.mp3",0.1f},
            {@"dengi.mp3",0.1f},
            {@"mandaty2.mp3",0.1f},
            {@"blya.mp3",0.1f},
            {@"chemodan_strana.mp3",0.1f},
        };
        
        unsigned int index = (rand() % _countof(music));    
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:music[index].volume];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:music[index].file 
                                                         loop:YES];
    }else
    {
        // no music playin'
    }
#endif
}

-(void) genericInit
{
    self.isTouchEnabled = YES;
    isShowStageSelect_ = NO; // default -> go to last stage after Quiz
    
    [self addMenu];
    //[self playRandomMusic];
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    CCSpriteEx* bg = [CCSpriteEx spriteWithFile:@"frame1.jpg"];
    bg.position = ccp(screen.width/2, screen.height/2);
    [bg setWidth:screen.width];
    [bg setHeight:screen.height];
    [self addChild:bg z:-5];
}

-(id) init
{
    if(self = [super init])
        [self genericInit];
    
    return self;
}


-(id) initIfStageSelect
{
    if(self = [super init])
        [self genericInit];
    
    isShowStageSelect_ = YES;
    return self;
}

@end