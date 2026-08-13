# Sudoku Solver – Odin + Raylib

ODIN       = odin
COLLECTION = -collection:src=src

.PHONY: dirs run build test clean distclean

dirs:
	mkdir -p puzzles/easy

run: dirs
	$(ODIN) run . $(COLLECTION)

build: dirs
	$(ODIN) build . $(COLLECTION) -out:sudoku-solver

test:
	$(ODIN) test src/logic $(COLLECTION) -define:ODIN_TEST_SHORT_LOGS=true

clean:
	rm -f sudoku-solver

distclean:
	rm -f sudoku-solver
	rm -rf puzzles
