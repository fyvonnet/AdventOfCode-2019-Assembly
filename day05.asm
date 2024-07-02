	.include "common.inc"



	.section .rodata
	aoc_rodata 2019, 05


	.section .bss
	.set 	ARENA_SIZE, 64*1024
	.type	arena, @object
	.size	arena, ARENA_SIZE
arena:	.zero	ARENA_SIZE


	.section .text


	.globl	_start
	.type	_start, @function
_start:
	print_banner

	call	timer_start
	addi	sp, sp, -16
	sd	a0, (sp)

	la	a0, ansp1
	call	print_str
	li	a0, 2
	call	foobar

	la	a0, ansp2
	call	print_str
	li	a0, 5
	call	foobar

	ld	a0, (sp)
	call	timer_stop

	exit
	.size	_start, .-_start


	.type	foobar, @function
foobar:
	addi	sp, sp, -32
	sd	ra,  0(sp)
	sd	s0,  8(sp)

	mv	s0, a0

	la	a0, arena
	li	a1, ARENA_SIZE
	call	arena_init

	la	a0, input
	la	a1, alloc
	la	a2, free
	call	intcode_init

	mv	a1, s0
	call	intcode_run
	call	print_dec
	call	print_ln

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	addi	sp, sp, 32
	ret
	.size	foobar, .-foobar


	.type	alloc, @function
alloc:
	addi	sp, sp, -16
	sd	ra, (sp)
	mv	a1, a0
	la	a0, arena
	call	arena_alloc
	ld	ra, (sp)
	addi	sp, sp, 16
	ret
	.size	alloc, .-alloc

	.type	free, @function
free:
	addi	sp, sp, -16
	sd	ra, (sp)
	mv	a1, a0
	la	a0, arena
	call	arena_free
	ld	ra, (sp)
	addi	sp, sp, 16
	ret
	.size	free, .-free

