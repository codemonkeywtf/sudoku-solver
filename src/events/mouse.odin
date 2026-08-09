package events

import rl "vendor:raylib"
import "src:state"

//---------- MOUSE EVENTS ----------\\
handle_mouse_click :: proc(game: ^state.Game) {
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()

        // Convert mouse position into grid coords 
        row := int(mouse.x - f32(state.GRID_ORIGIN_X)) / state.CELL_SIZE
        col := int(mouse.y - f32(state.GRID_ORIGIN_Y)) / state.CELL_SIZE

        // only accept clicks inside the grid 
        if row >= 0 && row < 9 && col >= 0 && col < 9 {
            game.selected.x = row
            game.selected.y = col
        }
    }
}
