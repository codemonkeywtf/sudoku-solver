package logic

import "src:helpers"
import "src:state"

// return row, col, and true if an empty cell was found
find_empty :: proc(game: ^state.Game) -> (row, col: int, ok: bool) {
    for r in 0..<9 {
        for c in 0..<9 {
            if game.board[r][c] == 0 {
                return r, c, true
            }
        }
    }
    return 0,0, false
}

//---------- SOLVE ----------\\
solve :: proc(game: ^state.Game) -> bool {
    if helpers.has_board_conflict(game) {
        game.solve_failed = true
        game.game_msg = "ERROR: Puzzle can not be solved press ENTER!"
        game.phase = .Fail_Modal
        return false
    }
    return solve_recursive(game)
}//_

//---------- Solver recursive backtracking ----------\\
solve_recursive :: proc(game: ^state.Game) -> bool {
    row, col, found := find_empty(game)
    if !found {
        return true
    }

    for digit in 1..=9 {
        if helpers.has_conflict(game, row, col, digit) {
            continue
        }

        game.board[row][col] = digit

        if solve_recursive(game) {
            return true
        }

        game.board[row][col] = 0
    }

    return false
}//_
