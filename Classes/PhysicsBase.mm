#include "PhysicsBase.h"
#include "helpers.h"
#include "movements.h"
#include "triggers.h"
#include "timings.h"
#include "animations.h"

// BAD!!!
#define FALL_DOWN_ERROR 2 

@implementation PhysicsBase

@synthesize collisionObjects;

- (void) addCollisionObject:(CGPoint)p 
    withSize:(CGPoint)size 
    dynamic:(BOOL)d 
    rotation:(long)r 
    friction:(long)f 
    density:(long)dens 
    restitution:(long)rest 
    boxId:(int)boxId 
{
    // Adding as simple object
    CGRect rect;    
    rect.origin.x = p.x;
    rect.origin.y = p.y;
    rect.size.width = size.x;
    rect.size.height= size.y;    
    [collisionObjects addObject:[NSValue valueWithCGRect:rect]];
}

- (void) sortCollisionObjects
{
    // simple slow bubble sort. But we don't care!
    for(size_t i=0; i<[collisionObjects count]; ++i)
    {
        for(size_t j=0; j<[collisionObjects count]-1; ++j)
        {
            NSValue* value  = [collisionObjects objectAtIndex:j];
            NSValue* value2 = [collisionObjects objectAtIndex:j+1];
            
            CGRect rectOriginal  = [value  CGRectValue];
            CGRect rectOriginal2 = [value2 CGRectValue];
            
            if(rectOriginal2.origin.x < rectOriginal.origin.x)
            {
                // swap
                [collisionObjects replaceObjectAtIndex:j    withObject:value2];
                [collisionObjects replaceObjectAtIndex:j+1  withObject:value];
            }
        }
    }
    
#ifdef _DEBUG
    // check that everything is OK
    for(size_t i=0; i<[collisionObjects count]-1; ++i)
    {
        NSValue* value  = [collisionObjects objectAtIndex:i];
        NSValue* value2 = [collisionObjects objectAtIndex:i+1];
        
        CGRect rectOriginal  = [value  CGRectValue];
        CGRect rectOriginal2 = [value2 CGRectValue];
        
        NSAssert(rectOriginal.origin.x<=rectOriginal2.origin.x,@"Sort failed");
    }
#endif
}

- (void) initCollisions:(CCTMXTiledMap*)tileMapNode 
              objectLayerName:(NSString*)objectLayerName
{
    // Init stuff
    isIntersectionTempRect  = [[NSMutableArray alloc]init]; // temporary
    collisionObjects        = [[NSMutableArray alloc]init];
    b2Vec2 gravity = b2Vec2(0.0f, -9.8f);
    
    //bool doSleep = true;
    //world = new b2World(gravity, doSleep);
    
    // Init collision objects!
    CCTMXObjectGroup* objects = [tileMapNode objectGroupNamed:objectLayerName];
    NSMutableDictionary* objPoint;
    
    // 7 * 32  = 224
    int x, y, w, h;	
    for (objPoint in [objects objects]) 
    {      
        x = RESIZE_X(RoundSize([[objPoint valueForKey:@"x"] intValue]));
        y = RESIZE_Y(RoundSize([[objPoint valueForKey:@"y"] intValue]));
        w = RESIZE_X(RoundSize([[objPoint valueForKey:@"width"] intValue]));
        h = RESIZE_Y(RoundSize([[objPoint valueForKey:@"height"] intValue]));	
        
        CGPoint _point=ccp(x,y);
        CGPoint _size=ccp(w,h);
        
        [self addCollisionObject:_point 
                        withSize:_size 
                         dynamic:false 
                        rotation:0 
                        friction:0.0f 
                         density:0.0f 
                     restitution:0 
                           boxId:-1];
    }
    
    // now sort all collision objects
    [self sortCollisionObjects];
}

-(void)dealloc
{
    [collisionObjects release];
    [isIntersectionTempRect release];
    [super dealloc];
}

- (void) getObjects:(CGRect)rect 
             arrOut:(NSMutableArray*)arrOut
{
    // do non-strict intersection!
    rect.origin.x-=ABS_VAL;
    rect.size.width-=ABS_VAL;
    rect.origin.y-=ABS_VAL;
    rect.size.height-=ABS_VAL;
    
    const CGFloat maxScreen = rect.origin.x + rect.size.width + CLIP_OBJECTS_X_VAL;
    
    for(NSValue* value in collisionObjects)
    {
        CGRect rectOriginal = [value CGRectValue];         
        if(rectOriginal.origin.x>maxScreen)
            break;  // stop
        
        if(!CGRectIsNull(CGRectIntersection(rectOriginal,rect)))
        {
            // add to array
            [arrOut addObject:[NSValue valueWithCGRect:rectOriginal]];
        }
    }
}

