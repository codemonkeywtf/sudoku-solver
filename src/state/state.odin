package state

import rl "vendor:raylib"
import v "../vecs"

// ------------------------------------------------------------
// Constants
// ------------------------------------------------------------
CELL_SIZE           :: 60
DX                  :: CELL_SIZE
DY                  :: CELL_SIZE
FONT_SIZE           :: 0.9 * CELL_SIZE
GRID_ORIGIN_X       :: 0
GRID_ORIGIN_Y       :: 0
GRID_SIZE           :: 9 * CELL_SIZE
MOVE_COOLDOWN       :: 0.19
MOVE_INITIAL_DELAY  :: 0.28
MOVE_REPEAT_RATE    :: 0.11
WINDOW_HEIGHT       :: 620          // extra space below for buttons later
WINDOW_WIDTH        :: 540

Game :: struct {
    board:                  [9][9]int,
//    dir:                    Direction,
    exit_window:            bool,
    exit_window_requested:  bool,
    is_dark:                bool,
    is_first_move:          bool,
    is_locked:              bool,
    last_move_time:         f64,
    locked:                 [9][9]bool,
    selected:               v.V2,
    // add more fields later as needed
}

Direction :: enum {
    None,
    Left,
    Right,
    Up,
    Down,
}

// init global variables
game_init :: proc() -> Game {
    return Game {
        is_dark         = true,
        is_first_move   = true,
    }
}
