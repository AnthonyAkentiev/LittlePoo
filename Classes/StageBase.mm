#include "StageBase.h"
#include "SpriteTags.h"
#include "SpriteEx.h"

#import "Player.h"
#import "Bear.h"
#import "Bee.h"
#import "Wolf.h"
#import "Eagle.h"
#import "Gran.h"
#import "Mole.h"
#import "Owl.h"
#import "NPCs.h"
#import "Condom.h"
#import "Chick.h"

#include "helpers.h"
#include "movements.h"
#include "triggers.h"
#include "timings.h"
#include "animations.h"

@implementation StageBase

#define ACTION_MOVE_WORLD 1

// layers
#define STATIC_BACK_LAYER_Z -3
#define BACKGROUND_SPRITE_MOVING_LAYER_Z -2
#define FOREGROUND_SPRITE_MOVING_LAYER_Z -1
#define TILEMAP_LAYER_Z    1

#define CLOUD_LAYER_Z 10

- (id) init
{
	if( (self=[super init])) 
	{
        // Init stuff
        stopMoving                 = NO;
        nowMovingHorizontally      = NO;
        moveWantedPoint = ccp(0.0f,0.0f);
            
        arrTmp = [[NSMutableArray alloc]init];
        
        cloudsLayer = [[[CCLayer alloc]init]retain];
        [self addChild:cloudsLayer z:CLOUD_LAYER_Z];
	}
	
	return self;
}

-(void)dealloc
{
    id enemy;
    for(enemy in enemies)
    {
        [enemy release];
    }
    [enemies release];
    [objects release];
    
    [cloudsLayer release];
    [arrTmp release];
    [super dealloc];
}

-(CGRect) getGoalObjPos{return goalObjectPosition;}

- (void) setPlayer:(id)p
{
    player = p;
}

- (id)      getPlayer
{
    return player;
}

-(void) loadTileMap:(NSString*)fileName layerName:(NSString*)layerName
{
	tileMapNode = [CCTMXTiledMap tiledMapWithTMXFile:fileName];
	tileMapNode.anchorPoint = ccp(0, 0);

	tileMapNode.scaleX = CurrentScaleFactorX * [[UIScreen mainScreen] scale];
    tileMapNode.scaleY = CurrentScaleFactorY * [[UIScreen mainScreen] scale];
    	    
	backgroundLayer = [tileMapNode layerNamed:layerName];
	[self addChild:tileMapNode z:TILEMAP_LAYER_Z];
    
    // run asserts :-)
#ifdef _DEBUG
    [self checkObjects];
#endif 
    
    if(![self getObjectPosRect:@"End" rect:&goalObjectPosition])
    {
        NSAssert(false, @"Can't get End object from current stage");
    }
    
    // Init physics
    [self initCollisions:tileMapNode objectLayerName:@"Collision"];
    [self initEnemies];
    [self initObjects];
    
    
#ifdef SCROLL_TO_SPAWN
    // scroll to spawn
    CGPoint pnt;
    if(![self getObjectPos:@"Spawn" pnt:&pnt])
    {
        NSAssert(false, @"Can't get spawn point from current stage!");
    }
    
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    
    [self moveLayerDirectX:-(pnt.x-screen.size.width/2)];
#endif
}

