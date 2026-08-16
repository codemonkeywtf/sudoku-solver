package logic

import "core:os"
import "core:strconv"
import "core:strings"

import "src:state"

Puzzle :: struct {
    board:      [9][9]int,
    locked:     [9][9]int,
}

puzzle :Puzzle

load_puzzle :: proc(game: ^state.Game, path: string) -> bool {
    data, err := os.read_entire_file(path, context.allocator)
    if err != nil {
        return false
    }
    defer delete(data)

    text := string(data)
    lines := strings.split_lines(text)
    defer delete(lines)

    if len(lines) == 0 || lines[0] != "v1" {
        return false
    }

    board_at := find_line(lines, "board")
    if board_at < 0 || board_at + 9 >= len(lines) {
        return false
    }

    for r in 0..<9 {
        row, row_ok := parse_row((lines[board_at + 1 + r]))
        if !row_ok {
            return false
        }
        game.board[r] = row
    }

    locked_at := find_line(lines, "locked")
    if locked_at < 0 || locked_at + 9 >= len(lines) {
        return false
    }

    for r in 0..<9 {
        row, row_ok := parse_row((lines[locked_at + 1 + r]))
        if !row_ok {
            return false
        }
        for c in 0..<9 {
            game.locked[r][c] = row[c] != 0
        }
    }

    return true
}

find_line :: proc(lines: []string, target: string) -> int {
    for line, i in lines {
        if line == target {
            return i
        }
    }
    return -1
}

parse_row :: proc(line: string) -> (row: [9]int, ok: bool) {
    parts := strings.fields(line)
    defer delete(parts)
    if len(parts) != 9 {
        return {}, false
    }

    for part, i in parts {
        n, parse_ok := strconv.parse_int(part)
        if !parse_ok || n < 0 || n > 9 {
            return {}, false
        }
        row[i] = n
    }
    return row, true
}

puzzle_builder :: proc() -> (puzzle: Puzzle, ok: bool) {
    // load puzzle data board & locked 

    // parse board: lines/rows 
    
    // parse locked: lines/rows 

    //  

    return
}
