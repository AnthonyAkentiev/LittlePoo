#import "ObjectBase.h"
#import "Player.h"
#include "triggers.h"
#include "helpers.h"
#include "timings.h"
#include "movements.h"
#include "animations.h"

#define OBJECTS_LAYER_Z 1
#define BACK_LAYER_Z    0 

@implementation ObjectBase

-(CCAction*) runAction:(CCAction*) action
{
    // delegate
    return [sprite runAction:action];
}

- (id)initWithWorld:(StageBase<IStage>*)w 
                pos:(CGPoint)pos 
             params:(ObjectParams)p
           spriteIn:(CCSpriteEx*)spriteIn
             zValue:(int)zValue
{
    if(self=[super init])
    {
        sprite = [spriteIn retain];
        world  = [w retain];        
        staticParams = p;
        
        if(p.spriteSize.height!=0)
        {            
            [sprite setWidth:p.spriteSize.width];
            [sprite setHeight:p.spriteSize.height];
        }else
        {
            // auto width
            [sprite setWidthScaled:p.spriteSize.width];
        }

        
        // cache
        sprite.anchorPoint = ccp(0,0);  // left anchored!
        playerSize = [sprite getContentSize];
        [sprite setPositionLowerLeft:pos];
        
        [world addChild:sprite z:zValue];
    }
    return self;
}

-(void)dealloc
{
    [world removeChild:sprite cleanup:YES];   
    [world release];
    [sprite release];
    [staticParams.name release];
    [super dealloc];
}

- (NSString*) getName
{
    return staticParams.name;
}

- (CGPoint) getCenterPos
{ 
    CGPoint outPnt = sprite.position;
    outPnt.x+=([self getObjectSize].width/2);
    outPnt.y+=([self getObjectSize].height/2);
    return outPnt;
}

- (CGPoint) getLeftAnchorPos
{
    return sprite.position;
}

-(CGRect) getLeftAnchorPosRect
{
    CGRect outRect;
    // screen coordinates!
    CGPoint playerPos = [self getLeftAnchorPos];
    outRect.origin= playerPos;
    outRect.size  = [self getObjectSize];
    return outRect;
}

- (CGSize) getObjectSize
{   
    return playerSize;
}

-(CGRect) getCurrentPositionWorld
{
    CGRect playerPos = [self getLeftAnchorPosRect];
    return [world toWorldCoords:playerPos];
}

// direct manipulation
- (void) moveSprite:(CGFloat)x y:(CGFloat)y
{
    [sprite setPosition:ccp(sprite.position.x + x,sprite.position.y + y)];
}

- (void) playerTouched:(id)player
{
    NSAssert(player!=nil,@"Bad params");
    
    // update params
    Player* p = (Player*)player;
    [p setScore:[p getScore] + staticParams.scoreModifier];
    
    int newTime = [p getTimeElapsed] - staticParams.timeModifier;
    if(newTime<0)
        newTime=0;
    
    [p setTimeElapsed:(unsigned int)newTime];    
    [p setHitPoints:[p getHitPoints] + staticParams.hitPointModifier];
    [p updateSpecialModifiers:self];
}

-(BOOL) isVisible
{
    CGRect pos = [self getCurrentPositionWorld];
    
    CGRect screen;
    screen.size = [[CCDirector sharedDirector] winSize];    
    screen.origin.x = screen.size.width/2;        // WARNING: bad code add this offset!
    screen.origin.y = 0;
    screen.size.height= /*TO_WORLD_COORDS_Y*/(screen.size.height);
    screen.size.width = /*TO_WORLD_COORDS_X*/(screen.size.width);
    
    screen = [world toWorldCoords:screen];
    
    //screen.origin.y     = ;
    //screen.size.height  = INT_MAX;
    
    if(CGRectGetMaxX(screen)<=CGRectGetMaxX(pos) || 
       CGRectGetMaxY(pos)<=CGRectGetMinY(screen) || 
       CGRectGetMaxY(pos)>=CGRectGetMaxY(screen) )
        return NO;
    
    return YES;
}

@end

@implementation CollectableObject