-(void) initEnemies
{
    enemies = [[NSMutableArray alloc]init];
    
    struct EnemyTuple
    {
        NSString* objectNameFormat;
        NSString* className;
    };
    
    EnemyTuple enemy_tuples[] = 
    {
        {@"bear%d",@"Bear"},
        {@"bee%d",@"Bee"},
        {@"wolf%d",@"Wolf"},
        {@"eagle%d",@"Eagle"},
        {@"gran%d",@"Gran"},
        {@"mole%d",@"Mole"},
        {@"owl%d",@"Owl"},
        {@"condom%d",@"Condom"},
        {@"chick%d",@"Chick"},
        {@"punk%d",@"Punk"},
        
        {@"Navalny%d",@"Navalny"},
        {@"Sobchak%d",@"Sobchak"},
        {@"Timoty%d",@"Timoty"}
    };
    
    for(size_t i=0; i<_countof(enemy_tuples); ++i)
    {        
        int objs = 1;
        while(true)
        {
            NSString* objectName = [NSString stringWithFormat:enemy_tuples[i].objectNameFormat, objs];	
            CGRect objectPos;
            if(![self getObjectPosRect:objectName rect:&objectPos])
                break;
            
            NSMutableDictionary* dict = [self getObjectProperties:objectName];
            
            Class c = NSClassFromString(NSLocalizedString(enemy_tuples[i].className,""));
            MovingObject* obj = [[c alloc]initWithWorld:(StageBase<IStage>*)self 
                                               name:objectName
                                                pos:objectPos.origin
                                              props:dict
                                ];
            
            [enemies addObject:obj];		
            ++objs;
        }
    }
}

-(void) initObjects
{
    objects = [[NSMutableArray alloc]init];
    
    struct ObjectTuple
    {
        NSString* objectNameFormat;
        NSString* className;
    };
    
    ObjectTuple object_tuples[] = 
    {
        // collectables
        {@"oil%d",@"CollectableObject"},
        
        // sprites
        {@"back%d",@"BackgroundObject"},
        
        // special
        {@"goal%d",@"GoalObject"},
        
        // Satellite
        {@"sat%d",@"CollectableObject"},
    };
    
    for(size_t i=0; i<_countof(object_tuples); ++i)
    {        
        int objs = 1;
        while(true)
        {
            NSString* objectName = [NSString stringWithFormat:object_tuples[i].objectNameFormat, objs];	
            CGRect objectPos;
            if(![self getObjectPosRect:objectName rect:&objectPos])
                break;
            
            NSMutableDictionary* dict = [self getObjectProperties:objectName];
            
            Class c = NSClassFromString(NSLocalizedString(object_tuples[i].className,""));
            ObjectBase* obj = [[c alloc]initWithWorld:(StageBase<IStage>*)self 
                                                   name:objectName
                                                    pos:objectPos.origin
                                                  props:dict
                                 ];
            
            [objects addObject:obj];		
            ++objs;
        }
    }    
}

- (void) removeEnemy:(id)enemy
{
    [enemies removeObject:enemy];
    [enemy release];
}

- (void) removeObject:(id)object
{
    [objects removeObject:object];
    [object release];
}

-(void) moveBackSprite:(CCSpriteEx*)sprite 
                           x:(CGFloat)x
                           y:(CGFloat)y
{
    // 0- get sprite width and calculate current diff
    // Calculate movement rate.
    if(!sprite.contentSize.width)
        return;
    
    const CGFloat parallaxRate = (goalObjectPosition.origin.x) 
        / [sprite getContentSize].width;
    
    // calcualte current layer diff 
    x/=parallaxRate;
    x/=2.0;                 // we shall be at the center of the sprite at the end of stage!
    
    // 1-move layer
    CGFloat after = sprite.position.x + x;    
    [sprite setPosition:ccp(after,sprite.position.y)];
}

-(void) moveBackground:(CGFloat)x y:(CGFloat)y
{
    // manual parallax
    [self moveBackSprite:staticBackgroundSprite x:x y:y];
    [self moveBackSprite:backgroundSpriteMoving x:x y:y];
    [self moveBackSprite:foregroundSpriteMoving x:x y:y];
}

