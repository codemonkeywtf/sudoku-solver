package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    if len(os.args) < 2 {
        fmt.println("Usage: raylib-pretty <file.txt>")
        return
    }

    filename := os.args[1]

    data, err := os.read_entire_file_from_path(filename, context.allocator)
    if err != nil {
        fmt.println("Could not read file:", filename)
        fmt.println("Error:", err)
        return
    }
    defer delete(data)

    content := string(data)
    lines := strings.split_lines(content)
    defer delete(lines)

    for line in lines {
        fmt.println(line)
    }
}
