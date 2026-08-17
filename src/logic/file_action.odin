package logic

import "core:fmt"
import "core:os"

import "src:state"

// Temporary until a real selector exists...
TEST_LOAD_NAME :: "b57440bd0176d33f.sudoku"

handle_file_action :: proc(game: ^state.Game, action: state.File_Action) {
    dir_parts := state.SAVE_DIR_PARTS

    switch action {
    case .Save:
        path, ok := save_puzzle(game, dir_parts)
        if !ok {
            game.save_failed = true
            game.game_msg = "ERROR: Puzzle can not be saved press ENTER!"
        }

    case .Load:
        dir, dir_ok := join_app_path(dir_parts)
        if !dir_ok {
            game.load_failed = true
            game.game_msg = "ERROR: Could not reslove dir not found Press ENTER!"
            return
        }
        defer delete(dir)

        if !os.exists(dir) {
            game.load_failed = true
            game.game_msg = "ERROR: Directory not found press ENTER!"
            return
        }

        path := fmt.tprintf("%s/%s", dir, TEST_LOAD_NAME)
        if !load_puzzle(game, path) {
            game.load_failed = true
            game.game_msg = "ERROR: Puzzle not found press ENTER!"
        }
    }
}
