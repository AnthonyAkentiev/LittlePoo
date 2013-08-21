#ifndef LittlePoo_triggers_h
#define LittlePoo_triggers_h

#ifdef _DEBUG
    #define TEST_RUN
#endif

// When player gets to close to gap -> fall in it!
//#define FALL_IN_GAP_IF_GOT_NEAR

//#define NO_DEATH

#define DO_FOLLOW_PLAYER_CAMERA_Y

#define ALLOW_MOVE_WORLD_BACK

// when touched enemy -> kill it
//#define REMOVE_ENEMY_IF_TOUCHED

// ******************************** 
// ******************************** These defines are for DEBUG only!!!
#ifdef TEST_RUN
    //#define SCROLL_TO_SPAWN

    // will highlight collision boxes, etc...
    //#define DRAW_PHYSICS_OBJS

    // no 146% left countdown!
    //#define DONT_COUNT_TIME

    #define PLAY_BACKGROUND_MUSIC

    //#define SHOW_FPS_VAL

    //#define UNLOCK_ALL_STAGES
#else
    #define PLAY_BACKGROUND_MUSIC

    //#define SHOW_FPS_VAL
#endif // TEST_RUN

// ********************************
// ******************************** 

#endif
