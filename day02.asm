	.include "common.inc"

	.set	PART2_TARGET, 19690720

	
	.section .rodata
	aoc_rodata	2019, 02
input_test:
	.incbin	"inputs/day02-test"
	.byte	0
slash:	.string " / "


	.section .bss
	.balign 8
	.set	ARENA_SIZE, 16*1024
	.type	arena, @object
	.size	arena, ARENA_SIZE
arena:	.zero	ARENA_SIZE
	.type	backup, @object
	.size	backup, ARENA_SIZE
backup:	.zero	ARENA_SIZE


	.section .text
	.balign 8


	.globl	_start
	.type	_start, @function
_start:
	print_banner

	addi	sp, sp, -16
	call	timer_start
	sd	a0, (sp)

	la	a0, arena
	la	a1, ARENA_SIZE	
	call	arena_init

	la	a0, input
	#la	a0, input_test
	la	a1, alloc
	la	a2, free
	call	intcode_init
	mv	s0, a0

j end
	mv	a0, s0
	call	intcode_run

	mv	a0, s0
	clr	a1
	call	intcode_peek

end:

	# backup intcode
	li	t0, ARENA_SIZE
	la	t1, arena
	la	t2, backup
loop_backup:
	ld	t3, (t1)
	sd	t3, (t2)
	addi	t0, t0, -8
	addi	t1, t1, 8
	addi	t2, t2, 8
	bnez	t0, loop_backup

	mv	a0, s0
	li	a1, 12
	li	a2, 2
	call	foobar
	
	mv	s1, a0
	la	a0, ansp1
	call	print_str
	mv	a0, s1
	call	print_dec
	call	print_ln

	li	s1, PART2_TARGET
	li	s2, 100
	clr	s3

loop_part2:
	# restore intcode
	li	t0, ARENA_SIZE
	la	t1, arena
	la	t2, backup
loop_restore:
	ld	t3, (t2)
	sd	t3, (t1)
	addi	t0, t0, -8
	addi	t1, t1, 8
	addi	t2, t2, 8
	bnez	t0, loop_restore

	mv	a0, s0
	div	a1, s3, s2
	rem	a2, s3, s2
	call	foobar
	beq	a0, s1, loop_part2_end
	inc	s3
	j	loop_part2
loop_part2_end:

	mv	s1, a0
	la	a0, ansp2
	call	print_str
	mv	a0, s1
	mv	a0, s3
	call	print_dec
	call	print_ln

	ld	a0, (sp)
	call 	timer_stop
	

	exit
	.size	_start, .-_start

	.type	foobar, @function
foobar:
	addi	sp, sp, -32
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s2, 16(sp)

	mv	s0, a0
	mv	s2, a2

	mv	a0, s0
	mv	a2, a1
	li	a1, 1
	call	intcode_poke
	
	mv	a0, s0
	li	a1, 2
	mv	a2, s2
	call	intcode_poke
	
	mv	a0, s0
	call	intcode_run
	
	mv	a0, s0
	li	a1, 0
	call	intcode_peek

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s2, 16(sp)
	addi	sp, sp, 32
	ret
	.size	foobar, .-foobar

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


print_nodes:
	addi	sp, sp, -64
	sd	ra, 0(sp)
	sd	s0, 8(sp)

	mv	s0, a0

	ld	a0, 0(s0)
	call	print_dec

	la	a0, slash
	call	print_str

	ld	a0, 8(s0)
	call	print_dec
	call	print_ln

	ld	ra, 0(sp)
	ld	s0, 8(sp)
	addi	sp, sp, 64
	ret
