package logic

import "core:fmt"
import "core:os"
import "core:strings"

import "src:state"

save_dir := state.SAVE_DIR

// Fast FNV-1a style mix of board + locked -> hex name
board_hash :: proc(game: ^state.Game) -> string {
    h: u64 = 14695981039346656037
    for r in 0..<9 {
        for c in 0..<9 {
            h = (h ~ u64(game.board[r][c])) * 1099511628211
            locked_bit: u64 = game.locked[r][c] ? 1 : 0
            h = (h ~ locked_bit) * 1099511628211
        }
    }
    return fmt.tprintf("%016x", h)
}

save_path :: proc(game: ^state.Game) -> string {
    name := board_hash(game)
    return fmt.tprintf("%s/%s.sudoku", save_dir, name)
}

ensure_save_dir :: proc() -> bool {
    // creates puzzles/ and puzzles/easy/ if needed 
    err := os.make_directory_all(save_dir)
    return err == nil || err == os.ERROR_NONE || err == .Exist
}

save_puzzle :: proc(game: ^state.Game) -> (path: string, ok: bool) {
    if !ensure_save_dir() {
        return "", false
    }

    path = save_path(game)
    
    b: strings.Builder 
    strings.builder_init(&b)
    defer strings.builder_destroy(&b)
    
    strings.write_string(&b, "v1\n")
    strings.write_string(&b, "board\n")
    for r in 0..<9 {
        for c in 0..<9 {
            if c > 0 {
                strings.write_byte(&b, ' ')
            }
            strings.write_int(&b, game.board[r][c])
        }
        strings.write_byte(&b, '\n')
    }

    strings.write_string(&b, "locked\n")
    for r in 0..<9 {
        for c in 0..<9 {
            if c > 0 {
                strings.write_byte(&b, ' ')
            }
            strings.write_int(&b, game.locked[r][c] ? 1 : 0)
        }
        strings.write_byte(&b, '\n')
    }

    data := strings.to_string(b)
     err := os.write_entire_file(path, data)
     if err != nil {
         return path, false
     }
    return path, true
}
