package game

import rl "vendor:raylib"
import v "src:vecs"

App_Phase :: enum {
    Playing,
    Confirm_Quit,
    Fail_Modal,
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

Game :: struct {
    board:                  [9][9]int,
    direction:              Direction,
    exit_window:            bool,
    exit_window_requested:  bool,
    file_action:            File_Action,
    is_dark:                bool,
    is_first_move:          bool,
    is_locked:              bool,
    last_move_time:         f64,
    locked:                 [9][9]bool,
    phase:              App_Phase,
    selected:               v.V2,
    solve_failed:           bool,
    save_failed:            bool,
    theme:                  Theme,
    load_failed:            bool,
    game_msg:               string,
}


// init global variables
game_init :: proc() -> Game {
    return Game {
        is_dark         = true,
        is_first_move   = true,
        phase           = .Playing,
        theme           = dark_theme,
    }
}
