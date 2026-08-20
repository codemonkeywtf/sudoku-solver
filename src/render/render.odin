package render

import rl "vendor:raylib"
import "core:fmt"

import helper "src:helpers"
import "src:game/fonts"

//---------- render exit modal ----------\\
draw_exit_window :: proc(game: ^game.Game) {
	if game.phase == .Playing do return

	rl.DrawRectangleRec(state.MSG_BOX_RECT, theme.bg)
	rl.DrawTextEx(
		font.regular,
		"Are you sure you want to exit program? [Y/N]?",
		{50.0, 260.0},
		20.0,
		1.0,
		theme.font_color,
	)
	rl.DrawRectangleLinesEx(state.MSG_BOX_OUTLINE, 2.0, theme.line_thick)
} //_

//------ render fail modal ----------\\
draw_fail_window :: proc(game: ^game.Game) {
	if game.phase == .Playing do return

	if !(game.solve_failed || game.load_failed || game.save_failed) {
		return
	}
	rl.DrawRectangleRec(state.MSG_BOX_RECT, theme.bg)
	rl.DrawTextEx(
		game.font.bold,
		helper.msg_cstring(game.game_msg),
		{50.0, 260.0},
		20.0,
		1.0,
		game.theme.error_color,
	)
	rl.DrawRectangleLinesEx(state.MSG_BOX_OUTLINE, 2.0, theme.line_thick)
} //_

//---------- render grid ----------\\
draw_grid :: proc(game: ^game.Game) {
	//---  Draw the light cell lines ---\\
	for i in 0 ..= 9 {
		thickness := f32(1)
		color := theme.line_thin

		//--- Thicker lines every 3 cells (the 3x3 box boarders) ---\\
		if i % 3 == 0 {
			thickness = 3
			color = theme.line_thick
		}
		//_

		//---  vertical lines
		x := f32(state.GRID_ORIGIN_X + i * state.CELL_SIZE)
		rl.DrawLineEx(
			{x, f32(state.GRID_ORIGIN_Y)},
			{x, f32(state.GRID_ORIGIN_Y + state.GRID_SIZE)},
			thickness,
			color,
		) //_

		//---  horizontal lines
		y := f32(state.GRID_ORIGIN_Y + i * state.CELL_SIZE)
		rl.DrawLineEx(
			{f32(state.GRID_ORIGIN_X), y},
			{f32(state.GRID_ORIGIN_X + state.GRID_SIZE), y},
			thickness,
			color,
		) //_
	} //_

	//--- draw the selection highlight
	cell_x := f32(state.GRID_ORIGIN_X + game.selected.x * state.CELL_SIZE)
	cell_y := f32(state.GRID_ORIGIN_Y + game.selected.y * state.CELL_SIZE)

	rl.DrawRectangleRec(
		{cell_x, cell_y, f32(state.CELL_SIZE), f32(state.CELL_SIZE)},
		theme.highlight,
	) //_

	//--- draw board crosshair


} //_

//---------- render numbers ----------\\
draw_numbers :: proc(theme: ^theme.Theme, fonts: ^fonts.Fonts, game: ^state.Game) {

	for row in 0 ..< 9 {
		for col in 0 ..< 9 {
			val := game.board[row][col]
			if val == 0 do continue

			if game.locked[row][col] && val != 0 {
				rect := rl.Rectangle {
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

} //_

//---------- Render Crosshair Tracking ----------\\
draw_crosshair :: proc(theme: ^theme.Theme, game: ^state.Game) {
    
	cell_x := f32(state.GRID_ORIGIN_X + game.selected.x * state.CELL_SIZE)
	cell_y := f32(state.GRID_ORIGIN_Y + game.selected.y * state.CELL_SIZE)

	//--- horizontal bar
	for x in 0 ..< 9 {
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
	} //_

	//--- vertical bar
	for y in 0 ..< 9 {
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
	} //_
}//_
