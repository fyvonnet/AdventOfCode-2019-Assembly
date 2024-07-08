	.include "common.inc"


	.set	INTCODE_SIZE, 	56
	.set	INTCODE_TREE, 	 0
	.set	INTCODE_ALLOC, 	 8
	.set	INTCODE_FREE, 	16
	.set	INTCODE_INPUT, 	24
	.set	INTCODE_OUTPUT, 32
	.set	INTCODE_PC, 	40
	.set	INTCODE_STAT, 	48

	.set	INTEGER_SIZE, 	16
	.set	INTEGER_ADDR, 	 0
	.set	INTEGER_VALUE, 	 8

	.macro	LOADPARAMS count
	.rept	\count
	inc	s1
	mv	a0, s0
	mv	a1, s1
	rem	a2, s2, s3
	div	s2, s2, s3
	call	get_value
	sd	a0, (s9)
	addi	s9, s9, 8
	.endr
	.endm


	.section .rodata
wrong_opcode:
	.string	"Wrong opcode: "



	.section .text



	# a0: input pointer
	# a1: allocation function pointer
	# a2: free function pointer
	.globl	intcode_init
	.type	intcode_init, @function
intcode_init:
	addi	sp, sp, -64
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)
	sd	s3, 32(sp)
	sd	s4, 40(sp)
	sd	s5, 48(sp)

	mv	s0, a0					# input pointer
	mv	s1, a1					# allocation
	mv	s2, a2

	# allocate memory for intcode structure
	li	a0, INTCODE_SIZE
	jalr	ra, s1
	mv	s5, a0					# intcode pointer

	sd	s1, INTCODE_ALLOC(s5)
	sd	s2, INTCODE_FREE(s5)
	sd	x0, INTCODE_PC(s5)
	sd	x0, INTCODE_STAT(s5)

	# initialize binary tree
	la	a0, intcode_compar
	mv	a1, s1
	clr	a2
	call	redblacktree_init
	sd	a0, INTCODE_TREE(s5)
	mv	s2, a0					# red black tree address

	# load input to binary tree
	clr	s3					# initilize address
	dec	s0
loop_load_input:
	inc	s0
	mv 	a0, s0
	call	parse_integer
	mv	s0, a0

	mv	a0, s5
	mv	a2, a1
	mv	a1, s3
	call	intcode_poke

	inc	s3
	li	t0, ','
	lb	t1, (s0)
	beq	t0, t1, loop_load_input

	mv	a0, s5

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s3, 32(sp)
	ld	s4, 40(sp)
	ld	s5, 48(sp)
	addi	sp, sp, 64
	ret
	.size	intcode_init, .-intcode_init



	# a0: intcode
	# a1: input
	.globl	intcode_run
	.type	intcode_run, @function
intcode_run:
	addi	sp, sp, -64
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s7, 24(sp)
	sd	s8, 32(sp)
	sd	s2, 40(sp)
	sd	s3, 48(sp)
	sd	s9, 56(sp)
	addi	sp, sp, -64

	mv	s0, a0
	ld	t0, INTCODE_STAT(s0)
	beqz	t0, skip_input
	#sd	x0, INTCODE_STAT(s0)
	sd	a1, INTCODE_INPUT(s0)
skip_input:
	ld	s1, INTCODE_PC(s0)
	li	s3, 10
loop_run:
	mv	s9, sp
	mv	a0, s0
	mv	a1, s1
	call	intcode_peek			# load instruction
	li	t0, 100
	div	s2, a0, t0			# modes
	rem	a0, a0, t0			# opcode
	li	t0, 1
	beq	a0, t0, opcode_add
	li	t0, 2
	beq	a0, t0, opcode_mul
	li	t0, 3
	beq	a0, t0, opcode_input
	li	t0, 4
	beq	a0, t0, opcode_output
	li	t0, 5
	beq	a0, t0, opcode_jump_if_true
	li	t0, 6
	beq	a0, t0, opcode_jump_if_false
	li	t0, 7
	beq	a0, t0, opcode_less_than
	li	t0, 8
	beq	a0, t0, opcode_equals
	li	t0, 99
	beq	a0, t0, opcode_end

	# shouldn't reach here
	mv	s0, a0
	la	a0, wrong_opcode
	call	print_str
	mv	a0, s0
	call	print_dec
	call	print_ln
	exit	1

opcode_add:
	loadparams 2

	inc	s1
	mv	a0, s0
	mv	a1, s1
	call	intcode_peek

	ld	t0, 0(sp)
	ld	t1, 8(sp)
	mv	a1, a0
	add	a2, t0, t1
	mv	a0, s0
	call	intcode_poke		# store result
	inc	s1
	j	loop_run


opcode_mul:
	loadparams 2

	inc	s1
	mv	a0, s0
	mv	a1, s1
	call	intcode_peek

	ld	t0, 0(sp)
	ld	t1, 8(sp)
	mv	a1, a0
	mul	a2, t0, t1
	mv	a0, s0
	call	intcode_poke		# store result
	inc	s1
	j	loop_run


