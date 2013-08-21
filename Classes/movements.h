#ifndef LittlePoo_movements_h
#define LittlePoo_movements_h

#include "helpers.h"

/////////// pixels on single button click/iteration:
#define BLOCK_SIZE  RESIZE_X(32)
#define BLOCK_SIZE_Y RESIZE_Y(32)
#define LEFTRIGHT_MOVE 2 * BLOCK_SIZE

#define ENEMY_COLLISION_RECT_WIDTH (BLOCK_SIZE/4)

// jumping N blocks high.
#define JUMP_AMOUNT_Y (BLOCK_SIZE_Y * 8)

// in screen width percentage.
#define DIALOGUE_START_WHEN_REACHED (1.2f/3.0f)

// do not draw/animate/update Objects that has x value bigger than:
#define CLIP_OBJECTS_X_VAL 300

#define MINIMUM_JUMP_TIME 0.2

#endif
