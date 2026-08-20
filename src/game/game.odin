package game

import "core:fmt"
import rl "vendor:raylib"

import "src:events"
// import "src:fonts"
import render "src:render"
// import "src:logic"

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


//---------- GAME ----------\\
run :: proc() {
    rl.InitWindow(
        WINDOW_WIDTH, 
        WINDOW_HEIGHT, 
        "Sudoku Solver - Odin + Raylib 6"
    )
    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()

    game := game_init()
    font := fonts_init()
    // theme: Theme
    defer destroy(&font)

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
        theme :=  game.is_dark ? dark_theme : light_theme
        events.handle_input(game)

        rl.BeginDrawing()

            rl.ClearBackground(theme.bg)
            render.draw_grid(&game)
            render.draw_numbers(&game)
            render.draw_crosshair(&game)
            render.draw_fail_window(&game)
            render.draw_exit_window(&game)

       rl.EndDrawing() //_
    }
}
