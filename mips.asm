.data 
	dimensions: .word 3 				# Square matrix length - row width, column height kept same for simplicity.
	matrix_size: .word 9 				# Total size - 3 x 3
	weights: .float 1, 2, 3, 4, 5, 6, 7, 8, 9 	# Fill weights with arbitrary values.  from left to right - W11, W12, W13, W21, W22, W23, W31, W32, W33
	X: .float 10, 11, 12, 13, 14, 15, 16, 17, 18 	# Fill memory X with arbitrary values. from left to right - X11, X12, X13, X21, X22, X23, X31, X32, X33
	Y: .float 0, 0, 0, 0, 0, 0, 0, 0, 0 		# Initialize result array with 0 values - Y11, Y12, Y13, Y21, Y22, Y23, Y31, Y32, Y33
	offset: .word 4 				# Single precision floating offset value
	new_line: .asciiz "\n"				# New line constant
	zero: .word 0					# Zero value constant
	siva: .asciiz "Program designed and executed by Siva Charan Mallena, Bronco Id: 016568110"
.text
.globl main 
main:
	la $s0, X 		#load address of X variable
	la $s1, weights 	#load address of weights variable
	lw $s2, dimensions	#dimension size into register
	la $s3, Y		#load address of resulting matrix
	lw $s4, offset		#load offset into a register
	lw $s5, matrix_size	#total matrix size into register
	li $s7, 0		#print loop counter
	li $t1, 0		#row loop counter
	li $t2, 0		#col loop counter
	li $t3, 0		#mult_add_loop counter
	lwc1 $f10, zero		#load zero into temp register for zeroing Y value later
	j row_loop		#start! jump to matrix multiplication loop
	li $v0, 10		#exit out! this is not necessary i guess, since there is an exit method which will be called by row_loop
	syscall 

row_loop: # i
	bge $t1, $s2, reset_Y_address_and_print		# break out to printing final result ( Y ) 
	j col_loop					# jump to inner loop
	col_loop_ret:					# return location for col_loop
	addi $t1, $t1, 1				# increment row loop counter
	li $t2, 0					# reset col loop counter
	j row_loop					# looop
	
col_loop: # j
	bge $t2, $s2, col_loop_ret			# break out to row_loop upon completion
	lwc1 $f4, ($s3)					# load current Y location value into $f4
	j mult_add_loop					# jump to multiplication and add loop
	mult_add_loop_ret:				# return locatioin for mult_add_loop
	s.s $f4, ($s3)					# Save $f4 back to its current pointed address
	add $s3, $s3, $s4				# increment Y's location for the next Y value
	addi $t2, $t2, 1				# increment col_loop counter
	li $t3, 0					# reset mult_add_loop counter
	mov.s $f4, $f10					# reset $f4 value to 0
	j col_loop					# loooop

mult_add_loop: # k
	bge $t3, $s2, mult_add_loop_ret			# break out to col_loop
							# W offset = (j * 3) + k
	mul $t4, $t2, $s2				# j * 3
	add $t4, $t4, $t3 				# j * 3 + K; 
	mul $t4, $t4, $s4 				# multiply offset with length of word/single precision. t4 is absolute offset. which means address of w must be pointed to first element then $t4 must be added.
	add $t4, $s1, $t4				# get address of value to be fetched for W
	lwc1 $f1, ($t4)					# load actual value to FP register
	
	#X offset = (i * 3) + k
	mul $t5, $t1, $s2				# i * 3
	add $t5, $t5, $t3 				# i * 3 + k; t5 is absolute offset. which means address of w must be pointed to first element then $t5 must be added.
	mul $t5, $t5, $s4 				# multiply offset with length of word/single precision
	add $t5, $s0, $t5				# get address of value to be fetched for W
	lwc1 $f2, ($t5)					# load actual value to FP register
	
	mul.s $f3, $f2, $f1				# both W and X values are loaded. now multiply
	add.s $f4, $f4, $f3				# Y = Y+ (W*X)	
	addi $t3, $t3, 1				# increment mult_add_loop counter
	j mult_add_loop					# loooop

reset_Y_address_and_print:
	la $s3, Y
	la $a0, siva			# load my name
	li $v0, 4			# load print text command to $v0
	syscall
	j print_Y

print_Y:
	bge $s7, $s5, end_program	# break out to exit
	li $v0, 2 			# print from $f12
	lwc1 $f12, ($s3) 		# copy value we want to print to $f12
	syscall
	la $a0, new_line		# load new line value
	li $v0, 4			# load print text command to $v0
	syscall
	addi $s7, $s7, 1		# increment print loop counter
	add $s3, $s3, $s4		# increment address of Y
	j print_Y			# looop

end_program:
	li $v0, 10
	syscall
	

