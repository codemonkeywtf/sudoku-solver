package helpers

import "core:fmt"
import "core:strings"
import "src:state"
import v "src:vecs"
// string to temp_cstring helper
temp_cstring :: proc (val: int) -> cstring {
    return strings.clone_to_cstring((fmt.tprintf("%d", val)), context.temp_allocator)
}

which_block :: proc(game: ^state.Game) -> v.V2 {
    // get current block 
    block_row := game.selected.x / 3
    block_col := game.selected.y / 3

    block: v.V2 = {block_row, block_col}
    return block
}

// check  board for conflict
has_board_conflict :: proc(game: ^state.Game) -> bool {
    for r in 0..<9 {
        for c in 0..<9 {
            v := game.board[r][c]
            if v != 0 && has_conflict(game, r, c, v) {
                return true
            }
        }
    }
    return false
}

// number conflict helper
has_conflict :: proc(game: ^state.Game, row, col, value: int) -> bool {
    if value == 0 do return false

    // check the rest of the row (same x)
    for c in 0..<9 {
        if c != col && game.board[row][c] == value {
            return true
        }
    }

    // check the rest of the column
    for r in 0..<9 {
        if r != row && game.board[r][col] == value {
            return true
        }
    }

    // check 3x3 block 
    start_row := (row/3) * 3
    start_col := (col/3) * 3

    for r in start_row..<start_row + 3 {
        for c in start_col..<start_col + 3 {
            if (r != row || c != col) && game.board[r][c] == value {
                return true
            }
        }
    }
    return false
}
