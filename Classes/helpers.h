#ifndef HELPERS_DEF_H
#define HELPERS_DEF_H

// functions
#define _countof(x)(sizeof(x)/sizeof(x[0]))

//#define LRINT lrint
#define LRINT(x)(x)

#define ccpLeft(obj,x,y) CGPointMake(x + [obj contentSize].width/2,y + [obj contentSize].height/2)

// these are calculated based on current device
// for example: we draw for iphone 3 - 480 x 320
// but current device is iPad with 1024.768 display.
extern float CurrentScaleFactorX;
extern float CurrentScaleFactorY;
extern float CurrentScaleFactorXRaw;
extern float CurrentScaleFactorYRaw;

// this is SCALE that you can use to modify game object sizes!!!
#define GLOBAL_GAME_OBJECTS_SCALE        0.65f
//#define GLOBAL_GAME_OBJECTS_SCALE        1.00f

// This one for Release!
//#define GLOBAL_GAME_OBJECTS_SCALE        0.50f 
#define GLOBAL_GAME_OBJECTS_SCALE_IPAD   0.65f

#define TILE_SIZE 32

// float comparison
#define ABS_VAL 0.3f
#define IS_NEAR(x,y)((x>=y-ABS_VAL) && (x<=y+ABS_VAL))

#define IS_SMALLER(x,y)(IS_NEAR(x,y) || x<y)
#define IS_BIGGER(x,y)(IS_NEAR(x,y) || x>y)
#define IS_STRICT_BIGGER(x,y)(x>(y+ABS_VAL))
#define IS_STRICT_SMALLER(x,y)((x+ABS_VAL)<y)

// for game objects!
// convert WorldCoordinates to pixels (screen coords)
#define RESIZE_X(x)(x * CurrentScaleFactorX)
#define RESIZE_Y(y)(y * CurrentScaleFactorY)

// If you want to initialize sprite with its size. 
#define RESIZE_SPRITE_X(x)(RESIZE_X(x) * [[UIScreen mainScreen] scale])
#define RESIZE_SPRITE_Y(y)(RESIZE_Y(y) * [[UIScreen mainScreen] scale])

// for non-game objects (buttons, controls, etc)
#define RESIZE_X_RAW(x)(x * CurrentScaleFactorXRaw)
#define RESIZE_Y_RAW(y)(y * CurrentScaleFactorYRaw)

inline unsigned int Mod2(float f)
{
    unsigned int val = (unsigned int)f;
    return 2 * (val/2); // 6,8,10,12...
}

#define RESIZE_FONT(x)(Mod2(x * CurrentScaleFactorYRaw))

// convert from pixels to world-coordinates
#define TO_WORLD_COORDS_X(x)(x/CurrentScaleFactorX)
#define TO_WORLD_COORDS_Y(y)(y/CurrentScaleFactorY)

// This method fixes object positions so that they are based on Tile sized
// For example - tile size is 32 and you pass here 33 -> it is rounded down to 32
inline int RoundSize(int val,int roundWith = TILE_SIZE )
{
    const int rounded       = (val/roundWith);
    const int rest          = (val%roundWith);    
    const bool isAddMore    = (rest>=roundWith/2);
    
    return (rounded + (isAddMore?1:0)) * roundWith;
}

#define INITIAL_HITPOINTS 5
#define BACKGROUND_SPRITE_WIDTH 1920

#endif // HELPERS_DEF_H
