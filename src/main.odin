package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "core:strings"


temp_cstring :: proc (s: string)-> cstring {
    return strings.clone_to_cstring(s, context.temp_allocator)
}

// ------------------------------------------------------------
// Constants
// ------------------------------------------------------------
WINDOW_WIDTH  :: 540
WINDOW_HEIGHT :: 620          // extra space below for buttons later
CELL_SIZE     :: 60
GRID_ORIGIN_X :: 0
GRID_ORIGIN_Y :: 0
GRID_SIZE     :: 9 * CELL_SIZE
MOVE_COOLDOWN :: 0.19
MOVE_INITIAL_DELAY :: 0.28
MOVE_REPEAT_RATE :: 0.11
FONT_SIZE :: 0.9 * CELL_SIZE

//----------------------------------------------------------
// Theme 
//----------------------------------------------------------
Theme :: struct {
    bg:             rl.Color,
    line_thin:      rl.Color,
    line_thick:     rl.Color,
    highlight:      rl.Color,
    font_color:     rl.Color,
}

light_theme := Theme {
    bg              = rl.RAYWHITE,
    line_thin       = rl.LIGHTGRAY,
    line_thick      = rl.BLACK,
    highlight       = {100, 180, 255, 100}, // soft blue, semi-transparent
    font_color      = rl.BLACK,
}

dark_theme := Theme {
    bg              = {30, 30, 30, 255},    // near-black
    line_thin       = {80, 80, 80, 255},    // medium gray 
    line_thick      = {200, 200, 200, 255}, // light gray / almost white 
    highlight       = {80, 140, 220, 120},  // a bit stronger blue for dark mode
    font_color      = rl.RAYWHITE,
}

// Enums
Direction :: enum {
    None,
    Left,
    Right,
    Up,
    Down,
}

// init global variables
is_dark := true
last_move_time: f64 = 0
is_first_move := true
selected: V2     // V2 is Vec2 {0, 0}
digit := " "
current_theme :: proc() -> Theme {
    return is_dark ? dark_theme : light_theme
}


// ---------------------------------------------------------
main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Sudoku Solver - Odin + Raylib 4")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        // ---------- event handlers ---------- 
        handle_theme_toggle()
        handle_mouse_click()
        handle_keys()
        handle_tab_navigation()
        handle_get_number()

        // ---------- Draw ----------
        theme := current_theme()

        rl.BeginDrawing()
        rl.ClearBackground(theme.bg)

        draw_grid(theme)

        rl.EndDrawing()
    }
}

handle_theme_toggle :: proc() {
    if rl.IsKeyPressed(.SPACE) {
        is_dark = !is_dark
    }
}

handle_mouse_click :: proc() {
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()

        // Convert mouse position into grid coords
        col := int(mouse.x - f32(GRID_ORIGIN_X)) / CELL_SIZE
        row := int(mouse.y - f32(GRID_ORIGIN_Y)) / CELL_SIZE

        // Only accept clicks inside the grid
        if row >= 0 && row < 9 && col >= 0 && col < 9 {
            selected.y = row
            selected.x = col
        }
    }
}

handle_keys :: proc() {
    now := rl.GetTime()

    // Arrow vim style key movement (wraps inside the current row/column)
    dir := Direction.None
    
    switch {
    case rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.L):
        dir = .Right 
    case rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.H):
        dir = .Left
    case rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J):
        dir = .Down
    case rl.IsKeyDown(.UP) || rl.IsKeyDown(.K):
        dir = .Up
    }

    if dir == .None {
        is_first_move = true
        return
    }

    delay := is_first_move ? MOVE_INITIAL_DELAY : MOVE_REPEAT_RATE

    if now - last_move_time < delay {
        return
    }

    switch dir {
    case .Right:
        selected.x = (selected.x + 1) % 9
    case .Left:
        selected.x = (selected.x - 1 + 9) % 9
    case .Down:
        selected.y = (selected.y + 1) % 9
    case .Up:
        selected.y = (selected.y - 1 + 9) % 9
    case .None:
    }

    last_move_time = now
}

handle_tab_navigation :: proc() {

    // Tab jump to next 3x3 block (forward)
    if rl.IsKeyPressed(.TAB) && !rl.IsKeyDown(.LEFT_SHIFT) &&
        !rl.IsKeyDown(.RIGHT_SHIFT) {
            // which block are we currently in? (0, 1, or 2)
            block_row := selected.y / 3 
            block_col := selected.x / 3 
            
            // Move to the next block
            block_col += 1
            if block_col > 2 {
                block_col = 0
                block_row += 1
                if block_row > 2 {
                    block_row = 0
                    block_col = 0
                }
            }
            fmt.println(block_row, block_col)

            // land on the top-left cell of that block 
            selected.y = block_row * 3
            selected.x = block_col * 3
    }

    // Shift+Tab jump to the previous 3x3 block (backward)
    if rl.IsKeyPressed(.TAB) && (rl.IsKeyDown(.LEFT_SHIFT) ||
        rl.IsKeyDown(.RIGHT_SHIFT)) {
            // get current block
            block_row := selected.y / 3
            block_col := selected.x /3 

            // move to previous block
            block_col -= 1
            if block_col < 0 {
                block_col = 2 
                block_row -= 1
                if block_row < 0 {
                    block_row = 2 
                }
            }

            selected.y = block_row * 3 
            selected.x = block_col * 3
    }
}

handle_get_number :: proc(){
    theme := current_theme()
    key := rl.GetCharPressed()
    if key > 48 && key < 58 {
        draw_text(key,theme)
        // fmt.println(key)
    }
    if rl.IsKeyPressed(.BACKSPACE) || rl.IsKeyPressed(.DELETE) {
        fmt.println("BLANK ME BABY!")
    }
}

draw_text :: proc(digit: rune,theme: Theme) {
    rl.DrawText(temp_cstring(digit), i32(selected.x + 15), i32(selected.y + 5), FONT_SIZE, theme.font_color )
}

draw_grid :: proc(theme: Theme) {
    // Draw the light cell lines
    for i in 0..=9 {
        thickness := f32(1)
        color     := theme.line_thin

        // Thicker lines every 3 cells (the 3×3 box borders)
        if i % 3 == 0 {
            thickness = 3
            color     = theme.line_thick
        }

        // Vertical
        x := f32(GRID_ORIGIN_X + i * CELL_SIZE)
        rl.DrawLineEx(
            {x, f32(GRID_ORIGIN_Y)},
            {x, f32(GRID_ORIGIN_Y + GRID_SIZE)},
            thickness,
            color,
        )

        // Horizontal
        y := f32(GRID_ORIGIN_Y + i * CELL_SIZE)
        rl.DrawLineEx(
            {f32(GRID_ORIGIN_X), y},
            {f32(GRID_ORIGIN_X + GRID_SIZE), y},
            thickness,
            color,
        )
    }

    // Draw the selection highlight
    cell_x := f32(GRID_ORIGIN_X + selected.x * CELL_SIZE)
    cell_y := f32(GRID_ORIGIN_Y + selected.y * CELL_SIZE)

    rl.DrawRectangleRec(
        {cell_x, cell_y, f32(CELL_SIZE), f32(CELL_SIZE)},
        theme.highlight,
    )

}
