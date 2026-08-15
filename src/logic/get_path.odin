package logic

import "core:fmt"
import "core:os"
import "core:strings"

import "src:state"

// Relative default (same meaning as old SAVE_DIR)
default_save_parts := state.SAVE_DIR_PARTS

// Directory that "owns" the app (binary location)
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
}

// Join base + relative parts -> one path
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
}