- (BOOL) isIntersectingSomething:(CGRect)worldCoords
{
    // optimize
    worldCoords.origin.x-=ABS_VAL;
    worldCoords.size.width-=ABS_VAL;
    worldCoords.origin.y-=ABS_VAL;
    worldCoords.size.height-=ABS_VAL;
    
    const CGFloat maxScreen = worldCoords.origin.x + CLIP_OBJECTS_X_VAL;
    
    for(NSValue* value in collisionObjects)
    {
        CGRect rectOriginal = [value CGRectValue];         
        if(rectOriginal.origin.x>maxScreen)
            break;  // stop
        
        if(!CGRectIsNull(CGRectIntersection(rectOriginal,worldCoords)))
        {
            return YES;
        }
    }

    return NO;
}

// optimized version - two collision at once
- (BOOL) isIntersectingSomething:(CGRect)rect1
                     rectCurrent:(CGRect)rect2
{
    // do non-strict intersection!
    rect1.origin.x-=ABS_VAL;
    rect1.size.width-=ABS_VAL;
    rect1.origin.y-=ABS_VAL;
    rect1.size.height-=ABS_VAL;
    
    rect2.origin.x-=ABS_VAL;
    rect2.size.width-=ABS_VAL;
    rect2.origin.y-=ABS_VAL;
    rect2.size.height-=ABS_VAL;
    
    const CGFloat maxScreen = rect1.origin.x + CLIP_OBJECTS_X_VAL;
    
    for(NSValue* value in collisionObjects)
    {
        CGRect rectOriginal = [value CGRectValue];         
        if(rectOriginal.origin.x>maxScreen)
            break;  // stop
        
        if(!CGRectIsNull(CGRectIntersection(rectOriginal,rect1)) || 
           !CGRectIsNull(CGRectIntersection(rectOriginal,rect2)))
        {
            // add to array
            return YES;
        }
    }

    return NO;
}

- (BOOL) isIntersection:(CGRect)obj1 obj2:(CGRect)obj2
{
    return !CGRectIsNull(CGRectIntersection(obj1,obj2));
}

// NOTE:
// 1 - Player rect is in world coordinates!
// 2 - Returns maximum jump height after looking for intersections.
- (CGFloat) getNearestObjectTop:(CGRect)playerRect 
                   wantedHeight:(CGFloat)wantedHeight
            objectsIntersecting:(NSMutableArray*)objectsIntersecting
{    
    // inflate rectangle UP!
    CGRect rectPlayerTmp = playerRect;
    rectPlayerTmp.size.height+=wantedHeight;
    
    // we don't care about STRICT size! All objects in game are BLOCK_SIZEd but
    // floating points caused error -> so little deflation of player RECT is OK
    rectPlayerTmp.size.width-=4;
    rectPlayerTmp.origin.x+=2;
    
    // Get intersection physical objects   
    [objectsIntersecting removeAllObjects];
    [self getObjects:rectPlayerTmp arrOut:objectsIntersecting];
    
    // sort these intersection so that the lowest will be returned as suggested height!
    CGFloat searchForLowestObject = INT_MAX;
    if([objectsIntersecting count]!=0)
    {
        for(NSValue* value in objectsIntersecting)
        {
            CGRect rectOriginal = [value CGRectValue];
            
            // non-strict comparisons!!!
            const CGFloat l       = CGRectGetMinY(rectOriginal);
            const CGFloat playerL = CGRectGetMaxY(playerRect);
            
            const CGFloat objX    = CGRectGetMinX(rectOriginal);
            const CGFloat playerX = CGRectGetMaxX(playerRect); 
            
            const CGFloat objX2    = CGRectGetMaxX(rectOriginal);
            const CGFloat playerX2 = CGRectGetMinX(playerRect);
            
            const BOOL isHorizontalNotGood = (IS_STRICT_BIGGER(objX,playerX) ||
                                              IS_STRICT_SMALLER(objX2,playerX2) );
            
            if( !isHorizontalNotGood && IS_STRICT_BIGGER(l,playerL)
               &&
               searchForLowestObject>=(l - playerL))
            {
                // subtract GROUND position!!!
                searchForLowestObject = l - playerL;
            }
        }
    }
    
    if(searchForLowestObject==INT_MAX)
        return wantedHeight;
    else
    {
        if(searchForLowestObject<0.0f)
            searchForLowestObject = 0.0f;
        
        return searchForLowestObject;
    }
}

