# Sudoku Solver (Odin + Raylib 6)

A clean, interactive Sudoku editor and solver written in [Odin](https://odin-lang.org/) using [Raylib 6](https://www.raylib.com/).

This project is both a useful tool and a learning platform for idiomatic Odin, modular design, and game/app structure.

## Features

- Full 9×9 grid with clear 3×3 block borders
- Light & dark themes (toggle with `Space`)
- Mouse + keyboard navigation (arrows, WASD, hjkl)
- Tab / Shift+Tab to jump between 3×3 blocks
- Number entry (1-9) and clear (Backspace / Delete)
- Conflict highlighting (row, column, **and** 3×3 box) in red
- Lock / Unlock system (`Ctrl+Shift+L` toggles)
  - Locked cells use bold font + outline
  - `Ctrl+Shift+C` clears all unlocked cells
- Exit confirmation dialog
- Monospaced fonts (Roboto Mono Light + SemiBold)

## Current Status (dev branch)

The project is in the middle of a structural refactor:

- Core data is being moved into a central `Game` struct
- Input handling is being split into an `events` package
- Drawing and logic will move into `render` and `logic` packages
- The application still runs on the previous global-based code while the new structure is completed

### Working
- All gameplay features listed above
- Theme system, fonts, conflict detection, locking

### In progress
- Migrating from globals → `Game` struct
- Moving handlers into `src/events/`
- Preparing `render/` and `logic/` packages

## Controls

| Input                    | Action                              |
|--------------------------|-------------------------------------|
| Mouse click              | Select cell                         |
| Arrows / WASD / hjkl     | Move selection                      |
| Tab / Shift+Tab          | Jump to next/previous 3×3 block     |
| 1-9                      | Enter number                        |
| Backspace / Delete       | Clear cell                          |
| Space                    | Toggle light/dark theme             |
| Ctrl+Shift+L             | Toggle lock on filled cells         |
| Ctrl+Shift+C             | Clear all unlocked cells            |
| Esc                      | Exit confirmation (Y/N)             |

## Building

```bash
odin run src
```

## Project Structure (target)

```text
src/
├── main.odin           # entry point + main loop
├── constants.odin
├── state.odin          # Game struct + init
├── theme.odin
├── fonts.odin
├── events/
│   ├── events.odin     # orchestrator
│   ├── keyboard.odin
│   └── mouse.odin
├── render/
│   └── render.odin
├── logic/
│   ├── conflict.odin
│   └── solver.odin     # future
└── vecs/
    └── vecs.odin
```

## Roadmap

1. Finish migration to `Game` struct
2. Complete `events` package
3. Move drawing into `render`
4. Move conflict checks into `logic`
5. Save / Load puzzles
6. Backtracking solver + Unsolve
7. (Optional) Pencil marks, more themes, microui menus

## License

This project is for learning and personal use. Fonts are under the OFL (see `assets/fonts/`).
