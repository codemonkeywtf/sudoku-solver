package events

import "core:fmt"
import rl "vendor:raylib"
import "src:state"
import "src:logic"

//---------- TIMER EVENTS ----------\\



//---------- KEYBOARD EVENTS ----------\\ 
handle_theme_toggle :: proc(game: ^state.Game) {
    if rl.IsKeyPressed(.SPACE) {
        game.is_dark = !game.is_dark
    }
}

handle_keys :: proc(game: ^state.Game) {
    dir := state.Direction.None

    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    shift := rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT)
    alt := rl.IsKeyDown(.LEFT_ALT) || rl.IsKeyDown(.RIGHT_ALT)

    // don't move if lock/unlock modifiers 
    if ctrl && shift || alt || ctrl {
        return
    }
    
    now := rl.GetTime()
    
    switch {
    case rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.L) || rl.IsKeyDown(.D)   :
        dir = .Right
    case rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.H) || rl.IsKeyDown(.A)    :
        dir = .Left
    case rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J) || rl.IsKeyDown(.S)    :
        dir = .Down
    case rl.IsKeyDown(.UP) || rl.IsKeyDown(.K) || rl.IsKeyDown(.W)      :
        dir = .Up
    }

    if dir == .None {
        game.is_first_move = true
        return
    }

    delay := game.is_first_move ? state.MOVE_INITIAL_DELAY : state.MOVE_REPEAT_RATE

    if now - game.last_move_time < delay {
        return
    }

    switch dir {
    case .Right:
        game.selected.x = (game.selected.x + 1)     % 9
    case .Left:
        game.selected.x = (game.selected.x - 1 + 9) % 9
    case .Down:
        game.selected.y = (game.selected.y + 1)     % 9
    case .Up:
        game.selected.y = (game.selected.y - 1 + 9) % 9
    case .None:
    }

    game.last_move_time = now
}

handle_tab_navigation :: proc(game: ^state.Game) {
    block: [2]int = {game.selected.x / 3, game.selected.y / 3}
    
    // tab jump to next 3x3 block 
    if rl.IsKeyPressed(.TAB) && !rl.IsKeyDown(.LEFT_SHIFT) &&
        !rl.IsKeyDown(.RIGHT_SHIFT) {
            block[0] += 1
            if block[0] > 2 {
                block[0] = 0
                block[1] += 1
                if block[1] > 2 {
                    block[0] = 0
                    block[1] = 0
                }
            }
            game.selected.x = block[0] * 3
            game.selected.y = block[1] * 3
    }

    // shift + tab jump to prev 3x3 block
    if rl.IsKeyPressed(.TAB) && (rl.IsKeyDown(.LEFT_SHIFT) ||
        rl.IsKeyDown(.RIGHT_SHIFT)) {
         block[0] -= 1
         if block[0] < 0 {
             block[0] = 2
             block[1] -= 1
             if block[1] < 0 {
                 block[1] = 2
             }
         }
        game.selected.x = block[0] * 3
        game.selected.y = block[1] * 3
    }
        
}

// lock the cells, make them immutable
handle_lock_keys :: proc(game: ^state.Game) {
    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    shift := rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT)

    // lock every cell that currently has a number
    if ctrl && shift && rl.IsKeyPressed(.L) {
        game.is_locked = !game.is_locked
        for r in 0..<9 {
            for c in 0..<9 {
                if game.board[r][c] != 0 && game.is_locked {
                    game.locked[r][c] = game.is_locked
                } else {
                    game.locked[r][c] = false
                }
            }
        }
    }

    // clear unlocked cells 
    if ctrl && shift && rl.IsKeyPressed(.C) {
        for r in 0..<9 {
            for c in 0..<9 {
                if game.locked[r][c] == false {
                    game.board[r][c] = 0
                }
            }
        }
    }
}

handle_get_number :: proc(game: ^state.Game) {
    if game.locked[game.selected.x][game.selected.y] {
        return
    }

    digit := game.board[game.selected.x][game.selected.y]
    key := rl.GetCharPressed()
    if key >= '1' && key <= '9' {
        digit = int(key - '0')
    } else if rl.IsKeyPressed(.BACKSPACE) || rl.IsKeyPressed(.DELETE){
        digit = 0
    }
    game.board[game.selected.x][game.selected.y] = digit
}

// ALT + S Handle Solve 
handle_solve_key :: proc(game: ^state.Game) {
    if rl.IsKeyDown(.RIGHT_ALT) || rl.IsKeyDown(.LEFT_ALT) && rl.IsKeyPressed(.S) { 
        _ = logic.solve(game)
    }
}

handle_close_fail :: proc(game: ^state.Game) {
    if game.solve_failed {
        if rl.IsKeyPressed(.ENTER) && game.solve_failed {
            game.solve_failed = false
        }
    }
        return
}

handle_save_key :: proc(game: ^state.Game) {
    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    if ctrl && rl.IsKeyPressed(.S) {
        path, ok := logic.save_puzzle(game)
        if ok {
            fmt.println("saved:", path)
        } else {
            fmt.println("save failed to:", path)
        }
    }
}

handle_open_key :: proc(game: ^state.Game) {
    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    if ctrl && rl.IsKeyPressed(.O) {
        path := "./puzzles/easy/b57440bd0176d33f.sudoku"
        logic.load_puzzle(game, path)
    }
}
