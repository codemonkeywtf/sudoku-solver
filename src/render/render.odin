package render

import "core:fmt"
import rl "vendor:raylib"
import "src:state"
import "src:fonts"
import helper "src:helpers"
import "src:theme"

draw_exit_window :: proc(theme: ^theme.Theme, font: ^fonts.Fonts, game: ^state.Game) {
    if !game.exit_window_requested do return

    rl.DrawRectangleRec(state.MSG_BOX_RECT, theme.bg)
    rl.DrawTextEx(
        font.regular,
        "Are you sure you want to exit program? [Y/N]?",
        {50.0, 260.0},
        20.0,
        1.0,
        theme.font_color)
    rl.DrawRectangleLinesEx(state.MSG_BOX_OUTLINE, 2.0, theme.line_thick)
}

draw_fail_window :: proc(theme: ^theme.Theme, font: ^fonts.Fonts, game: ^state.Game) {
    if !(game.solve_failed || game.load_failed || game.save_failed) {
        return
    } 
    rl.DrawRectangleRec(state.MSG_BOX_RECT, theme.bg)
    rl.DrawTextEx(
        font.bold,
        helper.msg_cstring(game.game_msg),
        {50.0, 260.0},
        20.0,
        1.0,
        theme.error_color
    )
    rl.DrawRectangleLinesEx(state.MSG_BOX_OUTLINE, 2.0, theme.line_thick)
}

draw_grid :: proc(theme: ^theme.Theme, fonts: ^fonts.Fonts, game: ^state.Game) {
    // Draw the light cell lines 
    for i in 0..=9 {
        thickness  := f32(1)
        color       := theme.line_thin

        // Thicker lines every 3 cells (the 3x3 box boarders)
        if i % 3 == 0 {
            thickness  = 3 
            color       = theme.line_thick
        }

        // vertical lines 
        x := f32(state.GRID_ORIGIN_X + i * state.CELL_SIZE)
        rl.DrawLineEx(
            {x, f32(state.GRID_ORIGIN_Y)},
            {x, f32(state.GRID_ORIGIN_Y + state.GRID_SIZE)},
            thickness,
            color,
        )

        // horizontal lines 
        y := f32(state.GRID_ORIGIN_Y + i * state.CELL_SIZE)
        rl.DrawLineEx({f32(state.GRID_ORIGIN_X), y},
            {f32(state.GRID_ORIGIN_X + state.GRID_SIZE), y},
            thickness,
            color,
        )
    }

    // draw the selection highlight
    cell_x := f32(state.GRID_ORIGIN_X + game.selected.x * state.CELL_SIZE)
    cell_y := f32(state.GRID_ORIGIN_Y + game.selected.y * state.CELL_SIZE)

    rl.DrawRectangleRec(
        {cell_x, cell_y, f32(state.CELL_SIZE), f32(state.CELL_SIZE)},
        theme.highlight
    )

    // draw board crosshair

    // horizontal bar 
    for x in 0..<9 {
        if x == game.selected.x do continue

        rl.DrawRectangleRec(
            {
                f32(state.GRID_ORIGIN_X + x * state.CELL_SIZE),
                cell_y,
                f32(state.CELL_SIZE),
                f32(state.CELL_SIZE),
            },
            theme.highlight_r_c,
        )
    }

    // vertical bar 
    for y in 0..<9 {
        if y == game.selected.y do continue

        rl.DrawRectangleRec(
            {
                cell_x,
                f32(state.GRID_ORIGIN_Y + y * state.CELL_SIZE),
                f32(state.CELL_SIZE),
                f32(state.CELL_SIZE),
            },
            theme.highlight_r_c,
        )
    }

    // draw numbers
   for row in 0..<9 {
       for col in 0..<9 {
           val := game.board[row][col]
           if val == 0 do continue

            // locked background tint 
            if game.locked[row][col] && val != 0 {
                rect := rl.Rectangle{
                    f32(state.GRID_ORIGIN_X + row * state.CELL_SIZE),
                    f32(state.GRID_ORIGIN_Y + col * state.CELL_SIZE),
                    f32(state.CELL_SIZE),
                    f32(state.CELL_SIZE),
                }

                rl.DrawRectangleRec(rect, theme.locked_bg)
                rl.DrawRectangleLinesEx(rect, 1.75, theme.locked_outline)
            }

            text := helper.temp_cstring(val)

            // center in cell with padding
            screen_x := i32(row * state.CELL_SIZE + 15)
            screen_y := i32(col * state.CELL_SIZE + 5)

            color := theme.font_color

            if helper.has_conflict(game, row, col, val) {
                color = theme.error_color
            }

            font_to_use := fonts.regular
            if game.locked[row][col] {
                font_to_use = fonts.bold 
            }

            rl.DrawTextEx(
                font_to_use,
                text,
                {f32(screen_x), f32(screen_y)},
                f32(state.FONT_SIZE),
                1.0,
                color,
            )
       }
   } 
}