// direct manipulation
-(BOOL) moveLayer:(CGFloat)x 
                y:(CGFloat)y
{        
    BOOL hasMoved = YES;
    if(tileMapNode.position.x + x>0)
    {
        x = 0 - tileMapNode.position.x;
        hasMoved = NO;
    }
    
    if(tileMapNode.position.y + y>0)
    {
        y = 0 - tileMapNode.position.y;
        hasMoved = NO;
    }
    
    // move all tilemap layers.
    CGPoint after = ccp(MIN(0,tileMapNode.position.x + x), 
                        MIN(0,tileMapNode.position.y + y));
    
    //NSLog(@"Setting world position: x=%f, y=%f; diff: x=%f, y=%f",
    //      after.x,
    //      after.y,
    //      x, y);

    // move background parallax layers!
    [self moveBackground:LRINT(x) y:LRINT(y)];
        
    after.x = LRINT(after.x);
    after.y = LRINT(after.y);
    
    [tileMapNode setPosition:after];
    [cloudsLayer setPosition:after]; 
    
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    screen = [self toWorldCoords:screen];
    
    // we do not animate objects that are far away
    const CGFloat maxScreenObjStep = screen.origin.x + screen.size.width + CLIP_OBJECTS_X_VAL;

    
    // all objects
    [self moveObjects:enemies x:x y:y 
                 maxX:maxScreenObjStep];
    [self moveObjects:objects x:x y:y 
                 maxX:maxScreenObjStep];
    return hasMoved;
}

-(void) moveObjects:(NSMutableArray*)objs
                  x:(CGFloat)x 
                  y:(CGFloat)y
               maxX:(CGFloat)maxX       // wolrd coords
{
    if(IS_NEAR(x,0.0) && IS_NEAR(y,0.0))
        return;
    
    // move all objects from array
    for(id obj in objs)
    {
        //CGRect rectObj = [obj getCurrentPositionWorld];
        //if(rectObj.origin.x>maxX)
        //    continue;
        
        [obj moveSprite:x y:y];
    }
}

- (void)step:(ccTime)delta
{    
    // TODO: move to GAME class!
    // call all objects processing!
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    screen = [self toWorldCoords:screen];
    
    // we do not animate objects that are far away
    const CGFloat maxScreenObjStep = screen.origin.x + screen.size.width + CLIP_OBJECTS_X_VAL;
    
    for(MovingObject* obj in enemies)
    {
        CGRect rectObj = [obj getCurrentPositionWorld];
        if(rectObj.origin.x>maxScreenObjStep)
            continue;
        
        [obj step:delta];
    }
}

-(void) draw
{
#ifdef DRAW_PHYSICS_OBJS
    glEnable(GL_LINE_SMOOTH);
    glColor4ub(255, 0, 255, 255);
    glLineWidth(2);
    
    // Get current wieport rectangle
    CGRect rectWorldOriginal;
    rectWorldOriginal.size = [[CCDirector sharedDirector] winSize];
    rectWorldOriginal = [self toWorldCoords:rectWorldOriginal];
    
    // Get visible physical objects 
    [arrTmp removeAllObjects];
    [self getObjects:rectWorldOriginal arrOut:arrTmp];
    
    NSValue* value;
    
    //NSLog(@"total objects: %d",[array count]);
    
    unsigned int objIndex = 0;
    for(value in arrTmp)
    {
        CGRect rectOriginal = [value CGRectValue];
        [self toScreenCoords:&rectOriginal];
        
        const CGPoint vertices[] = 
        { 
            ccp(CGRectGetMinX(rectOriginal),CGRectGetMinY(rectOriginal)),
            ccp(CGRectGetMinX(rectOriginal),CGRectGetMaxY(rectOriginal)),
            ccp(CGRectGetMaxX(rectOriginal),CGRectGetMaxY(rectOriginal)),
            ccp(CGRectGetMaxX(rectOriginal),CGRectGetMinY(rectOriginal)),
        };
        
        /*
        NSLog(@"Object %d: %f,%f\n%f,%f\n%f,%f\n%f,%f",objIndex, vertices[0].x, vertices[0].y,
                        vertices[1].x, vertices[1].y,
                        vertices[2].x, vertices[2].y,
                        vertices[3].x, vertices[3].y);
        */
        
        ccDrawPoly(vertices, _countof(vertices), YES);        
        ++objIndex;
    }
#endif // DRAW_PHYSICS_OBJS
}

