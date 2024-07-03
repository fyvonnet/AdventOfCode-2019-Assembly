	.include "common.inc"

	.section .rodata
	aoc_rodata 2019, 03
moves:	.byte	'L', -1,  0		# left
	.byte	'U',  0, -1		# up
	.byte	'R',  1,  0		# right
	.byte	'D',  0,  1		# down


	.section .bss
	.balign	8
	.set	ARENA_SIZE, 8*1024*1024
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

	la	a0, arena
	li	a1, ARENA_SIZE
	call	arena_init

	la	a0, compar
	la	a1, alloc	
	call	redblacktree_init
	mv	s0, a0
	

	la	a0, input
	mv	a1, s0
	la	a2, first_wire
	call	parse_wire

	mv	a1, s0
	la	a2, second_wire
	call	parse_wire
	mv	s1, a1

	la	a0, ansp1
	call	print_str

	mv	a0, s1
	call	print_dec
	call	print_ln
	

	ld	a0, (sp)
	call	timer_stop
	
	
	exit
	.size	_start, .-_start

	
	# a0: tree
	# a1: X
	# a2: Y
	# a3: pointer
	.type	first_wire, @function
first_wire:
	addi	sp, sp, -64
	sd	ra,  0(sp)

	slli	a1, a1, 32
	add	a1, a1, a2
	call	redblacktree_insert

	ld	ra,  0(sp)
	addi	sp, sp, 64
	ret
	.size	first_wire, .-first_wire


	# a0: tree
	# a1: X
	# a2: Y
	# a3: pointer
	.type	second_wire, @function
second_wire:
	addi	sp, sp, -64
	sd	ra,  0(sp)
	sd	s1,  8(sp)
	sd	s2, 16(sp)
	sd	s3, 24(sp)

	mv	s1, a1
	mv	s2, a2
	mv	s3, a3

	slli	a1, a1, 32
	add	a1, a1, a2
	call	redblacktree_search
	beqz	a0, second_wire_ret

	mv	a0, s1
	call	abs
	mv	s1, a0

	mv	a0, s2
	call	abs
	add	a0, a0, s1

	ld	t0, (s3)
	bgeu	a0, t0, second_wire_ret
stop_here:
	sd	a0, (s3)

second_wire_ret:
	ld	ra,  0(sp)
	ld	s1,  8(sp)
	ld	s2, 16(sp)
	ld	s3, 24(sp)
	addi	sp, sp, 64
	ret
	.size	second_wire, .-first_wire


	# a0: input
	# a1: tree
	# a2: function
parse_wire:
	addi	sp, sp, -96
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)
	sd	s3, 32(sp)
	sd	s4, 40(sp)
	sd	s5, 48(sp)
	sd	s6, 56(sp)
	sd	s7, 64(sp)
	#sd	s8, 72(sp)
	addi	sp, sp, -16

	mv	s0, a0
	mv	s1, a1
	mv	s2, a2

	li	t0, -1
	sd	t0, (sp)

	# current coordinate
	mv	s4, zero
	mv	s5, zero

loop_lines:
	lb	t0, (s0)
	la	t1, moves
	inc	s0
	# search for steps direction
loop_dirs:
	lb	t3, (t1)
	beq	t0, t3, loop_dirs_end
	addi	t1, t1, 3
	j	loop_dirs
loop_dirs_end:
	# load steps moves
	lb	s6, 1(t1)
	lb	s7, 2(t1)

	mv	a0, s0
	call	parse_integer
	mv	s0, a0
	mv	s3, a1
loop_steps:
	add	s4, s4, s6
	add	s5, s5, s7
	mv	a0, s1
	mv	a1, s4
	mv	a2, s5
	mv	a3, sp
	jalr	ra, s2
	dec	s3
	bnez	s3, loop_steps

	li	t0, ','
	lb	t1, (s0)
	inc	s0
	beq	t0, t1,loop_lines
	
	mv	a0, s0
	ld	a1, (sp)

	addi	sp, sp, 16
	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s3, 32(sp)
	ld	s4, 40(sp)
	ld	s5, 48(sp)
	ld	s6, 56(sp)
	ld	s7, 64(sp)
	#ld	s8, 72(sp)
	addi	sp, sp, 96
	ret
	.size	parse_wire, .-parse_wire


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


	.type	compar, @function
compar:
	sub	a0, a0, a1
	ret
	.size	compar, .-compar
