# Sudoku Solver (Odin + Raylib 6)

A clean, interactive Sudoku editor and solver written in [Odin](https://odin-lang.org/) using [Raylib 6](https://www.raylib.com/).

This project is both a useful tool and a learning platform for idiomatic Odin, modular design, and app structure.

## Screenshots

<p align="center">
  <img src="assets/screenshots/dark.png" width="260" alt="Dark theme" />&nbsp;&nbsp;
  <img src="assets/screenshots/light.png" width="260" alt="Light theme" />&nbsp;&nbsp;
  <img src="assets/screenshots/exit-dialog.png" width="260" alt="Exit dialog" />
</p>

<p align="center">
  <img src="assets/screenshots/unsolvable.png" width="260" alt="Unsolvable puzzle" />&nbsp;&nbsp;
  <img src="assets/screenshots/solved.png" width="260" alt="Solved board" />
</p>

## Features

- Full 9×9 grid with clear 3×3 block borders
- Light & dark themes (toggle with `Space`)
- Mouse + keyboard navigation (arrows, WASD, hjkl)
- Tab / Shift+Tab jumps between 3×3 blocks
- Number entry (`1`–`9`) and clear (Backspace / Delete)
- Conflict highlighting (row, column, and 3×3 box) in red
- Lock / unlock system (`Ctrl+Shift+L` toggles)
  - Locked cells use bold font + outline
  - `Ctrl+Shift+C` clears all unlocked cells
- Backtracking solver (`Alt+S`); locked cells treated as givens
- Save puzzles (`Ctrl+S`) to `puzzles/easy/<hash>.sudoku` (simple text format)
- Load puzzles (`Ctrl+O`) — currently loads a fixed path; lists files in `puzzles/easy`
- Exit confirmation dialog
- Monospaced fonts (Roboto Mono)

## Controls

| Input | Action |
|-------|--------|
| Mouse click | Select cell |
| Arrows / WASD / hjkl | Move selection |
| Tab / Shift+Tab | Jump to next/previous 3×3 block |
| `1`–`9` | Enter number |
| Backspace / Delete | Clear cell |
| Space | Toggle light/dark theme |
| Ctrl+Shift+L | Toggle lock on filled cells |
| Ctrl+Shift+C | Clear all unlocked cells |
| Alt+S | Solve current board |
| Ctrl+S | Save puzzle |
| Ctrl+O | Open puzzle (path still hard-coded) |
| Esc, then Y/N | Quit |

## Building

```bash
make run      # odin run . -collection:src=src
make build    # produces ./sudoku-solver
make test     # runs logic tests
```

Requires a recent Odin with Raylib 6 and collection support (e.g. dev-2026-08+).

## Project structure

```text
.
├── main.odin              # entry: game.run()
├── Makefile
├── ols.json               # OLS collection: src
├── assets/
│   ├── fonts/...
│   └── screenshots/...
├── puzzles/easy/          # saved .sudoku files
└── src/
    ├── game/              # main loop
    ├── state/             # Game struct, constants, init
    ├── events/            # keyboard + mouse handlers
    ├── render/            # grid, numbers, dialogs
    ├── helpers/           # conflict check, which_block, etc.
    ├── logic/             # solver, save, load, list_puzzles
    ├── fonts/
    ├── theme/
    └── vecs/
```

## Branches

- **`master`** — stable snapshot of what works today
- **`dev`** — active development (work only happens here)

## Roadmap

1. Selectable open path / simple file picker for load
2. Dirty flag; warn on exit if unsaved
3. Undo / Redo
4. Pencil marks, more themes, export (stretch)
5. WASM / Linux polish

Project roadmap also lives on the [wiki DOC](https://github.com/codemonkeywtf/sudoku-solver/wiki/DOC).

## Notes

- Coordinate convention: `selected.x` = row, `selected.y` = col
- Locked cells = puzzle givens; `Ctrl+Shift+C` clears the rest
- Prefer alphabetical order for struct fields and constant lists

## License

Learning / personal use. Fonts are under the OFL (see `assets/fonts/`).