- (CCTMXTiledMap*)getTileMap
{
	return tileMapNode;
}

- (NSMutableArray*) getEnemies
{
    return enemies;
}

- (NSMutableArray*) getObjects
{
    return objects;
}

-(void) checkObjects
{
    // Check that all objects are present in current stage!
    NSString* strings[] = 
    {
        @"Spawn",
        @"End"        
    };
    
    for(size_t i=0; i<_countof(strings); ++i)
    {
        // contains asserts inside
        CGPoint pntCurrent;
        [self getObjectPos:strings[i] pnt:&pntCurrent];
    }
}

-(void) addClouds:(int)zOrder
{
	struct CloudTuple
	{
		NSString* fileName;
		float scale;
	};
	
    // TODO: pass this array as parameter to this method?
	CloudTuple cloudTypes[] =
	{
		{@"cloud1.png",1.0f},
		{@"cloud2.png",1.0f},
        {@"cloud3.png",1.0f},
        
        {@"cloud1.png",0.8f},
		{@"cloud2.png",0.8f},
        {@"cloud3.png",0.8f},
        
        {@"cloud1.png",0.6f},
		{@"cloud2.png",0.6f},
        {@"cloud3.png",0.6f},
        
        {@"cloud1.png",0.4f},
		{@"cloud2.png",0.4f},
        {@"cloud3.png",0.4f},
	};
	
	// get all objects that are named Cloud%d in objects
	CCTMXObjectGroup* objs = [tileMapNode objectGroupNamed:@"Objects"];
	NSAssert(objs != nil, @"'Objects' object group not found");
	
	int cloudsAdded = 0;
	while(true)
	{
		NSString* objectName = [NSString stringWithFormat:@"Cloud%d", cloudsAdded];	
		
		NSMutableDictionary* cloudPosition = [objs objectNamed:objectName];   
		if(!cloudPosition)
			break;
		
		// get random filename
		const unsigned int indexRand = (rand() % _countof(cloudTypes));
		NSAssert(indexRand<_countof(cloudTypes),@"rand error");
		
		// add cloud
        CCSpriteEx* cloud = [CCSpriteEx spriteWithSpriteFrameName:cloudTypes[indexRand].fileName]; 
		       
		NSLog(@"Adding cloud: %@; scale=%f",cloudTypes[indexRand].fileName,cloudTypes[indexRand].scale);
		
		const int x  = RESIZE_SPRITE_X(RoundSize([[cloudPosition valueForKey:@"x"] intValue]));
		const int y  = RESIZE_SPRITE_Y(RoundSize([[cloudPosition valueForKey:@"y"] intValue]));
		
		cloud.position  = ccp(x, y);
		cloud.scale     = cloudTypes[indexRand].scale;
		[cloudsLayer addChild:cloud z:zOrder tag:CLOUD_SPRITE_TAG];
				
		++cloudsAdded;
	}
	
	NSLog(@"cloudsAdded=%d",cloudsAdded);	
}

// static background that doesn't move!!!
-(void) initBackgroundSprites:(NSString*)staticBack 
                   movingBack:(NSString*)movingBack
             movingForeground:(NSString*)movingForeground
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    // this one is 1 to 1, i.e. 480*320
    if([staticBack length])
    {
        staticBackgroundSprite = [CCSpriteEx spriteWithFile:staticBack];
        staticBackgroundSprite.position = ccp(screen.width/2, screen.height/2);
        [staticBackgroundSprite setWidth:screen.width];
        [staticBackgroundSprite setHeight:screen.height];    
        [self addChild:staticBackgroundSprite z:STATIC_BACK_LAYER_Z];
    }
    
    // moving background minimum 2 times wider that the screen
    if([movingBack length])
    {
        backgroundSpriteMoving = [CCSpriteEx spriteWithFile:movingBack];
        [backgroundSpriteMoving setHeightScaled:screen.height]; 

        backgroundSpriteMoving.anchorPoint = ccp(0,0);
        backgroundSpriteMoving.position = ccp(0, 0);
        [self addChild:backgroundSpriteMoving z:BACKGROUND_SPRITE_MOVING_LAYER_Z];
    }
    
    // this one is foreground layer (trees etc) - minimum 5*6 screens wide
    if([movingForeground length])
    {
        foregroundSpriteMoving = [CCSpriteEx spriteWithFile:movingForeground];
        
        foregroundSpriteMoving.anchorPoint = ccp(0,0);
        foregroundSpriteMoving.position = ccp(0, 0);
        
        [foregroundSpriteMoving setHeight:screen.height];
        [self addChild:foregroundSpriteMoving z:FOREGROUND_SPRITE_MOVING_LAYER_Z];
    }
}

