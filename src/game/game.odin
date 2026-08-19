package game

// {{{ odin-imports
import "core:fmt"
import rl "vendor:raylib"

// }}}
// {{{ sudoku-solver-imports
import "src:events"
import "src:fonts"
import render "src:render"
import "src:state"
import "src:theme"
import "src:logic"
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
    defer fonts.destroy(&font)

    //----------  game loop ----------\\
    for !game.exit_window {
        //---------- to close or not to close ----------\\
        if rl.WindowShouldClose() || rl.IsKeyPressed(.Q) {
            if game.phase == .Playing {
                game.phase = .Confirm_Quit
            }
        }

        if game.phase == .Confirm_Quit {
            if rl.IsKeyPressed(.Y) {
                game.exit_window = true 
            } else if rl.IsKeyPressed(.N) {
                game.phase = .Playing
            }
        }//_
        theme :=  game.is_dark ? theme.dark_theme : theme.light_theme
        events.handle_input(&game)

        rl.BeginDrawing()

            rl.ClearBackground(theme.bg)
            render.draw_grid(&theme, &font, &game)
            render.draw_numbers(&theme, &font, &game)
            render.draw_crosshair(&theme, &game)
            render.draw_fail_window(&theme, &font, &game)
            render.draw_exit_window(&theme, &font, &game)

       rl.EndDrawing() //_
    }
}
