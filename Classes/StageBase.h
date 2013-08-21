#import "cocos2d.h"
#import "SpriteEx.h"
#import "PhysicsBase.h"
//#import "ObjectBase.h"

@protocol IStage<NSObject>
    -(unsigned int)       getTimeNeeded;
    -(id<IStage>*)        getNextStage;
    -(NSString*)          getStageTitle;
    -(NSString *)         getBriefingText;
    // called when player see object that is named "Goal" object
    -(void)               goalIsVisible:(NSString*)objectName 
                               distance:(CGFloat)distance
                                 object:(id)object
                       isVerticalVisible:(BOOL)isVerticalVisible;

    -(id)                 getCurrentDialogue;
    -(int)                getStageTag;

    -(void)               startStage;
    // change the HUD color if so
    -(BOOL)               isBackgroundDark;
@end

/// NOTE: each stage must have 
//    - Collision
//    - Objects
//    - Ground 
// layers!
@interface StageBase: PhysicsBase
{
	CCTMXTiledMap* tileMapNode;
@private
// Layers
    CCTMXLayer*	   backgroundLayer;
    CCLayer*       cloudsLayer;
    NSMutableArray* enemies;
    NSMutableArray* objects;
    
    NSMutableArray* arrTmp;
    
// Sprites
    // Simple Parallax - these layers are not scaled!!!
    CCSpriteEx*    staticBackgroundSprite;
    CCSpriteEx*    backgroundSpriteMoving;
    CCSpriteEx*    foregroundSpriteMoving;
    
// Objects
    // in world-coordinates!
    CGRect         goalObjectPosition;
    
// Animations
    BOOL           nowMovingHorizontally;  
    CGPoint        moveWantedPoint;
    
// For optimization! That is the example of shitty design.
    id             player;
    BOOL           stopMoving;
}

- (id)      init;
- (void)    initEnemies;
- (void)    initObjects;
- (void)    dealloc;

// bad, but for optimization
- (void)    setPlayer:(id)player;
- (id)      getPlayer;

- (void)    step:(ccTime)delta;
- (void)    draw;

// Access methods
- (void) loadTileMap:(NSString*)fileName layerName:(NSString*)layerName;
- (CCTMXTiledMap*)  getTileMap;
- (NSMutableArray*) getEnemies;
- (NSMutableArray*) getObjects;
- (void) removeEnemy:(id)enemy;
- (void) removeObject:(id)object;

// Draw multiple clouds automatically, selecting random files and getting
// objects from tile map!
-(void) addClouds:(int)zOrder;

-(void) checkObjects;              // check that tilemap contains needed objects (like SpawnPoint,EndPoint etc)
-(id)   getObject:(NSString*)objName;
-(BOOL) getObjectPos:(NSString*)objName pnt:(CGPoint*)pnt;
-(BOOL) getObjectPosRect:(NSString*)objName rect:(CGRect*)rect;

-(NSMutableDictionary*) getObjectProperties:(NSString*)objName;
-(CGRect) getGoalObjPos;

/// \params Filenames
-(void) initBackgroundSprites:(NSString*)staticBack                 // optional
                   movingBack:(NSString*)movingBack
                   movingForeground:(NSString*)movingForeground;    // optional

-(BOOL) isInFirstScreen;
-(BOOL) isInLastScreen;

// this is direct manipulation. Will do that even if layer already moves!
-(BOOL) moveLayerDirectX:(CGFloat)x;
-(BOOL) moveLayerDirectY:(CGFloat)y;

-(void) moveObjects:(NSMutableArray*)objects 
                  x:(CGFloat)x 
                  y:(CGFloat)y
               maxX:(CGFloat)maxX;  // do not move objects that have bigger x coord

-(void) setOpacity:(GLubyte) anOpacity;

// scaled-screen coordinates (pixels) 
-(CGPoint) getWorldOffset;

// Returns YES if visible on screen
- (BOOL)   toScreenCoords:(CGRect*)rectWorldCoords;
- (CGRect) toWorldCoords:(CGRect)rectScreenCoords;

-(BOOL)     toScreenCoordsPoint:(CGPoint*)pntWorldCoords;
-(CGPoint)  toWorldCoordsPoint:(CGPoint)pntScreenCoords;

-(void) stopMoving;
-(void) darkenBackground;

@end
