#ifndef LittlePoo_animations_h
#define LittlePoo_animations_h

#include "timings.h"
#include "movements.h"

#define FULL_MOVE_TIME          (SINGLE_BLOCK_MOVE_TIMING)
#define MOVE_PIXELS_PER_SECOND  (BLOCK_SIZE / SINGLE_BLOCK_MOVE_TIMING)

#define FULL_JUMP_TIME          (2 * (JUMP_AMOUNT_Y/BLOCK_SIZE_Y) * SINGLE_BLOCK_JUMP_TIMING)
#define JUMP_PIXELS_PER_SECOND  (BLOCK_SIZE_Y / SINGLE_BLOCK_JUMP_TIMING)

#define CAMERA_MOVEMENT_SPEED_X  (JUMP_PIXELS_PER_SECOND / 4)
#define CAMERA_MOVEMENT_SPEED_Y  (JUMP_PIXELS_PER_SECOND / 2)

#endif