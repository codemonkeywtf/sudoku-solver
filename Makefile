# Makefile for Sudoki Solver (Odin)

COLLECTION 	= -collection:src=src
ODIN 		= odin

.PHONY: run build clean 

run:
	$(ODIN) run . $(COLLECTION)

build: 
	$(ODIN) build . $(COLLECTION) -out:sudoku-solver

clean:
	rm -f sudoku-solver