opcode_input:
	ld	t0, INTCODE_STAT(s0)
	bnez	t0, input_ready
	sd	s1, INTCODE_PC(s0)
	li	a0, 1
	sd	a0, INTCODE_STAT(s0)
	j	loop_run_end
input_ready:
	sd	x0, INTCODE_STAT(s0)
	mv	a0, s0
	addi	a1, s1, 1
	call	intcode_peek
	mv	a1, a0
	mv	a0, s0
	ld	a2, INTCODE_INPUT(s0)
	call	intcode_poke
	addi	s1, s1, 2
	j	loop_run

opcode_output:
	mv	a0, s0
	addi	a1, s1, 1
	call	intcode_peek		# load address
	mv	a1, a0
	mv	a0, s0
	call	intcode_peek		# load value
	sd	a0, INTCODE_OUTPUT(s0)
	mv	a1, a0
	li	a0, 2
	addi	s1, s1, 2
	sd	s1, INTCODE_PC(s0)
	li	t0, 2
	sd	t0, INTCODE_STAT(s0)
	j	loop_run_end

opcode_jump_if_true:
	loadparams 2
	ld	t0, 0(sp)
	bnez	t0, opcode_jump
	inc	s1
	j	loop_run

opcode_jump_if_false:
	loadparams 2
	ld	t0, 0(sp)
	beqz	t0, opcode_jump
	inc	s1
	j	loop_run

opcode_jump:
	ld	s1, 8(sp)
	j	loop_run

opcode_less_than:	
	loadparams 2
	ld	t0, 0(sp)
	ld	t1, 8(sp)
	li	s7, 1
	blt	t0, t1, opcode_compare
	li	s7, 0
	j	opcode_compare

opcode_equals:
	loadparams 2
	ld	t0, 0(sp)
	ld	t1, 8(sp)
	li	s7, 1
	beq	t0, t1, opcode_compare
	li	s7, 0
	#j	opcode_compare
	
opcode_compare:
	inc	s1
	mv	a0, s0
	mv	a1, s1
	call	intcode_peek
	mv	a1, a0
	mv	a0, s0
	mv	a2, s7
	call	intcode_poke
	inc	s1
	j	loop_run

opcode_end:
	clr	a0
	ld	a1, INTCODE_OUTPUT(s0)
	

loop_run_end:
	addi	sp, sp, 64
	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s7, 24(sp)
	ld	s8, 32(sp)
	ld	s2, 40(sp)
	ld	s3, 48(sp)
	ld	s9, 56(sp)
	addi	sp, sp, 64
	ret
	.size	intcode_run, .-intcode_run


	# a0: intcode
	# a1: address
	# a2: mode
	.globl	get_value,
	.type	get_value, @function
get_value:
	addi	sp, sp, -32
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)
	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	call	intcode_peek
	bnez	s2, mode_immediate
	mv	a1, a0
	mv	a0, s0
	call	intcode_peek
mode_immediate:
	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	addi	sp, sp, 32
	ret
	.size	get_value, .-get_value


	.globl	intcode_poke
	.type 	intcode_poke, @function
intcode_poke:
	addi	sp, sp, -48
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)
	sd	s3, 32(sp)

	mv	s0, a0			# intcode ptr
	mv	s1, a1			# addr
	mv	s2, a2			# value

	ld	t0, INTCODE_ALLOC(s0)
	li	a0, INTEGER_SIZE
	jalr	ra, t0

	mv	s3, a0			# new node
	sd	s1, INTEGER_ADDR(a0)
	mv	a1, a0
	ld	a0, INTCODE_TREE(s0)
	call	redblacktree_insert
	beqz	a0, insert_ok
	mv	t0, s3
	mv	s3, a0
	mv	a0, t0
	ld	t1, INTCODE_FREE(s0)
	jalr	ra, t1
insert_ok:
	sd	s2, INTEGER_VALUE(s3)

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s3, 32(sp)
	addi	sp, sp, 48
	ret
	.size	intcode_poke, .-intcode_poke


	.globl	intcode_peek
	.type	intcode_peek, @function
intcode_peek:
	addi	sp, sp, -16
	sd	ra,  0(sp)
	addi	sp, sp, -16
	ld	a0, INTCODE_TREE(a0)
	sd	a1, INTEGER_ADDR(sp)
	mv	a1, sp
	call	redblacktree_search
	ld	a0, INTEGER_VALUE(a0)
	addi	sp, sp, 16
	ld	ra,  0(sp)
	addi	sp, sp, 16
	ret
	.size	intcode_peek, .-intcode_peek



	.type	intcode_compar, @function
intcode_compar:
	ld	t0, INTEGER_ADDR(a0)
	ld	t1, INTEGER_ADDR(a1)
	sub	a0, t0, t1
	ret
	.size	intcode_compar, .-intcode_compar
