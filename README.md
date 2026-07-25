# Sudoku Solver (Odin + Raylib)

A learning project built with [Odin](https://odin-lang.org/) and [Raylib 6](https://www.raylib.com/).

## Goals

- Interactive 9×9 Sudoku grid with keyboard + mouse navigation
- Ability to enter and clear numbers
- A working backtracking solver
- "Unsolve" support so you can create and share puzzles
- Clean, readable code as a learning exercise in Odin

## Current Status

- Grid rendering with light/dark theme
- Cell selection (mouse + arrows + hjkl + Tab block jumping)
- Basic number input (still needs a persistent board)
- Project structured with small packages (`vecs`, etc.)

## Building

```bash
odin run src
```

## Controls (so far)

| Input              | Action                          |
|--------------------|---------------------------------|
| Mouse click        | Select cell                     |
| Arrow keys / hjkl  | Move selection                  |
| Tab / Shift+Tab    | Jump to next/previous 3×3 block |
| 1-9                | Enter number (temporary)        |
| Backspace / Delete | Clear cell (temporary)          |
| Space              | Toggle light/dark theme         |

## Roadmap

1. Persistent board state (`[9][9]int`)
2. Proper number drawing
3. Solve button + backtracking solver
4. Unsolve / restore original puzzle
5. Optional undo stack
6. Polish + keyboard shortcuts

---

Learning project – code is intentionally kept simple and readable.
