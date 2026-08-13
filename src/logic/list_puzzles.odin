package logic

import "core:fmt"
import "core:os"
import "core:strings"

list_puzzle_names :: proc(dir: []string) -> (names: []string, ok: bool) {
    fis: []os.File_Info // seems necessary, errors without it 
    result: [dynamic]string
    read_err: os.Error
    defer os.file_info_slice_delete(fis, context.allocator)

    cwd, err := os.get_working_directory(context.allocator)
    if err != nil {
        fmt.eprintfln("could not get current working directory: %v", err)
        return {}, false
    }
    defer delete(cwd)

    parts := make([dynamic]string, 0, 1 + len(dir))
    defer delete(parts)
    append(&parts, cwd)
    append(&parts, ..dir)
    puzzle_dir, join_err := os.join_path(parts[:], context.allocator)
    
    if join_err != nil {
        fmt.eprintfln("join_path failed: %v", join_err)
        return {}, false
    }
    defer delete(puzzle_dir)

    f, open_err := os.open(puzzle_dir)
	if open_err != nil {
		fmt.eprintfln("Could not open directory: %v", open_err)
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
}
