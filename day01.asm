	.include "common.inc"


	.section .rodata
	aoc_rodata 2019, 01


	.section .text

	.globl	_start
	.type	_start, @function
_start:
	print_banner

	addi	sp, sp, -16
	call	timer_start
	sd	a0, (sp)

	la	a0, input
	clr	s1
	clr	s2
loop:
	call	parse_integer
	mv	s0, a0
	mv	a0, a1

	call	require
	add	s1, s1, a0

loop_reqfuel:
	call	require
	bltz	a0, loop_reqfuel_end
	add	s2, s2, a0
	j	loop_reqfuel
loop_reqfuel_end:

	addi	a0, s0, 1
	lb	t0, (a0)
	bnez	t0, loop

	la	a0, ansp1
	call	print_str
	mv	a0, s1
	call	print_dec
	call	print_ln
	
	la	a0, ansp2
	call	print_str
	add	a0, s1, s2
	call	print_dec
	call	print_ln

	ld	a0, (sp)
	call	timer_stop
	
	exit
	.size	_start,.-_start


	.type	require, @function
require:
	li	t0, 3
	div	a0, a0, t0
	addi	a0, a0, -2
	ret
	.size	require, .-require


