	.include "common.inc"

	.section .rodata
	aoc_rodata 2019, 06
com:	.string	"COM"
you:	.string	"YOU"
san:	.string "SAN"
input_test:
	.incbin	"inputs/day06-test2"
	#.incbin	"inputs/day06-test"
	.byte	0


	.section .bss
	.balign	8
	.set	ARENA_SIZE, 1024*1024
	.type	arena, @object
	.size	arena, ARENA_SIZE
arena:	.zero	ARENA_SIZE
	.set	NMEMB, 100
	.set	SIZE, 16
	.set	QUEUE_SIZE, 40 + (NMEMB * SIZE)
	.type	queue, @object
	.size	queue, QUEUE_SIZE
queue:	.zero	QUEUE_SIZE



	.section .text


	.globl	_start
	.type	_start, @function
_start:
	addi	sp, sp, -16

	call	timer_start
	sd	a0, (sp)

	la	a0, arena
	li	a1, ARENA_SIZE
	call	arena_init

	la	a0, compar
	la	a1, alloc
	la	a2, free
	call	redblacktree_init
	mv	s0, a0

	la	a0, queue
	li	a1, NMEMB
	li	a2, SIZE
	call	queue_init

	mv	s1, sp
	#la	a0, input_test
	la	a0, input
loop_parse:
	addi	sp, sp, -16
	call	hash
	sd	a1, 0(sp)
	call	hash
	sd	a1, 8(sp)
	lb	t0, (a0)
	bnez	t0, loop_parse


	mv	s10, sp
loop_insert:
	mv	a0, s0
	ld	a1, 0(s10)
	ld	a2, 8(s10)
	call	tree_insert
	addi	s10, s10, 16
	bne	s10, s1, loop_insert

	# initialize queue with COM object at orbit level 0
	la	s2, queue
	mv	a0, s2
	call	queue_push
	mv	s11, a0
	la	a0, com
	call	hash
	sd	a1, 0(s11)
	sd	x0, 8(s11)
	
	clr	s3			# initialize counter
loop_part1:
	mv	a0, s2
	call	queue_pop
	beqz	a0, loop_part1_end
	ld	s11, 8(a0)		# load orbit level
	add	s3, s3, s11		# add orbit level to sum
	inc 	s11
	#ld	t0, 0(a0)
	#sd	t0, 0(sp)
	#mv	a0, s0
	#mv	a1, sp
	#call	redblacktree_search
	ld	a1, 0(a0)
	mv	a0, s0
	call	get_list
	beqz	a0, loop_part1
	#ld	s10, 8(a0)
	mv	s10, a0
loop_enqueue:
	beqz	s10, loop_enqueue_end
	mv	a0, s2
	call	queue_push
	ld	t0, 0(s10)
	sd	t0, 0(a0)
	sd	s11, 8(a0)
	ld	s10, 8(s10)
	j	loop_enqueue
loop_enqueue_end:
	j	loop_part1
	
loop_part1_end:

	la	a0, ansp1
	call	print_str
	mv	a0, s3
	call	print_dec
	call	print_ln	
	
	
	# insert inverted input to make
	# the orbits graph non-directional 
	mv	s10, sp
loop_insert_inv:
	mv	a0, s0
	ld	a1, 8(s10)
	ld	a2, 0(s10)
	call	tree_insert
	addi	s10, s10, 16
	bne	s10, s1, loop_insert_inv

	# initialize queue with YOU object with 0 moves
	la	s2, queue
	mv	a0, s2
	call	queue_push
	mv	s11, a0
	la	a0, you
	call	hash
	sd	a1, 0(s11)
	sd	x0, 8(s11)

	mv	a0, s0
	call	get_visited
	
	la	a0, san
	call	hash
	mv	s9, a1

loop_part2:
	la	a0, queue
	call	queue_pop

	ld	a1, 0(a0)
	ld	s11, 8(a0)
	beq	a1, s9, loop_part2_end
	inc	s11
	mv	a0, s0
	call	get_list
	beqz	a0, loop_part2
	mv	s8, a0
loop_enqueue2:
	ld	s7, 0(s8)
	mv	a0, s0
	mv	a1, s7
	call	get_visited
	bnez	a0, skip_enqueue
	la	a0, queue
	call	queue_push
	sd	s7, 0(a0)
	sd	s11, 8(a0)
