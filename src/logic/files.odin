package logic

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import "src:state"

default_save_parts := state.SAVE_DIR_PARTS
save_dir := state.SAVE_DIR_PARTS
// Temporary until a real selector exists...
TEST_LOAD_NAME :: "b57440bd0176d33f.sudoku"

//---------- Get App Base DIR !Imortant ----------\\
app_base_dir :: proc(allocator := context.allocator) -> (dir: string, ok:bool) {
    path, err := os.get_executable_directory(allocator)
    if err == nil {
        return path, true
    }
    // fallback if the OS call fails 
    path, err = os.get_working_directory(allocator)
    if err != nil {
        fmt.eprintfln("app_base_dir: %v", err)
        return "", false
    }
    return path, true
}//_

//---------- Join path parts ----------\\
// Example: parts = {"puzzles", "easy"} -> "<base>/puzzles/easy"
join_app_path :: proc(
    parts: []string, 
    allocator := context.allocator) -> (path: string, ok: bool) {
        base, base_ok := app_base_dir(allocator)
        if !base_ok {
            return "", false
        }
        defer delete(base, allocator)

        all := make([dynamic]string, 0, 1 + len(parts), allocator)
        defer delete(all)
        append(&all, base)
        append(&all, ..parts)

        joined, join_err := os.join_path(all[:], allocator)
        if join_err != nil {
            fmt.eprintfln("join_app_path: %v", join_err)
            return "", false
        }
        return joined, true
}//_

//---------- load puzzle ----------\\
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
}//_

//---------- find line ----------\\
find_line :: proc(lines: []string, target: string) -> int {
    for line, i in lines {
        if line == target {
            return i
        }
    }
    return -1
}//_

//---------- parse row ----------\
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
}//_

//---------- FNV-1a board+locked->hexname ----------\\
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
}//_

//---------- save path ----------\\
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
}//_

//---------- save puzzle ----------\\
save_puzzle :: proc(
    game: ^state.Game,
    dir_parts: []string = state.SAVE_DIR_PARTS,
    ) -> (path: string, ok: bool) {

    path, ok = save_path(game, dir_parts)
    if !ok {
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
     err := os.write_entire_file(path, data)
     if err != nil {
         return path, false
     }
    return path, true
}//_

//---------- List Puzzle Names ----------\\
 list_puzzle_names :: proc(dir: []string, game: ^state.Game) -> (names: []string, ok: bool) {
    fis: []os.File_Info // seems necessary, errors without it 
    result: [dynamic]string
    read_err: os.Error
    defer os.file_info_slice_delete(fis, context.allocator)
    
    puzzle_dir, dir_ok := join_app_path(dir)
    if !dir_ok {
        return {}, false
    }
    defer delete(puzzle_dir)

    f, open_err := os.open(puzzle_dir)
	if open_err != nil {
		fmt.eprintfln("Could not open directory: %v", open_err)
        game.phase = .Fail_Modal
        return {}, false
	}
	defer os.close(f)

	fis, read_err = os.read_dir(f, -1, context.allocator) // -1 reads all file infos
	if read_err != nil {
		fmt.eprintfln("Could not read directory: %v", read_err)
        return {}, false
	}

	for fi in fis {
		if fi.type == .Regular && strings.has_suffix(fi.name, ".sudoku") {
            append(&result, strings.clone(fi.name))
		}
	}

    return result[:], true
}//_

//---------- Handle File Action ----------\\
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
            list_puzzle_names(dir_parts, game)
            game.phase = .Fail_Modal
            game.load_failed = true
            game.game_msg = "ERROR: Could not reslove dir not found Press ENTER!"
            return
        }
        defer delete(dir)

        if !os.exists(dir) {
            game.phase = .Fail_Modal
            game.load_failed = true
            game.game_msg = "ERROR: Directory not found press ENTER!"
            return
        }

        path := fmt.tprintf("%s/%s", dir, TEST_LOAD_NAME)
        if !load_puzzle(game, path) {
            game.phase = .Fail_Modal
            game.load_failed = true
            game.game_msg = "ERROR: Puzzle not found press ENTER!"
        } else {
            list_puzzle_names(dir_parts, game)
        }
    }
}//_
