	.include "common.inc"


	.section .rodata
	aoc_rodata 2019, 07


	.section .data
settings:
	.quad	settings + 8
	.byte	0, 1, 2, 3, 4, 0, 0, 0
	.quad	ansp1
	.byte	5, 6, 7, 8, 9, 0, 0, 0
	.quad	ansp2
	.byte	-1


	.section .bss
	.balign	8
	.set	ARENA_SIZE, 256*1024
	.type	arena, @object
	.size	arena, ARENA_SIZE
arena:	.zero	ARENA_SIZE


	.section .text


	.globl	_start
	.type	_start, @function
_start:
	print_banner
	
	addi	sp, sp, -16
	call	timer_start
	sd	a0, (sp)

	la	a0, arena
	li	a1, ARENA_SIZE
	call	arena_init

	li	a0, 120 * 8
	call	alloc
	mv	s6, a0

	li	a0, 6 * 8
	call	alloc
	mv	s10, a0
	sd	x0, 5(s10)

loop_parts:
	la	t0, settings
	ld	s0, (t0)

	ld	a0, 8(s0)
	call	print_str

	la	a0, 5
	mv	a1, s6
	mv	a2, s0
	call	generate

	mv	s0, s6
	mv	s1, s10

	clr	s4
	li	s9, 120

loop_sequences:
	# initialize the amps and set the modes
	.rept 5
	la	a0, input
	la	a1, alloc
	la	a2, free
	call	intcode_init
	sd	a0, (s1)
	mv	s11, a0

	# initial run
	call	intcode_run

	# input the mode
	mv	a0, s11
	lb	a1, (s0)
	call	intcode_run
	
	inc	s0
	addi	s1, s1, 8
	.endr

	# amps are now waiting for input signal

	addi	s0, s0, 3

	mv	s1, s10

	clr	s3			# initial input signal is 0

loop_feedback:
	mv	s2, s10
loop_amplifiers:
	# sending input signal
	ld	a0, (s2)
	beqz	a0, loop_feedback
	mv	a1, s3
	call	intcode_run
	beqz	a0, loop_amplifiers_end
	mv	s3, a1
	addi	s2, s2, 8
	j	loop_amplifiers
	
loop_amplifiers_end:
	
	mv	a0, s3
	mv	a1, s4
	call	max
	mv	s4, a0

	ld	a0, (s10)
	call	free

	dec	s9
	bnez	s9, loop_sequences

	mv	a0, s4
	call	print_dec
	call	print_ln

	la	t0, settings
	ld	t1, (t0)
	addi	t1, t1, 16
	lb	t2, (t1)
	bltz	t2, end
	sd	t1, (t0)

	j	loop_parts

end:
	
	ld	a0, (sp)
	call	timer_stop

	exit

	.size	_start, .-_start


	# heap's function
	.type	generate, @function
generate:
	addi	sp, sp, -48
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)

	mv	s0, a0
	
	li	t0, 1
	beq	s0, t0, output
	addi	a0, s0, -1
	call	generate

	clr	s1			# i
	add	s2, s0, -1		# k - 1
loop_generate:
	li	t2, 1
	and	t3, s0, t2
	bnez	t3, else
	add	t5, a2, s1		# A[i]
	j	endif
else:
	mv	t5, a2			# A[0]
	
endif:
	add	t6, a2, s0
	dec	t6			# A[k - 1]
	lb	a5, (t5)
	lb	a6, (t6)
	sb	a6, (t5)
	sb	a5, (t6)
	addi	a0, s0, -1
	call	generate

	inc	s1
	bne	s1, s2, loop_generate 
	
generate_ret:
	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	ld	s3, 32(sp)
	addi	sp, sp, 48
	ret
output:
	mv	t1, a2
	ld	t2, (t1)
	sd	t2, (a1)
	addi	a1, a1, 8
	j	generate_ret
	.size	generate, .-generate


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
	.size 	alloc, .-alloc


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
	.size 	free, .-free
