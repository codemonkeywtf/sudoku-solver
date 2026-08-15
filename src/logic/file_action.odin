package logic

import "core:fmt"

import "src:state"

// Temporary until a real selector exists...
TEST_LOAD_NAME :: "b57440bd0176d33f.sudoku"

handle_file_action :: proc(game: ^state.Game, action: state.FIle_Action) {
    dir_parts := state.SAVE_DIR_PARTS

    switch action {
    case .Save:
        path, ok := save_puzzle(game, dir_parts)
        if ok {
            fmt.printfln("saved: %s", path)
        } else {
            fmt.eprintfln("save failed")
        }

    case .Load:
        dir, dir_ok := join_app_path(dir_parts)
        if !dir_ok {
            fmt.eprintfln("load: could not resolve dir")
            return
        }
        defer delete(dir)

        path := fmt.tprintf("%s/%s", dir, TEST_LOAD_NAME)
        if load_puzzle(game, path) {
            fmt.printfln("loaded: %s", path)
        } else {
            fmt.eprintfln("load failed: %s", path)
        }
    }
}