-(void) darkenBackground
{
    backgroundSpriteMoving.color = ccc3(100, 100, 100);
    backgroundSpriteMoving.blendFunc = (ccBlendFunc) { GL_ONE, GL_ONE };

    
    //[self performSelector:@selector(ResetBlendForSprite:) 
    //           withObject:backgroundSpriteMoving 
    //           afterDelay:0.17f];
    
    //[backgroundSpriteMoving setColor:ccBLACK];
    //[backgroundSpriteMoving setBlendFunc:(ccBlendFunc){0.1, 0.1}];
}


-(id)   getObject:(NSString*)objName
{
    NSMutableArray* objs = [self getObjects];
    for(ObjectBase* obj in objs)
    {
        if([[obj getName]compare:objName]==NSOrderedSame)
        {
            return obj;
        }
    }
    
    return nil;
}

-(BOOL) getObjectPos:(NSString*)objName pnt:(CGPoint*)pnt
{
    CCTMXObjectGroup* objs = [[self getTileMap] objectGroupNamed:@"Objects"];
    if(objs==nil)
        return NO;
    NSAssert(objs != nil, @"'Objects' object group not found");
    
    NSMutableDictionary* obj = [objs objectNamed:objName];        
    if(obj==nil)
        return NO;
    
    NSAssert(obj != nil, @"Object not found");    
    CGPoint pos;
    
    // scale the position as it is just returned as property
    pos.x = RESIZE_X(RoundSize([[obj valueForKey:@"x"] intValue]));
    pos.y = RESIZE_Y(RoundSize([[obj valueForKey:@"y"] intValue]));    
    *pnt =  pos;
    
    return YES;
}

-(NSMutableDictionary*) getObjectProperties:(NSString*)objName
{
    CCTMXObjectGroup* objs = [[self getTileMap] objectGroupNamed:@"Objects"];
    if(objs==nil)
        return NO;
    NSAssert(objs != nil, @"'Objects' object group not found");
    
    return [objs objectNamed:objName];  
}

-(BOOL) getObjectPosRect:(NSString*)objName rect:(CGRect*)rect
{
    if(![self getObjectPos:objName pnt:&(rect->origin)])
        return NO;
    
    rect->size.width = BLOCK_SIZE;
    rect->size.height= BLOCK_SIZE_Y;
    return YES;
}

// internal method
-(void) scheduleMoveBackSpriteLeftRight:(CCSpriteEx*)sprite 
                 diff:(CGFloat)diff 
               timing:(ccTime)timing
{
    // 0- get sprite width and calculate current diff
    // Calculate movement rate.
    if(!sprite.contentSize.width)
        return;
    
    const CGFloat parallaxRate = goalObjectPosition.origin.x / [sprite getContentSize].width;
    // calcualte current layer diff 
    diff/=parallaxRate;
    
    // 1-move layer
    CGFloat after = sprite.position.x + diff;    
    CCMoveTo* action = [CCMoveTo actionWithDuration:timing position:ccp(after,sprite.position.y)];
    [sprite runAction:action];
}

