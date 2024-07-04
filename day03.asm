	.include "common.inc"

	.set	VALUE_X,	 0	
	.set	VALUE_Y,	 4
	.set	VALUE_DIST1, 	 8
	.set	VALUE_DIST2,	12
	.set	VALUE_SIZE,	16

	.section .rodata
	aoc_rodata 2019, 03
moves:	.byte	'L', -1,  0		# left
	.byte	'U',  0, -1		# up
	.byte	'R',  1,  0		# right
	.byte	'D',  0,  1		# down


	.section .bss
	.balign	8
	.set	ARENA_SIZE, 17*1024*1024
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

	addi	sp, sp, -16
	li	t0, -1
	sd	t0, 0(sp)
	sd	t0, 8(sp)

	la	a0, input
	mv	a1, s0
	la	a2, first_wire
	mv	a3, sp
	call	parse_wire

	mv	a1, s0
	la	a2, second_wire
	mv	a3, sp
	call	parse_wire

	la	a0, ansp1
	call	print_str
	ld	a0, 0(sp)
	call	print_dec
	call	print_ln
	
	la	a0, ansp2
	call	print_str
	ld	a0, 8(sp)
	call	print_dec
	call	print_ln
	

	addi	sp, sp, 16

	ld	a0, (sp)
	call	timer_stop
	
	
	exit
	.size	_start, .-_start

	
	# a0: tree
	# a1: X
	# a2: Y
	# a3: pointer (ignored)
	# a4: steps
	.type	first_wire, @function
first_wire:
	addi	sp, sp, -64
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)
	sd	s4, 32(sp)

	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	mv	s4, a4

	la	a0, VALUE_SIZE
	call	alloc
	sw	s1, VALUE_X(a0)
	sw	s2, VALUE_Y(a0)
	sw	s4, VALUE_DIST1(a0)
	sw	x0, VALUE_DIST2(a0)
	mv	s1, a0

	mv	a0, s0
	mv	a1, s1
	call	redblacktree_insert
	beqz	a0, first_wire_skip
	#lw	s4, VALUE_DIST1(a0)		# cable crosses itself, load initial steps count
	la	a0, arena
	mv	a1, s1
	call	arena_free
first_wire_skip:

	mv	a0, s4
	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s4, 32(sp)
	addi	sp, sp, 64
	ret
	.size	first_wire, .-first_wire


	# a0: tree
	# a1: X
	# a2: Y
	# a3: pointer
	# a4: steps
	.type	second_wire, @function
second_wire:
	addi	sp, sp, -64
	sd	ra,  0(sp)
	sd	s1,  8(sp)
	sd	s2, 16(sp)
	sd	s3, 24(sp)
	sd	s4, 32(sp)
	sd	s5, 40(sp)
	sd	s0, 48(sp)
	sd	s6, 56(sp)

	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	mv	s3, a3
	mv	s4, a4

	la	a0, arena
	li	a1, VALUE_SIZE
	call	arena_alloc
	mv	s6, a0
	sw	s1, VALUE_X(s6)
	sw	s2, VALUE_Y(s6)
	sw	s4, VALUE_DIST2(s6)

	mv	a0, s0
	mv	a1, s6
	call	redblacktree_insert
	beqz	a0, second_wire_ret		# new step has been successfully inserted
	mv	s5, a0

	# existing coordinates found

	la	a0, arena
	mv	a1, s6
	call	arena_free

	# check if wire is crossing itself
	lw	t0, VALUE_DIST2(s5)
	beqz	t0, not_cross_self

	# check if wire also crossing first wire
	lw	t0, VALUE_DIST1(s5)
	bnez	t0, cross_wire1
	j	second_wire_ret

not_cross_self:
	sw	s4, VALUE_DIST2(s5)

cross_wire1:
	mv	a0, s1
	call	abs
	mv	s1, a0

	mv	a0, s2
	call	abs
	add	a0, a0, s1

	# check if new minimum distance found
	ld	a1, 0(s3)
	call	minu
	sd	a0, 0(s3)

cross_wire1_next:
	lw	s1, VALUE_DIST1(s5)
	beqz	s1, second_wire_ret
	lw	s2, VALUE_DIST2(s5)
	beqz	s2, second_wire_ret
	add	a0, s1, s2
	
	ld	a1, 8(s3)
	call	minu
	sd	a0, 8(s3)

second_wire_ret:
	mv	a0, s4
	ld	ra,  0(sp)
	ld	s1,  8(sp)
	ld	s2, 16(sp)
	ld	s3, 24(sp)
	ld	s4, 32(sp)
	ld	s5, 40(sp)
	ld	s0, 48(sp)
	ld	s6, 56(sp)
	addi	sp, sp, 64
	ret
	.size	second_wire, .-second_wire


	# a0: input
	# a1: tree
	# a2: function
	# a3: pointer
	.type	parse_wire, @function
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
	sd	s8, 72(sp)
	sd	s9, 80(sp)

	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	mv	s8, a3

	la	s9, 1

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
	mv	a3, s8
	mv	a4, s9
	jalr	ra, s2
	addi	s9, a0, 1
	dec	s3
	bnez	s3, loop_steps

	li	t0, ','
	lb	t1, (s0)
	inc	s0
	beq	t0, t1,loop_lines
	
stop_here:

	mv	a0, s0
	ld	a1, (sp)

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s3, 32(sp)
	ld	s4, 40(sp)
	ld	s5, 48(sp)
	ld	s6, 56(sp)
	ld	s7, 64(sp)
	ld	s8, 72(sp)
	ld	s9, 80(sp)
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
	ld	t0, (a0)
	ld	t1, (a1)
	sub	a0, t0, t1
	ret
	.size	compar, .-compar
