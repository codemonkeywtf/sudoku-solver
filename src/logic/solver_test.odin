package logic

import "core:log"
import "core:testing"
import "src:state"

@(test)
test_find_empty_on_blank_board :: proc(t: ^testing.T) {
    log.info("find_empty: blank board should return (0,0)")
    g := state.game_init()
    r, c, ok := find_empty(&g)
    testing.expect(t, ok)
    testing.expect(t, r == 0 && c == 0)
}

@(test)
test_find_empty_none :: proc(t: ^testing.T) {
    log.info("find_empty_none: if no empty cells possible win state")
    g := state.game_init()
    for r in 0..<9 {
        for c in 0..<9 {
            g.board[r][c] = 1
        }
    }
    _, _, ok := find_empty(&g)
    testing.expect(t, !ok)
}

@(test)
test_solve_enpty_board :: proc(t: ^testing.T) {
    log.info("solve: empty board  should succeed and fill all cells")
    g := state.game_init()
    ok := solve(&g)
    testing.expect(t, ok)
    _, _, has_empty := find_empty(&g)
    testing.expect(t, !has_empty)
}

@(test)
test_solve_simple_given :: proc(t: ^testing.T) {
    log.info("solve: single given should still solve")
    g := state.game_init()
    g.board[0][0] = 5
    ok := solve(&g)
    testing.expect(t, ok)
    testing.expect(t, g.board[0][0] == 5)
    _, _, has_empty := find_empty(&g)
    testing.expect(t, !has_empty)
}

@(test)
test_solve_impossible :: proc(t: ^testing.T) {
    log.info("solve: contradictory givens should fail")
    g := state.game_init()
    g.board[0][0] = 5
    g.board[0][1] = 5
    ok := solve(&g)
    testing.expect(t, !ok)
}
