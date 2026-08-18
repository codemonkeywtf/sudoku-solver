package logic

import "core:fmt"
import "core:testing"

import "src:logic"
import "src:state"

TESTDATA_PARTS :: []string{"testdata"}

boards_equal :: proc(a, b: ^state.Game) -> bool {
    for r in 0..<9 {
        for c in 0..<9 {
            if a.board[r][c] != b.board[r][c] {
                return false
            }
        }
    }
    return true
}

fixture_path :: proc(name: string) -> (path: string, ok: bool) {
    dir, dir_ok := join_app_path(TESTDATA_PARTS)
    if !dir_ok {
        return "", false
    }
    defer delete(dir)
    return fmt.tprintf("%s/%s", dir, name), true
}

@(test)
test_solve_known_solvable :: proc(t: ^testing.T) {
    path_in, ok_in := fixture_path("known_solvable.sudoku")
    testing.expect(t, ok_in)
    path_want, ok_want := fixture_path("known_solved.sudoku")
    testing.expect(t, ok_want)

    g := state.game_init()
    testing.expect(t, load_puzzle(&g, path_in))

    testing.expect(t, solve(&g))

    want := state.game_init()
    testing.expect(t, load_puzzle(&want, path_want))

    testing.expect(t, boards_equal(&g, &want))

    // givens stayed put (spot-check a few locked cells)
    testing.expect(t, g.board[0][3] == 9)
    testing.expect(t, g.board[0][6] == 7)
    testing.expect(t, g.board[8][0] == 6)
}

@(test)
test_save_load_round_trip_testdata :: proc(t: ^testing.T) {
    path_in, ok := fixture_path("known_solvable.sudoku")
    testing.expect(t, ok)

    original := state.game_init()
    testing.expect(t, load_puzzle(&original, path_in))

    saved_path, save_ok := save_puzzle(&original, TESTDATA_PARTS)
    testing.expect(t, save_ok)

    loaded := state.game_init()
    testing.expect(t, load_puzzle(&loaded, saved_path))
    testing.expect(t, boards_equal(&original, &loaded))
}
