# Makefile for Sudoki Solver (Odin)

COLLECTION 	= -collection:src=src
ODIN 		= odin

.PHONY: run build clean 

test: 
	$(ODIN) test src/logic $(COLLECTION) -define:ODIN_TEST_SHORT_LOGS=true

run:
	$(ODIN) run . $(COLLECTION)

build: 
	$(ODIN) build . $(COLLECTION) -out:sudoku-solver

clean:
	rm -f sudoku-solver
