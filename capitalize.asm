# This program illustrates an exercise of capitalizing a string.
# The test string is hardcoded. The program should capitalize the input string
# Agnes Liu 260713093

	.data

inputstring: 	.asciiz "all work no play makes jack a dull boy"
outputstring:	.space 128 #127+1 for null termination


	.text
	.globl main

main:	
	li $v0 4		#give syscall $v0 of 4
	la $a0 inputstring	#give syscall $a0 of inputstring
	syscall                # Print the input string
	
	la $t0 inputstring	#load inputstring address to $t0
	la $s0 outputstring	#load address of outputstring into $s0
	li $t2 0		#offset initiated to 0
	
Loop: 	
	lb $t1 ($t0)		#t0: ptr to the A[i]; value loaded to $t1
	beq $t1 0 print		#if A[i]=0, termination		
	blt $t1 'a' store	#if smaller than a, no need to modify
	bgt $t1 'z' store	#if greater than z, no need to modify
	addi $t1 $t1 -32	#if within alphabet range, -32
	
store:	add $t3 $s0 $t2		#add the output address ptr and offset to get output[i] address ptr
	sb $t1 ($t3)		# store the incremented $t1 value into output[i]
	addi $t2 $t2 1		#increment offset 
	addi $t0 $t0 1		#increment input ptr
	j Loop			#go back and loop
			
print:
	li $v0 4		
	la $a0 outputstring	
	syscall                #print my new string
	
exit:	nop	
	