// internal method
// moving all background sprites (does parallax!!!)
-(void) scheduleMoveBackgroundLeftRight:(CGFloat)diff timing:(ccTime)timing
{
    // manual parallax
    [self scheduleMoveBackSpriteLeftRight:staticBackgroundSprite diff:diff timing:timing];
    [self scheduleMoveBackSpriteLeftRight:backgroundSpriteMoving diff:diff timing:timing];
    [self scheduleMoveBackSpriteLeftRight:foregroundSpriteMoving diff:diff timing:timing];
}

-(void) stopMoving
{
    stopMoving = YES;
}

-(BOOL) moveLayerDirectX:(CGFloat)x 
{   
    if(stopMoving)
        return NO;
    
    moveWantedPoint.x+=x;
    
    // can't move more to the left and right!
    if(moveWantedPoint.x>0)
    {
        moveWantedPoint.x = 0;
        return NO;
    }

    [self moveLayer:x y:0];
    return YES;
}

-(BOOL) moveLayerDirectY:(CGFloat)y
{   
    if(stopMoving)
        return NO;
    
    CGFloat newPosY = tileMapNode.position.y + y;
   
    // can't move more to the left and right!
    if(newPosY>0)
    {
        return NO;
    }
    
    [self moveLayer:0 y:y];
    return YES; 
}

// scaled-screen coordinates (pixels) 
-(CGPoint) getWorldOffset
{
    return ccp(MAX(0.0f,-tileMapNode.position.x), 
               MAX(0.0f,-tileMapNode.position.y)) ;
}

-(BOOL) isInFirstScreen
{
#ifndef ALLOW_MOVE_WORLD_BACK
    // don't allow to go back a screen!
    return YES;
#endif
    
    CGPoint off = [self getWorldOffset];
    return IS_NEAR(off.x,0.0f);
}

-(BOOL) isInLastScreen
{    
    CGRect screen;
    screen.origin = ccp(0,0);
    screen.size   = [[CCDirector sharedDirector] winSize];
    screen = [self toWorldCoords:screen];
    
    if(CGRectGetMaxX(screen)>=CGRectGetMaxX(goalObjectPosition))
    {
        // we are in the last screen currently!
        return YES;
    }    
    return NO;
}

- (BOOL) toScreenCoords:(CGRect*)rectWorldCoords
{
    CGPoint offset = [self getWorldOffset];
    *rectWorldCoords = CGRectOffset(*rectWorldCoords, -offset.x, -offset.y);
        
    // not visible?
    CGSize screen = [[CCDirector sharedDirector] winSize];
    if(CGRectGetMaxX(*rectWorldCoords)<0.0 || CGRectGetMinX(*rectWorldCoords)>screen.width 
       || CGRectGetMaxY(*rectWorldCoords)<0.0 || CGRectGetMinY(*rectWorldCoords)>screen.height)
        return NO;

    return YES;
}
    
- (CGRect) toWorldCoords:(CGRect)rectScreenCoords
{
    CGPoint off = [self getWorldOffset];
    return CGRectOffset(rectScreenCoords,off.x,off.y);
}
      
-(BOOL) toScreenCoordsPoint:(CGPoint*)pntWorldCoords
{
    CGPoint off = [self getWorldOffset];
    CGSize screen = [[CCDirector sharedDirector] winSize];
       
    pntWorldCoords->x-=off.x;
    pntWorldCoords->y-=off.y;
    
    if(pntWorldCoords->x<0.0 || pntWorldCoords->x>screen.width ||
       pntWorldCoords->y<0.0 || pntWorldCoords->y>screen.height )
        return NO;
    
    return YES;
}

-(CGPoint) toWorldCoordsPoint:(CGPoint)pntScreenCoords
{
    CGPoint off = [self getWorldOffset];
    pntScreenCoords.x+=off.x;
    pntScreenCoords.y+=off.y;
    return pntScreenCoords;
}

-(void) setOpacity:(GLubyte) anOpacity
{
    [backgroundSpriteMoving setOpacity:anOpacity];
    [staticBackgroundSprite setOpacity:anOpacity];
    [foregroundSpriteMoving setOpacity:anOpacity];
}
@end
