all: day01 day02 day03 day04 day05 day06 day07

day01: day01.o misc.o timer.o print.o common.inc 
	ld -o day01 day01.o misc.o timer.o print.o

day02: day02.o misc.o timer.o print.o memory.o redblacktree.o intcode.o common.inc 
	ld -o day02 day02.o misc.o timer.o print.o memory.o redblacktree.o intcode.o

day03:	day03.o misc.o timer.o print.o redblacktree.o memory.o common.inc
	ld -o day03 day03.o misc.o timer.o print.o redblacktree.o memory.o

day04:	day04.o misc.o timer.o print.o common.inc
	ld -o day04 day04.o misc.o timer.o print.o

day05: day05.o misc.o timer.o print.o memory.o redblacktree.o intcode.o common.inc 
	ld -o day05 day05.o misc.o timer.o print.o memory.o redblacktree.o intcode.o

day06: day06.o misc.o timer.o print.o memory.o redblacktree.o queue.o common.inc 
	ld -o day06 day06.o misc.o timer.o print.o memory.o redblacktree.o queue.o

day07: day07.o misc.o timer.o print.o memory.o redblacktree.o intcode.o common.inc 
	ld -o day07 day07.o misc.o timer.o print.o memory.o redblacktree.o intcode.o

%.o: %.asm
	as -g $< -o $@
