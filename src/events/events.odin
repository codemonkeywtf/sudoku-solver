package events

import "src:state"
//---------- ORCHESTRATOR ----------\\

handle_input :: proc(game: ^state.Game) {
    if game.solve_failed || game.load_failed || game.save_failed {
        handle_fail_all(game)
        return
    }

    handle_theme_toggle(game)
    handle_keys(game)
    handle_tab_navigation(game)
    handle_lock_keys(game)
    handle_get_number(game) 
    handle_mouse_click(game)
    handle_solve_key(game)
    // handle_fail_all(game)
    handle_save_key(game)
    handle_open_key(game)
}
