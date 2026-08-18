package state

import rl "vendor:raylib"
import v "src:vecs"

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
MSG_BOX_RECT        :: rl.Rectangle {
                        20,
                        220,
                        f32(WINDOW_WIDTH - 50),
                        100,
}
MSG_BOX_OUTLINE     :: rl.Rectangle {
                        20,
                        220,
                        WINDOW_WIDTH - 50,
                        100,
}
SAVE_DIR_PARTS      :: []string{"puzzles", "easy"}

App_Phase :: enum {
    Playing,
    Confirm_Quit,
    Fail_Modal,
}

Game :: struct {
    phase:              App_Phase,
    board:                  [9][9]int,
    exit_window:            bool,
    exit_window_requested:  bool,
    is_dark:                bool,
    is_first_move:          bool,
    is_locked:              bool,
    last_move_time:         f64,
    locked:                 [9][9]bool,
    selected:               v.V2,
    solve_failed:           bool,
    save_failed:            bool,
    load_failed:            bool,
    game_msg:               string,
}

Direction :: enum {
    None,
    Left,
    Right,
    Up,
    Down,
}

File_Action :: enum {
    Load,
    Save,
}

// init global variables
game_init :: proc() -> Game {
    return Game {
        is_dark         = true,
        is_first_move   = true,
    }
}
