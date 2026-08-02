package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "core:strings"
import "vecs"

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
DX :: CELL_SIZE
DY :: CELL_SIZE

//----------------------------------------------------------
// Theme 
//----------------------------------------------------------
Theme :: struct {
    bg:             rl.Color,
    line_thin:      rl.Color,
    line_thick:     rl.Color,
    highlight:      rl.Color,
    highlight_r_c:  rl.Color,
    font_color:     rl.Color,
    error_color:    rl.Color,
    locked_bg:      rl.Color,
    locked_outline: rl.Color,
}

light_theme := Theme {
    bg              = rl.RAYWHITE,
    line_thin       = rl.LIGHTGRAY,
    line_thick      = rl.BLACK,
    highlight       = {100, 180, 255, 100}, // soft blue, semi-transparent
    highlight_r_c   = {100, 180, 255, 50},  // very soft row,col
    font_color      = rl.BLACK,
    error_color     = rl.RED,
    locked_bg       = {220, 230, 250, 80},  // soft blue-ish tint
    locked_outline  = {190, 170, 230, 200}   // very soft lavender
}

dark_theme := Theme {
    bg              = {30, 30, 30, 255},    // near-black
    line_thin       = {80, 80, 80, 255},    // medium gray 
    line_thick      = {200, 200, 200, 255}, // light gray / almost white 
    highlight       = {80, 140, 220, 120},  // a bit stronger blue for dark mode
    highlight_r_c  = {80, 140, 220, 50},    // very soft row,col
    font_color      = rl.RAYWHITE,
    error_color     = rl.RED,
    locked_bg       = {50, 70, 110, 90},    // slightly lighter/cooler dark blue
    locked_outline  = {70, 170, 160, 100}  // soft teal
}

Fonts :: struct {
    regular: rl.Font,
    bold:    rl.Font,
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
exit_window_requested: bool
exit_window: bool 
is_dark := true
last_move_time: f64 = 0
is_first_move := true
selected: vecs.V2     // V2 is Vec2 {0, 0}
space_num := 0
board: [9][9]int
locked: [9][9]bool  // true = this cell cannot be changed 

// ---------------------------------------------------------
main :: proc() {
    current_theme :: proc() -> Theme {
        return is_dark ? dark_theme : light_theme
    }
    fmt.println(board)
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Sudoku Solver - Odin + Raylib 6")
    rl.SetExitKey(.KEY_NULL)

    // Load RobotoMono-Medium
    fonts := Fonts{
        regular = rl.LoadFont("assets/fonts/static/RobotoMono-Light.ttf"),
        bold    = rl.LoadFont("assets/fonts/static/RobotoMono-SemiBold.ttf"),
    }
    defer {
        rl.UnloadFont(fonts.regular)
        rl.UnloadFont(fonts.bold)
    }
    rl.SetTextureFilter(fonts.regular.texture, .BILINEAR)
    rl.SetTextureFilter(fonts.bold.texture, .BILINEAR)

    rl.SetTargetFPS(60)
    defer rl.CloseWindow()

    for !exit_window {
        if rl.WindowShouldClose() || rl.IsKeyPressed(.ESCAPE) {
            exit_window_requested = true
        }

        if exit_window_requested {
            if rl.IsKeyPressed(.Y) {
                exit_window = true
            } else if rl.IsKeyPressed(.N) {
                exit_window_requested = false
            }
        }
        theme := current_theme()

        // ---------- event handlers ---------- 
        handle_theme_toggle()
        handle_mouse_click()
        handle_keys()
        handle_tab_navigation()
        handle_lock_keys()
        handle_get_number(theme)

        // ---------- Draw ----------

        rl.BeginDrawing()

            rl.ClearBackground(theme.bg)
            draw_grid(theme, fonts)
            draw_exit_window(theme, fonts.regular)

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
        row := int(mouse.x - f32(GRID_ORIGIN_X)) / CELL_SIZE
        col := int(mouse.y - f32(GRID_ORIGIN_Y)) / CELL_SIZE

        // Only accept clicks inside the grid
        if row >= 0 && row < 9 && col >= 0 && col < 9 {
            selected.x = row
            selected.y = col
        }
    }
}

handle_keys :: proc() {
    ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    shift := rl.IsKeyDown(.LEFT_SHIFT)  || rl.IsKeyDown(.RIGHT_SHIFT)
    // don't move!
    if ctrl && shift {
        return
    }

    now := rl.GetTime()

    // Arrow vim style key movement (wraps inside the current row/column)
    dir := Direction.None
    
    switch {
    case rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.L) || rl.IsKeyDown(.D):
        dir = .Right 
    case rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.H) || rl.IsKeyDown(.A):
        dir = .Left
    case rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J) || rl.IsKeyDown(.S):
        dir = .Down
    case rl.IsKeyDown(.UP) || rl.IsKeyDown(.K) || rl.IsKeyDown(.W):
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
    block := which_block()
    // fmt.println("cursor is in block: ", block)
}

