package game

// {{{ odin-imports
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
// }}}
// {{{ sudoku-solver-imports
import "src:events"
import mouse "src:events"
import "src:fonts"
import render "src:render"
import "src:state"
import "src:theme"
import v "src:vecs"
// }}}

//---------- GAME ----------\\
run :: proc() {
    rl.InitWindow(
        state.WINDOW_WIDTH, 
        state.WINDOW_HEIGHT, 
        "Sudoku Solver - Odin + Raylib 6"
    )
    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()

    game := state.game_init()
    font := fonts.init()

    for !game.exit_window {
        //---------- to close or not to close ----------\\
        if rl.WindowShouldClose() || rl.IsKeyPressed(.ESCAPE) {
            game.exit_window_requested = true 
        }

        if game.exit_window_requested {
            if rl.IsKeyPressed(.Y) {
                game.exit_window = true 
            } else if rl.IsKeyPressed(.N) {
                game.exit_window_requested = false
            }
        }
        theme :=  game.is_dark ? theme.dark_theme : theme.light_theme

        //---------- event handlers ----------\\
        events.handle_get_number(&game, &theme)
        events.handle_keys(&game)
        events.handle_lock_keys(&game)
        mouse.handle_mouse_click(&game)
        events.handle_tab_navigation(&game)
        events.handle_theme_toggle(&game)


        //---------- DRAW----------\\
        rl.BeginDrawing()

            rl.ClearBackground(theme.bg)
            render.draw_grid(&theme, &font, &game)
            render.draw_exit_window(&theme, &font, &game)

       rl.EndDrawing()
    }
}
