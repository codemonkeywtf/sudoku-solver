package main

import rl "vendor:raylib"
import v "vecs"

Game :: struct {
    board:                  [9][9]int,
    dir:                    Direction,
    exit_window:            bool,
    exit_window_requested:  bool,
    is_dark:                bool,
    is_first_move:          bool,
    is_locked:              bool,
    last_move_time:         f64,
    locked:                 [9][9]bool,
    selected:               v.V2,
    space_num:              bool,
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
    g: Game
    g.exit_window_requested = false
    g.exit_window = false 
    g.is_dark = true
    g.is_first_move = true
    g.is_locked = false 

    return g
}