handle_tab_navigation :: proc() {
    block := which_block()
    // Tab jump to next 3x3 block (forward)
    if rl.IsKeyPressed(.TAB) && !rl.IsKeyDown(.LEFT_SHIFT) &&
        !rl.IsKeyDown(.RIGHT_SHIFT) {
            // Move to the next block
            block.x += 1
            if block.x > 2 {
                block.x = 0
                block.y += 1
                if block.y > 2 {
                    block.y = 0
                    block.x = 0
                }
            }

            // land on the top-left cell of that block 
            selected.x = block.x * 3
            selected.y = block.y * 3
    }

    // Shift+Tab jump to the previous 3x3 block (backward)
    if rl.IsKeyPressed(.TAB) && (rl.IsKeyDown(.LEFT_SHIFT) ||
        rl.IsKeyDown(.RIGHT_SHIFT)) {
            // get current block
            block := which_block()

            // move to previous block
            block.x -= 1
            if block.x < 0 {
                block.x = 2 
                block.y -= 1
                if block.y < 0 {
                    block.y = 2 
                }
            }

            selected.x = block.x * 3 
            selected.y = block.y * 3
    }
}

handle_lock_keys :: proc() {
    ctrl    := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
    shift   := rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT)

    if ctrl && shift && rl.IsKeyPressed(.L) {
        // lock every cell that currently has a number
        for r in 0..<9 {
            for c in 0..<9 {
                if board[r][c] != 0 {
                    locked[r][c] = true
                }
            }
        }
    }

    if ctrl && shift && rl.IsKeyPressed(.U) {
        // unlock all cells
        for r in 0..<9 {
            for c in 0..<9 {
                locked[r][c] = false
            }
        }
    }
}

handle_get_number :: proc(theme: Theme){
    if locked[selected.x][selected.y] {
        return 
    }

    digit := board[selected.x][selected.y]
    key := rl.GetCharPressed()
    if key >= '1' && key <= '9' {
        digit = int(key - '0')
    } else if rl.IsKeyPressed(.BACKSPACE) || rl.IsKeyPressed(.DELETE) {
            digit = 0
    }
    board[selected.x][selected.y] = digit
}

// find my block helper
which_block :: proc () -> vecs.V2 {
    // get current block
    block_row := selected.x / 3 
    block_col := selected.y / 3

    block: vecs.V2 = {block_row, block_col}
    return block
}

// Number conflict helper
has_conflict :: proc(row, col, value: int) -> bool {
    if value == 0 do return false 

    // Check the rest of the row (same x)
    for c in 0..<9 {
        if c  != col && board[row][c] == value {
            return true
        }
    }

    // Chedk the rest of the column 
    for r in 0..<9 {
        if r != row && board[r][col] == value {
            return true
        }
    }

    // Check 3x3 Block 
    start_row := (row/3) * 3 
    start_col := (col/3) * 3 

    for r in start_row..<start_row + 3 {
        for c in start_col..<start_col + 3 {
            if (r != row  || c != col) && board[r][c] == value {
                return true
            }
        }
    }
    return false
}

// string to cstring helper
temp_cstring :: proc (s: string)-> cstring {
    return strings.clone_to_cstring(s, context.temp_allocator)
}

draw_exit_window :: proc(theme: Theme, font: rl.Font) {
    if !exit_window_requested do return

    rl.DrawRectangle(20, 220, WINDOW_WIDTH -50, 100, theme.bg)
    rl.DrawTextEx(
        font, 
        "Are you sure you want to exit program? [Y/N]",
        {50.0, 260.0},
        20.0,
        1.0,
        theme.font_color)
    rl.DrawRectangleLines(20,220,WINDOW_WIDTH - 50, 100, theme.line_thick)
}

draw_grid :: proc(theme: Theme, fonts: Fonts) {
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

    // Draw crosshair over row + col
    
    // Horizontal bar 
    for x in 0..<9 {
        if x == selected.x do continue 

        rl.DrawRectangleRec(
            {
                f32(GRID_ORIGIN_X + x * CELL_SIZE),
                cell_y,
                f32(CELL_SIZE),
                f32(CELL_SIZE),
            },
            theme.highlight_r_c,
        )
    }

    // Vertical bar
    for y in 0..<9 {
        if y == selected.y do continue

        rl.DrawRectangleRec(
            {
                cell_x,
                f32(GRID_ORIGIN_Y + y * CELL_SIZE),
                f32(CELL_SIZE),
                f32(CELL_SIZE),
            },
            theme.highlight_r_c,
        )
    }

    // Draw numbers 
    for row in 0..<9 {
        for col in 0..<9 {
            val := board[row][col]
            if val == 0 do continue
            
            // locked background tint
            if locked[row][col] && val != 0 {
                rect := rl.Rectangle{
                    f32(GRID_ORIGIN_X + row * CELL_SIZE),
                    f32(GRID_ORIGIN_Y + col * CELL_SIZE),
                    f32(CELL_SIZE),
                    f32(CELL_SIZE),
                }

                rl.DrawRectangleRec(
                    {
                        f32(GRID_ORIGIN_X + row * CELL_SIZE),
                        f32(GRID_ORIGIN_Y + col * CELL_SIZE),
                        f32(CELL_SIZE),
                        f32(CELL_SIZE),
                    },
                    theme.locked_bg,
                )

                outline_color := theme.locked_outline
                rl.DrawRectangleLinesEx(rect, 1.75, outline_color)
            }

            text := temp_cstring(fmt.tprintf("%d", val))

            // position in cell with padding to center number
            screen_x := i32(row * CELL_SIZE + 15)
            screen_y := i32(col * CELL_SIZE + 5)

            color := theme.font_color

            if has_conflict(row,col,val) {
                color = theme.error_color
            }

            font_to_use := fonts.regular
            if locked[row][col] {
                font_to_use = fonts.bold
            }

            rl.DrawTextEx(
                font_to_use,
                text, 
                {f32(screen_x), f32(screen_y)}, 
                f32(FONT_SIZE),
                1.0,
                color,)
        }
    }
}
