#studentName: Agnes Liu
#studentID:260713093

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
theW:	.asciiz  "Welcome to QuickSort\n"
theS:	.asciiz  "\nThe sorted array is: "
theC: 	.asciiz   "\nThe array is re-initialized\n"
theQ:	.asciiz   "\nQuickSort termination\n"

buffer:   .space  1024
	
int:	.byte
	.text
	.globl main

main:	# all subroutines you create must come below "main"
	la $a0,theW
	jal p1
	
	addi $s0 $0 0		#set s0 as ctr
	addi $s1 $0 0		#initialize int =0
	addi $s4 $0 0		# indicator
	la $s2 buffer	       # buffer tail pos
	
p2:	jal wait1		# read from MMIO
	
	beq $v0 32 sp		#space check		
	beq $v0 99 re_init	#c check
	beq $v0 113 quit 	#q check
	beq $v0 115 sort	#s check
	bge $v0 48 num		#number check
	j p2
num:	bge $v0 58 p2
	add $a0 $v0 $0	
	jal wait2	
	mul $s1 $s1 10		#last*10+decremented new value
	add $s1 $s1 $v0
	addi $s1 $s1 -48
	addi $s4 $0 1		# indicater ++
	j p2
sp:	addi $a0 $v0 0		#if received space, then store int
	jal wait2
	sb $s1 0($s2)
	addi $s2 $s2 4		#inc offset
	addi $s1 $0 0 		#clear integer va
	addi $s0 $s0 1		# increase the counter
	addi $s4 $0 0		#change the integer indicator $s4 to 0
	j p2
	
sort:	
	la $a0 theS
	jal p1
	beq $s4 0 begin 	#check if there is a valid integer haven't been stored in array
	sb $s1 0($s2)	
	addi $s2 $s2 4		#increase array
	add $s1 $0 $0 		
	addi $s0 $s0 1 	
	addi $s4 $0 0		#reset indicator
begin:
	
	la $a0 buffer
	move $a1 $0
	move $a2 $s0
	addi $a2 $a2 -1
	jal quicksort
	la $a0 buffer		#print the sorted array
	move $a1 $s0
	jal p3
	j p2
	
re_init:	
	la $a0 theC
	jal p1
	la $a0 buffer		#clear array
	move $a1 $s0
	jal ClearArray
	addi $s0 $0 0		#update counter to 0
	la $s2 buffer		# update $s2 
	j p2

quit:	la $a0 theQ
	jal p1
	li $v0 17			
	la $a0 0
	syscall

ClearArray:
	addi $t0 $0 0

clearL:	bge $t0 $a1 fini
	sb $zero 0($a0)
	addi $a0 $a0 4
	addi $t0 $t0 1
	j clearL
	
fini:	jr $ra
	
quicksort:			#$a0=address of array, $a1=low,$a2=hi
	addi $sp $sp -16
	sw $ra 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	ble $a2 $a1 back	# if hi <= low, then finish.
	jal pivot		# get the index of pivot
	sw $v0 12($sp)
	lw $a1 4($sp)
	lw $a2 12($sp)
	addi $a2 $a2 -1
	jal quicksort
	lw $a1 12($sp)
	addi $a1 $a1 1
	lw $a2 8($sp)
	jal quicksort
	
back:	
	lw $ra 0($sp)
	addi $sp $sp 16
	jr $ra

pivot:	addi $sp $sp -12	#dec sp to pivot index
	sw $ra 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	move $t5 $a1		#store pivot address
	move $t0 $t5
	sll $t0 $t0 2
	add $t0 $t0 $a0	
	lb $s3 0($t0)		#store value of pivot
	move $t3 $a1
	addi $t3 $t3 1		# $t3 is the current index in loop
	move $t4 $a2		# $t4 is index of last element
	 
loopP:	bgt $t3 $t4 done
	
	move $t0 $t3
	sll $t0 $t0 2
	add $t0 $t0 $a0
	lb $t1 0($t0)		#$t1 is the element at $t3
	
	bge $t1 $s3 next	#if curr < pivot, swap
	addi $t5 $t5 1		#inc pivot index
	
	# swap
	move $a1 $t5
	move $a2 $t3
	jal swap
	
next:	addi $t3 $t3 1		# increase $t3
	j loopP


done:	
	# swap pivot to the right place
	lw $a1 4($sp)
	move $a2 $t5
	jal swap
	
	move $v0 $t5		
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

swap:   
	sll $a1 $a1 2		#implement addresses of first 2 elements
	add $a1 $a0 $a1
	sll $a2 $a2 2
	add $a2 $a0 $a2
	
	lb $t0 0($a1)
	lb $t1 0($a2)
	sb $t0 0($a2)
	sb $t1 0($a1)
	jr $ra

p1:	addi $sp $sp -8		#print char array
	sw $ra 4($sp)
	add $t0 $0 $a0
	
loop:	lb $t1 0($t0)	
	beq $t1 0 return
	sw $t0 0($sp)
	add $a0 $t1 $0		#in an infinite loop
	jal wait2
	lw $t0 0($sp)	
	addi $t0 $t0 1
	j loop
return:	
	lw $ra 4($sp)
	addi $sp $sp 8
	jr $ra
	
p3:	addi $sp $sp -8		#print integer array
	sw $ra 0($sp)
	
	move $t1 $a0		# store address of curr int
	add $t5 $zero $zero
	
arrayL:	
	bge $t5 $a1 end	#go to noInt if reached end of array
	addi $t0 $zero 10	
	lb $t2 0($t1)
	div $t2 $t0
	mfhi $t3		#quotient
	mflo $t4		#remainder
	addi $t3 $t3 48
	addi $t4 $t4 48
	
	sw $t1 4($sp)		# save $t1 in stack
	la $a0 int		# print remainder
	sb $t4 0($a0)
	jal p1
	la $a0 int		# print quotient
	sb $t3 0($a0)
	jal p1
	la $a0 int		# print space
	addi $t3 $0 32
	sb $t3 0($a0)
	jal p1

	addi $t5 $t5 1		# increase current index
	lw $t1 4($sp)		# get the current address of intege
	addi $t1 $t1 4		# increase current address
	j arrayL
	
end:	la $a0 int		
	addi $t3 $0 10
	sb $t3 0($a0)
	jal p1

	lw $ra 0($sp)
	addi $sp $sp 8
	jr $ra	
	
	
wait1:  lui $t0 0xffff 	#ffff0000
l1:	lb $t1 0($t0) 		#control
	andi $t1 $t1 0x0001
	beq $t1 $zero l1
	lb $v0 4($t0) 		#data	
	jr $ra

wait2:  lui $t0 0xffff 	#ffff0000
l2: 	lw $t1 8($t0) 		#control
	andi $t1 $t1 0x0001
	beq $t1 $zero l2
	sw $a0 12($t0) 		#data	
	jr $ra	