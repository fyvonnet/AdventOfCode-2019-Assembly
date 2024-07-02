	.include "common.inc"

	.section .rodata
	aoc_rodata 2019, 03
moves:	.byte	'L', -1,  0		# left
	.byte	'U',  0, -1		# up
	.byte	'R',  1,  0		# right
	.byte	'D',  0,  1		# down


	.section .bss
	.balign	8
	.set	COORDS_SIZE, 6*1024*1024
	.type	coords, @object
	.size	coords, COORDS_SIZE
coords:	.zero	COORDS_SIZE
	.set	SCHEM_SIZE, 256*1024*1024
	.type	schem, @object
	.size	schem, SCHEM_SIZE
schem:	.zero	SCHEM_SIZE
foobar:	.byte	0


	.section .text


	.globl	_start
	.type	_start, @function
_start:

	call	timer_start
	addi	sp, sp, -16
	sd	a0, (sp)
	
	la	a0, input
	la	s0, coords
	mv	s6, s0
	addi	s0, s0, 16

loop_wires:
	# current coordinate
	mv	s8, zero
	mv	s9, zero

loop_lines:
	lb	t0, (a0)
	inc	a0
	la	s1, moves
	# search for steps direction
loop_dirs:
	lb	t3, (s1)
	beq	t0, t3, loop_dirs_end
	addi	s1, s1, 3
	j	loop_dirs
loop_dirs_end:
	# load steps moves
	lb	s10, 1(s1)
	lb	s11, 2(s1)

	call	parse_integer
	mv	s7, a1
loop_steps:
	add	s8, s8, s10
	add	s9, s9, s11
	sd 	s8, 0(s0)
	sd	s9, 8(s0)
	addi	s0, s0, 16
	dec	s7
	bnez	s7, loop_steps

	li	t0, ','
	lb	t1, (a0)
	inc	a0
	beq	t0, t1,loop_lines
	
	sd	s0, (s6)		# store end of wire's address
	addi	s6, s6, 8

	lb	t0, (a0)
	bnez	t0, loop_wires
	


	# create array

	la	t0, schem
	li	t1, 2
	sd	t1, 0(t0)
	li	t1, 1
	sd	t1, 8(t0)

	la	t0, coords
	addi	s0, t0, 16
	ld	s11, 8(t0)		# load end second wire's adress

loop_coords_bounds:
	mv	s1, s0
	la	s2, schem
	addi	s2, s2, 16

	.rept 2
	ld	a0, 0(s1)
	ld	a1, 0(s2)
	call	min
	sd	a0, 0(s2)

	ld	a0, 0(s1)
	ld	a1, 8(s2)
	call	max

	sd	a0, 8(s2)
	addi	s1, s1, 8
	addi	s2, s2, 16
	.endr
	
	addi	s0, s0, 16
	bne	s0, s11, loop_coords_bounds

	la	a0, schem
	call	array_init


	# mark first wire on the schematic

	la	t0, coords
	addi	s0, t0, 16
	li	s1, 1
	ld	s11, 0(t0)				# load end of first wire
loop_mark_wire:
	la 	a0, schem
	mv	a1, s0
	call	array_addr
	sb	s1, (a0)	
	addi	s0, s0, 16
	bne	s0, s11, loop_mark_wire



	
	# search for crossings

	li	s1, -1
	la	t0, coords
	ld	s11, 8(t0)				# load end of second wire
loop_search_crossings:
	la 	a0, schem
	mv	a1, s0
	call	array_addr
	lb	t0, (a0)
	beqz	t0, skip_crossing
	ld	a0, 0(s0)
	call	abs
	mv	s2, a0
	ld	a0, 8(s0)
	call	abs
	add	s2, s2, a0
	bgeu	s2, s1, skip_newmin
	mv	s1, s2
skip_newmin:
skip_crossing:
	addi	s0, s0, 16
	blt	s0, s11, loop_search_crossings

	la	a0, ansp1
	call	print_str

	mv	a0, s1
	call	print_dec
	call	print_ln
	

	ld	a0, (sp)
	call	timer_stop
	
	
end:
	exit
	.size	_start, .-_start