- (CCSpriteEx*) initSprite:(NSString*)spriteName
{
    /*
#ifdef _DEBUG
    // no sprites yet!
    spriteName = @"emerald.png";
#endif
    */
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:spriteName];    
    return spriteOut;
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    NSString* spriteName = [props valueForKey:@"spriteName"];
    NSAssert([spriteName length],@"Bad object property: no 'spriteName'");
    
    CCSpriteEx* spriteIn = [self initSprite:spriteName];
    ObjectParams paramsIn;
    
    paramsIn.scoreModifier           = [[props valueForKey:@"scoreModifier"]intValue];
    paramsIn.timeModifier            = [[props valueForKey:@"timeModifier"] intValue];
    paramsIn.hitPointModifier        = [[props valueForKey:@"hitPointModifier"] intValue];
    
    paramsIn.spriteSize.width        = RESIZE_X([[props valueForKey:@"strictWidth"] intValue]);
    paramsIn.spriteSize.height       = 0;      // auto
    paramsIn.name                    = [[NSString stringWithString:name]retain];
    
    //NSAssert(paramsIn.spriteSize.width,@"Bad object property: no 'width'");
    if(!paramsIn.spriteSize.width)
    {
        // get from sprite
        paramsIn.spriteSize.width = RESIZE_SPRITE_X(([spriteIn contentSize].width));
    }
    
    self = [super initWithWorld:stageBase 
                            pos:pos 
                         params:paramsIn 
                       spriteIn:spriteIn
                         zValue:OBJECTS_LAYER_Z];
    if(self)
    {
        
    }
    return self;
}

-(BOOL) isScoreModifier
{
    return (staticParams.scoreModifier!=0);
}

-(BOOL) isTimeModifier
{
    return (staticParams.timeModifier!=0);    
}
@end


@implementation BackgroundObject

- (CCSpriteEx*) initSprite:(NSString*)spriteName
{
    /*
#ifdef _DEBUG
    // no sprites yet!
    spriteName = @"r1.png";
#endif
    */
    CCSpriteEx* spriteOut = [CCSpriteEx spriteWithSpriteFrameName:spriteName];
    return spriteOut;
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    NSString* spriteName = [props valueForKey:@"spriteName"];
    NSAssert([spriteName length],@"Bad object property: no 'spriteName'");
    
    CCSpriteEx* spriteIn = [self initSprite:spriteName];

    if([props valueForKey:@"flip"])
    {
        [spriteIn setFlipX:YES];
    }
    
    ObjectParams paramsIn;
    
    paramsIn.scoreModifier           = 0;
    paramsIn.timeModifier            = 0;
    paramsIn.hitPointModifier        = 0;
    paramsIn.spriteSize.width        = RESIZE_X([[props valueForKey:@"strictWidth"] intValue]);
    paramsIn.spriteSize.height       = 0;      // auto
    paramsIn.name                    = [[NSString stringWithString:name]retain];
    
    //NSAssert(paramsIn.spriteSize.width,@"Bad object property: no 'width'");
    if(!paramsIn.spriteSize.width)
    {
        // get from sprite!
        paramsIn.spriteSize.width = RESIZE_SPRITE_X(([spriteIn getContentSize].width));
    }
    
    self = [super initWithWorld:stageBase 
                            pos:pos 
                         params:paramsIn 
                       spriteIn:spriteIn
                         zValue:BACK_LAYER_Z];
    if(self)
    {
        
    }
    return self;
}

@end

@implementation GoalObject

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props
{
    CCSpriteEx* spriteIn = [CCSpriteEx spriteWithFile:@"r1.png"];
    [spriteIn setVisible:NO];
    
    ObjectParams paramsIn;
    
    paramsIn.scoreModifier           = [[props valueForKey:@"scoreModifier"]intValue];
    paramsIn.timeModifier            = [[props valueForKey:@"timeModifier"] intValue];
    paramsIn.hitPointModifier        = [[props valueForKey:@"hitPointModifier"] intValue];
    paramsIn.spriteSize.width        = RESIZE_X(32);
    paramsIn.name                    = [[NSString stringWithString:name]retain];
    
    self = [super initWithWorld:stageBase 
                            pos:pos 
                         params:paramsIn 
                       spriteIn:spriteIn
                         zValue:0];
    
    if(self)
    {
        
    }
    return self;
}

@end