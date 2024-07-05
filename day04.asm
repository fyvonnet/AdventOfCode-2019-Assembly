	.include "common.inc"


	.section .rodata
	aoc_rodata 2019, 04


	.section .text



	.globl	_start
	.type	_start, @function
_start:
	print_banner

	addi	sp, sp, -16
	call	timer_start
	li	t0, -1
	sb	t0, 6(sp)
	sd	a0, 8(sp)

	la	a0, input
	call	parse_integer
	mv	s0, a1
	inc	a0
	call	parse_integer
	mv	s1, a1

	clr	s3
	clr	s4

loop:
	addi	t0, sp, 5
	li	t1, 10
	mv	s2, s0
	.rept	6
	rem	t2, s2, t1
	sb	t2, (t0)
	dec	t0
	div	s2, s2, t1
	.endr

	# test for repeat digits
	mv	t0, sp
	.rept	5
	lb	t1, 0(t0)
	lb	t2, 1(t0)
	beq	t1, t2, rep_ok
	inc	t0
	.endr
	j	next
	
rep_ok:

	# test for non-decrease
	mv	t0, sp
	.rept	5
	lb	t1, 0(t0)
	lb	t2, 1(t0)
	bgt	t1, t2, next
	inc	t0
	.endr

	inc	s3


	# test for repeat not part of larger group
	mv	s5, sp
	li	s2, 2
loop_notpart:
	mv	a0, s5
	call	count_repeat
	bltz	a0, next
	beq	a0, s2, notpart_success
	add	s5, s5, a0
	j	loop_notpart

notpart_success:
	inc	s4
	
	

next:
	inc	s0
	ble	s0, s1, loop

	la	a0, ansp1
	call	print_str
	mv	a0, s3
	call	print_dec
	call	print_ln

	la	a0, ansp2
	call	print_str
	mv	a0, s4
	call	print_dec
	call	print_ln

	ld	a0, 8(sp)
	call	timer_stop

	exit
	.size	_start, .-_start


	.type	count_repeat, @function
count_repeat:
	lb	t0, (a0)
	bgez	t0, count_repeat_go
	li	a0, -1
	ret
count_repeat_go:
	li	t1, 1
	inc	a0
loop_count_repeat:
	lb	t2, (a0)
	bne	t0, t2, loop_count_repeat_end
	inc	t1
	inc	a0
	j	loop_count_repeat
loop_count_repeat_end:
	mv	a0, t1
	ret
	.size	count_repeat, .-count_repeat
