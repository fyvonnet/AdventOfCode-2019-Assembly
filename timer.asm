	.include "common.inc"

	.set	TICKS_PER_SECOND, 	100
	.set	SECONDS_PER_MINUTE, 	 60

	.section .rodata
	.type	running, @object
running:.string	"Running..."
	.size	running, .-running
	.type	runtime, @object
runtime:.string "\rRun time: "
	.size	runtime, .-runtime
	

	.text
	.balign	8

	.globl	timer_start
	.type	timer_start, @function
timer_start:
	addi	sp, sp, -32
	mv	a0, sp
	li	a7, SYS_TIMES
	ecall	
	addi	sp, sp, 32
	ret
	.size	timer_start, .-timer_start
	

	.globl	timer_stop
	.type	timer_stop, @function
timer_stop:
	addi	sp, sp, -64
	sd	s1,  0(sp)
	sd	s2,  8(sp)
	sd	s3, 16(sp)
	sd	s5, 24(sp)
	sd	s6, 32(sp)
	sd	s7, 40(sp)
	sd	ra, 48(sp)
	
	mv	s1, a0

	call	timer_start
	mv	s2, a0

	sub	s3, s2, s1

	li	t0, TICKS_PER_SECOND
	div	t1, s3, t0			# seconds
	rem	s5, s3, t0			# 100th of second

	li	t0, SECONDS_PER_MINUTE
	div	s6, t1, t0			# minutes
	rem	s7, t1, t0			# remaining seconds

	la	a0, runtime
	call	print_str

	mv	a0, s6
	call	print_dec
	li	a0, 'm'
	call	print_chr

	mv	a0, s7
	call	print_dec
	li	a0, '.'
	call	print_chr

	li	t0, 10
	bge	s5, t0, skip_zero
	li	a0, '0'
	call	print_chr
skip_zero:

	mv	a0, s5
	call	print_dec
	li	a0, 's'
	call	print_chr

	call	print_ln

	ld	s1,  0(sp)
	ld	s2,  8(sp)
	ld	s3, 16(sp)
	ld	s5, 24(sp)
	ld	s6, 32(sp)
	ld	s7, 40(sp)
	ld	ra, 48(sp)
	addi	sp, sp, 64
	ret



