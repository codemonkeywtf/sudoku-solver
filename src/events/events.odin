package events

import rl "vendor:raylib"
import v "vecs"
import "core:math"
import "core:strings"
import "state"

//---------- MOUSE EVENTS ----------\\
handle_input :: proc(game: ^Game) {
    handle_theme_toggle(game)
    handle_keys(game)
    handle_tab_navigation(game)
    handle_lock_keys(game)
    handle_get_number(game)
    handle_mouse_click(game)
}

