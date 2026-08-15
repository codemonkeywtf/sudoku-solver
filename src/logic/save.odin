package logic

import "core:fmt"
import "core:os"
import "core:strings"

import "src:state"

save_dir := state.SAVE_DIR_PARTS

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


ensure_save_dir :: proc(dir_parts: []string) -> bool {
    dir, ok := join_app_path(dir_parts)
    if !ok {
        return false
    }
    defer delete(dir)

    err := os.make_directory_all(dir)
    return err == nil || err == os.ERROR_NONE || err == .Exist
}

save_path :: proc(
    game: ^state.Game,
    dir_parts: []string = state.SAVE_DIR_PARTS,
) -> (path: string, ok: bool) {
    dir, dir_ok := join_app_path(dir_parts)
    if !dir_ok {
        return "", false
    }
    defer delete(dir)

    name := board_hash(game)
    path = fmt.tprintf("%s/%s.sudoku", dir, name)
    return path,true
}

save_puzzle :: proc(
    game: ^state.Game,
    dir_parts: []string = state.SAVE_DIR_PARTS,
    ) -> (path: string, ok: bool) {
    if !ensure_save_dir(dir_parts) {
        return "", false
    }

    _path, path_ok := save_path(game, dir_parts)
    if !path_ok {
        return "", false
    }
    
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
     err := os.write_entire_file(_path, data)
     if err != nil {
         return _path, false
     }
    return _path, true
}