skip_enqueue:
	ld	s8, 8(s8)
	bnez	s8, loop_enqueue2
	j	loop_part2
loop_part2_end:
	

	la	a0, ansp2
	call	print_str
	addi	a0, s11, -2
	call	print_dec
	call	print_ln


	ld	a0, (s1)
	call	timer_stop

end:
	exit
	.size	_start, .-_start



	.type	get_visited, @function
get_visited:
	addi	sp, sp, -16
	sd	ra, 0(sp)
	sd	s0, 8(sp)
	clr	s0					# leaf nodes are considered non-visited
	call	tree_search
	beqz	a0, get_visited_ret
	ld	s0, 16(a0)
	li	t0, 1
	sd	t0, 16(a0)
get_visited_ret:
	mv	a0, s0
	ld	ra, 0(sp)
	ld	s0, 8(sp)
	addi	sp, sp, 16
	ret
	.size	get_visited, .-get_visited


	.type	get_list, @function
get_list:
	addi	sp, sp, -16
	sd	ra, 0(sp)
	call	tree_search
	beqz	a0, get_list_ret
	ld	a0, 8(a0)
get_list_ret:
	ld	ra, 0(sp)
	addi	sp, sp, 16
	ret
	.size	get_list, .-get_list


	.type	tree_search, @function
tree_search:
	addi	sp, sp, -16
	sd	ra, 0(sp)
	addi	sp, sp, -16
	sd	a1, 0(sp)
	mv	a1, sp
	call	redblacktree_search
	addi	sp, sp, 16
	ld	ra, 0(sp)
	addi	sp, sp, 16
	ret
	.size	tree_search, .-tree_search

	# a0: tree
	# a1: object
	# a2: orbiting object
tree_insert:
	addi	sp, sp, -32
	sd	ra,  0(sp)
	sd	s0,  8(sp)
	sd	s1, 16(sp)
	sd	s2, 24(sp)

	mv	s0, a0
	mv	s1, a1
	mv	s2, a2

	# create new object node with
	# empty list of orbiting objects
	li	a0, 24
	call	alloc
	sd	s1,  0(a0)
	sd	x0,  8(a0)
	sd	x0, 16(a0)
	mv	s1, a0

	mv	a0, s0
	mv	a1, s1
	call	redblacktree_insert
	beqz	a0, tree_insert_new
	mv	s0, a0
	mv	a0, s1
	call	free
	mv	s1, s0
tree_insert_new:
	li	a0, 16
	call	alloc
	ld	t0, 8(s1)		# load current list's head
	sd	t0, 8(a0)		# save it as new cell's next
	sd	s2, 0(a0)		# store new orbiting object's name in new cell
	sd	a0, 8(s1)		# store new cell as new head

	ld	ra,  0(sp)
	ld	s0,  8(sp)
	ld	s1, 16(sp)
	ld	s2, 24(sp)
	addi	sp, sp, 32
	ret


hash:
	clr	a1
	li	t2, ')'
	li	t3, '\n'
loop_hash:
	lb	t1, (a0)
	beqz	t1, loop_hash_end
	beq	t1, t2, loop_hash_end
	beq	t1, t3, loop_hash_end
	slli	a1, a1, 8
	add	a1, a1, t1
	inc	a0
	j	loop_hash
loop_hash_end:
	inc	a0
	ret
	


	.type	compar, @function
compar:
	ld	t0, (a0)
	ld	t1, (a1)
	sub	a0, t0, t1
	ret
	.size	compar, .-compar


	.type	free, @function
free:
	addi	sp, sp, -16
	sd	ra, 0(sp)
	mv	a1, a0
	la	a0, arena
	call	arena_free
	ld	ra, 0(sp)
	addi	sp, sp, 16
	ret
	.size	free, .-free

	.type	alloc, @function
alloc:
	addi	sp, sp, -16
	sd	ra, 0(sp)
	mv	a1, a0
	la	a0, arena
	call	arena_alloc
	ld	ra, 0(sp)
	addi	sp, sp, 16
	ret
	.size	alloc, .-alloc

