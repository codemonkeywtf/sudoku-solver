package events

import "src:state"
//---------- ORCHESTRATOR ----------\\

handle_input :: proc(game: ^state.Game) {
    handle_theme_toggle(game)
    handle_keys(game)
    handle_tab_navigation(game)
    handle_lock_keys(game)
    handle_get_number(game) 
    handle_mouse_click(game)
}

