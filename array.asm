	#.include	"common.inc"

	.global	array_addr_unsafe
	.global	array_addr

	.section .text

	# a0: rank
	# a1: address of bounds array
	# a2: size of an element
	.globl	array_init
	.type	array_init, @function
array_init:
	ld	a1,  0(a0)		# dimensions
	addi	a2, a0, 16		# pointer to bounds vector
	ld	a3, 8(a0)		# elements size

	# allocate vector for dimensions lengths in the stack
	li	t0, 8
	mul	t0, t0, a1
	sub	sp, sp, t0

	# compute dim lengths from bounds
	# length = max - min + 1
	mv	t1, a1				# initialize countdown
	mv	t2, sp				# pointer to lengths
	mv	t3, a2				# pointer to bounds
	li	t6, 1				# initialize total number of elements
loop_compute_lengths:
	ld	t4, 8(t3)			# load maximum
	ld	t5, 0(t3)			# load minimum
	sub	t4, t4, t5			# maximum - minimum
	addi	t4, t4, 1			# add 1
	sd	t4, 0(t2)			# save length
	mul	t6, t6, t4			# multiply total number of elements by length
	addi	t2, t2, 8			# move lengths pointer
	addi	t3, t3, 16			# move bounds pointer
	addi	t1, t1, -1			# decrease countdown
	bnez	t1, loop_compute_lengths	# loop if countdown not null

	# compute address of multipliers array
	addi	t2, a0, 16			# skip dimensions and sizes
	slli	t0, a1, 4			# total size of bounds array (dimensions*16)
	add	t2, t2, t0			# skip bounds array

	li	t0, 1
	sd	t0, 0(t2)			# first multiplier is 1
	
	addi	t1, a1, -1			# initialize countdown
	mv	t3, sp				# pointer to lengths
loop_compute_multipliers:
	addi	t2, t2, 8			# move ptr to next multiplier
	beqz	t1, loop_compute_multipliers_end
	ld	t4, 0(t3)			# load length
	mul	t0, t0, t4			# multiply length to last multiplier
	sd	t0, 0(t2)			# store new multiplier
	addi	t1, t1, -1			# decrease coutndown
	j	loop_compute_multipliers
loop_compute_multipliers_end:
	
	# free lengths vector 
	li	t0, 8
	mul	t0, t0, a1
	add	sp, sp, t0

	ret



# a0: structure pointer
# a1: coordinates vector
array_addr:
	addi	sp, sp, -8
	sd	ra, 0(sp)
	ld	t0, 0(a0)			# load rank
	addi	t1, a0, 16			# bound vector pointer
	mv	t4, a1				# copy coordinates vector
check_bounds_loop:
	ld	t2, 0(t4)			# load index
	ld	t3, 0(t1)			# load min bound
	blt	t2, t3, check_bounds_fail
	ld	t3, 8(t1)			# load max bound
	bgt	t2, t3, check_bounds_fail
	addi	t1, t1, 16
	addi	t4, t4, 8
	addi	t0, t0, -1
	bnez	t0, check_bounds_loop
	call	array_addr_unsafe
	ld	ra, 0(sp)
	addi	sp, sp, 8
	ret
check_bounds_fail:
	mv	a0, zero
	ld	ra, 0(sp)
	addi	sp, sp, 8
	ret



# a0: structure pointer
# a1: coordinates vector
array_addr_unsafe:
	ld	t0, 0(a0)			# load rank
	mv	a7, t0
	addi	t1, a0, 16			# bounds array pointer
	slli	t6, t0, 4
	add	t2, t1, t6			# multipliers pointer
	mv	t3, zero			# initialize index
loop_compute_index:
	ld	t4, 0(a1)			# load coordinate
	ld	t5, 0(t1)			# load lower bound
	sub	t4, t4, t5			# substract lower bound from coordinate
	ld	t5, 0(t2)			# load multiplier
	mul	t4, t4, t5			# multiply coordinate with multiplier
	add	t3, t3, t4			# add coordinate to index
	addi	t1, t1, 16			# move bounds pointer
	addi	t2, t2, 8			# move multipliers pointer
	addi	a1, a1, 8			# move coordinates pointer
	addi	t0, t0, -1			# decrease countdown
	bnez	t0, loop_compute_index		# loop if countdown not null

	ld	t1, 8(a0)			# load member size
	mul	t3, t3, t1			# multiply index by member size
	#addi	t1, a0, 16
	li	t2, 24				# 16 (bounds) + 8 (multipliers)
	mul	t2, t2, a7			# total length of bounds + multipliers
	addi	a0, a0, 16			# skip dimensions / element size
	add	a0, a0, t2			# skip bounds and multipliers
	add	a0, a0, t3			# add offset to vector address
	
	ret
