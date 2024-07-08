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
	li	a0, 1
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
	sd	s1, 16(sp)
	sd	s2, 24(sp)

	mv	s1, a0

	la	a0, arena
	li	a1, ARENA_SIZE
	call	arena_init

	la	a0, input
	la	a1, alloc
	la	a2, free
	call	intcode_init
	mv	s0, a0

	# initial run
	call	intcode_run

	# continue with input
	mv	a0, s0
	mv	a1, s1
	call	intcode_run

	mv	s2, a1

	# loop and collect outputs until intcode stops running
loop_foobar:
	mv	a0, s0
	call	intcode_run
	beqz	a0, foobar_ret
	mv	s2, a1
	j	loop_foobar

foobar_ret:
	
	mv	a0, s2
	call	print_dec
	call	print_ln

stop_here:

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
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