// returns positiong of nearest object
- (CGFloat) getNearestObjectRight:(CGRect)playerRect
                        worldRect:(CGRect)worldRect
              objectsIntersecting:(NSMutableArray*)objectsIntersecting
{    
    [objectsIntersecting removeAllObjects];
    [self getObjects:worldRect arrOut:objectsIntersecting];
    
    // sort these intersection so that the lowest will be returned as suggested height!
    CGFloat nearestObject = INT_MAX;
    if([objectsIntersecting count]!=0)
    {
        for(NSValue* value in objectsIntersecting)
        {
            CGRect rectOriginal = [value CGRectValue];
            
            const BOOL isVerticalNotGood = (CGRectGetMinY(rectOriginal)>=CGRectGetMaxY(playerRect) ||
                                            CGRectGetMaxY(rectOriginal)<=CGRectGetMinY(playerRect) );
            
            const CGFloat objLeft = CGRectGetMinX(rectOriginal);
            const CGFloat r = playerRect.origin.x + playerRect.size.width;
            
            // WARNING: anti-error constant :-)
            if( !isVerticalNotGood && IS_BIGGER(objLeft + 3,r) &&
               nearestObject>=objLeft )
            {
                nearestObject = objLeft;
            }            
        }
    }
    
    if(IS_SMALLER(nearestObject,0.0f))
        nearestObject = INT_MAX;
    
    return nearestObject;
}

- (CGFloat) getNearestObjectLeft:(CGRect)playerRect
                       worldRect:(CGRect)worldRect
             objectsIntersecting:(NSMutableArray*)objectsIntersecting
{
    [objectsIntersecting removeAllObjects];
    [self getObjects:worldRect arrOut:objectsIntersecting];
    
    // sort these intersection so that the lowest will be returned as suggested height!
    CGFloat nearestObject = -1.0;
    if([objectsIntersecting count]!=0)
    {
        for(NSValue* value in objectsIntersecting)
        {
            CGRect rectOriginal = [value CGRectValue];
            
            const BOOL isVerticalNotGood = ((CGRectGetMinY(rectOriginal)>=playerRect.origin.y + playerRect.size.height) ||
                                            CGRectGetMaxY(rectOriginal)<=playerRect.origin.y );
            
            const CGFloat objRight = CGRectGetMaxX(rectOriginal);
            const CGFloat l        = playerRect.origin.x;
            
            if( !isVerticalNotGood && IS_SMALLER(objRight,l) && 
               nearestObject<=objRight )
            {
                nearestObject = objRight;
            }
            
        }
    }
    
    if(IS_NEAR(nearestObject,-1.0))
        nearestObject = 0;
    
    return nearestObject;
}

// Return difference beetween ground and player pos (for example, while jumping)
// It does collision detection
- (CGFloat) getDiffGround:(CGRect)playerPosWorldCoords
{  
    // adjust a little bit to avoid unnecesarry coliisions!
    playerPosWorldCoords.origin.x+=FALL_DOWN_ERROR;
    playerPosWorldCoords.size.width-=FALL_DOWN_ERROR;
    playerPosWorldCoords.size.width-=FALL_DOWN_ERROR;
    
    // rect goes down
    CGRect rect = playerPosWorldCoords;
    rect.origin.y    = 0;
    rect.size.height = playerPosWorldCoords.origin.y; // + (playerPosWorldCoords.size.height/2);
    
    // find all intersections
    // Get intersection physical objects  
    //NSMutableArray* objs = [[NSMutableArray alloc]init];
    [isIntersectionTempRect removeAllObjects];
    [self getObjects:rect arrOut:isIntersectionTempRect];
    
    // sort these intersection so that the lowest will be returned as suggested height!
    CGFloat searchForHighestObject = INT_MAX;
    if([isIntersectionTempRect count]!=0)
    {
        for(NSValue* value in isIntersectionTempRect)
        {
            CGRect rectOriginal = [value CGRectValue];
            
            const CGFloat l       = CGRectGetMaxY(rectOriginal);
            const CGFloat playerL = CGRectGetMinY(playerPosWorldCoords);
            //const CGFloat playerM = playerL + (playerPosWorldCoords.size.height/2);
            
            const CGFloat objLeft     = CGRectGetMinX(rectOriginal);
            const CGFloat playerRight = CGRectGetMaxX(playerPosWorldCoords);
            
            const CGFloat objRight   = CGRectGetMaxX(rectOriginal);
            const CGFloat playerLeft = CGRectGetMinX(playerPosWorldCoords);
            
            const BOOL isHorizontalNotGood = (IS_STRICT_BIGGER(objLeft,playerRight) ||
                                              IS_STRICT_SMALLER(objRight,playerLeft) );
            
            if( !isHorizontalNotGood)
            {
                if(IS_SMALLER(l,playerL) && searchForHighestObject>=(playerL - l))
                {
                    // subtract GROUND position!!!
                    searchForHighestObject = playerL - l;
                }
                /*
                else if(IS_SMALLER(l,playerM))
                {
                    return 0;                    
                }*/
            }
        }
    }
    
    return searchForHighestObject;
}

@end