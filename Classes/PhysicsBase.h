#include "cocos2d.h"
#include "Box2D/Box2D.h"

@interface PhysicsBase: CCLayer
{
@protected  
    // all of these objects are in Scaled screen coordinates.
    NSMutableArray* collisionObjects;
    
    NSMutableArray* isIntersectionTempRect;
}

@property(nonatomic,readonly,retain) NSMutableArray* collisionObjects;

- (void) initCollisions:(CCTMXTiledMap*)tileMapNode objectLayerName:(NSString*)objectLayerName;

// Searches for rects that are visible on screen.
- (void) getObjects:(CGRect)rect arrOut:(NSMutableArray*)arrOut;

- (BOOL) isIntersectingSomething:(CGRect)worldCoords;
// optimized version. do that for 2 rects at once!
- (BOOL) isIntersectingSomething:(CGRect)rect1
                     rectCurrent:(CGRect)rect2;

// NOTE:
// 1 - Player rect is in world coordinates! Not screen coordinates!
// 2 - Returns maximum jump height after looking for intersections.
- (CGFloat) getNearestObjectTop:(CGRect)playerRect 
                   wantedHeight:(CGFloat)wantedHeight
            objectsIntersecting:(NSMutableArray*)objectsIntersecting;

// playerRect is in world coordinates
// returns positiong of nearest object (to the right)
- (CGFloat) getNearestObjectRight:(CGRect)playerRect
                        worldRect:(CGRect)worldRect
              objectsIntersecting:(NSMutableArray*)objectsIntersecting;

// playerRect is in world coordinates
// returns positiong of nearest object (to the left)
- (CGFloat) getNearestObjectLeft:(CGRect)playerRect
                        worldRect:(CGRect)worldRect
             objectsIntersecting:(NSMutableArray*)objectsIntersecting;

// Return difference beetween ground and player pos (for example, while jumping)
// It does collision detection
- (CGFloat) getDiffGround:(CGRect)playerPosWorldCoords;

-(BOOL)isIntersection:(CGRect)obj1 obj2:(CGRect)obj2;
@end

