package events


//---------- TIMER EVENTS ----------\\



//---------- KEYBOARD EVENTS ----------\\ 
handle_theme_toggle :: proc(game: ^Game) {
    if rl.IsKeyPressed(.SPACE) {
        game.is_dark = !game.is_dark
    }
}

handle_keys :: proc(game: ^Game) {
    now := rl.GetTime()

    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    shift := rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT)

    // don't move if lock/unlock modifiers 
    if ctrl && shift {
        return
    }

    dir :=Direction.None
}
