#Quadratic Congruence
#Agnes Liu, 260713093
	.data
a: 	.space 4
b: 	.space 4
c: 	.space 4
SOL: 	.asciiz "\n solution: "
NULL:	.asciiz "No solution"
	.text
	.globl main
	
main: 	li $v0 5
	la $a0 a
	syscall		#read input a
	move $s0 $v0	#store a value to s0

	li $v0 5
	la $a0 b
	syscall		#read input b
	move $s1 $v0	#store b value to s1
	
	li $v0 5
	la $a0 c
	syscall		#read input c
	move $s2 $v0	#store c value to s2
	
	li $t3 0 	#counter on possible x values found

	rem $t0 $s0 $s1	 	#a%b
#	div $s0 $s1	#divide a by b
#	mfhi $t0	#move the remainder to store in $t0
	
	add $t1 $0 $0 		#t1 (possible x value) start at 0
	mul $t4 $s2 $s2 	#getting c squared
	div $t4 $s1 		#divide it by b
	mflo $t5		#move the quotient (upper bound for loop) in t5
	addi $t6 $0 2		#give the new loop iterator i starting value at 2
	
loop1:	bgt $t1 $s2 null 	#if $t1 > c value, no longer satisfy the condition
	mul $t2 $t1 $t1		#x^2
	rem $t2 $t2 $s1		#x^2 %b
	bne $t2 $t0 inc	# if square != a mod b, increment x+1

print:	addi $t3 $t3 1
	li $v0 4
	la $a0 SOL
	syscall			#indicate solution
	
	li $v0 1	
	la $a0 ($t1)		#print the found solution
	syscall
	j inc
	
inc:	addi $t1 $t1 1		#x+1
	j loop1			#back to loop
	
null:	bne $t3 $0 exit	#means found solution	
	li $v0 4
	la $a0 NULL
	syscall
	
exit: nop
