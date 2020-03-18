#studentName: Agnes Liu
#studentID: 260713093

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
wordC:	.asciiz "Word count:\n"
inTextSeg: .asciiz "Enter the text segment:\n"
inSearchWord: .asciiz "Enter the search word:\n"
eorq: .asciiz "\npress 'e' to enter another segment of text or 'q' to quit.\n"
buffer: .space 3
occ: .asciiz "\noccurence: "
	.text
	.globl main

main:	# all subroutines you create must come below "main"
	li $v0 4	#print word count
	la $a0 wordC
	syscall		

	li $v0 4	#print textseg
	la $a0 inTextSeg	
	syscall	
	
#first call of wait1: store text in $s1
	li $v0 9
	la $a0 600
	syscall
	move $s1 $v0
	addi $s0 $0 0
r1:	jal wait1	
	la $a0 ($v0)	#a0 storing read byte
	jal wait2
	la $a0 ($v0) 	#printing the stored content
	li $v0 11
	syscall
	
	add $s3 $s0 $s1	#s0 storing the text
	sb $a0 ($s3)	
	addi $s0 $s0 1
	bne $a0 10 r1	
		
				
	li $v0 4	#print the searchword text
	la $a0 inSearchWord
	syscall
	
#second call of wait1: store word in $s2
	li $v0 9
	la $a0 600
	syscall
	move $s2 $v0
	addi $s0 $0 0
r2:	jal wait1	#2nd call of wait1: read word
	la $a0 ($v0)	#a0 storing read byte
	jal wait2
	la $a0 ($v0) 
	li $v0 11
	syscall
	
	add $s4 $s0 $s2
	sb $a0 ($s4)	#s0 storing the text
	addi $s0 $s0 1
	bne $a0 10 r2
	#now i should have s0 s1 pt to text & word respectively
	addi $t1 $0 0		#test offset
	addi $t2 $0 0		#word offset
	addi $t7 $0 0		#countr
loop:	
	add $t5 $t1 $s1
	lb $t3 ($t5)
	add $t6 $t2 $s2
	lb $t4 ($t6)
	beq $t3 10 end		#if t3= enter, end
	bne $t3 $t4 inc		#if they don't match then go to next word
	beq $t4 32 found	#branch to found if t0=t1=' '
	addi $t1 $t1 1		#if match & not space: each offset inc by 1 word
	addi $t2 $t2 1
	j loop
inc:	bne $t4 10 here 	#not equal: if word !=enter, check t3
	beq $t3 32 found	
	j next
here:	beq $t3 32 next		#if t3 = ' ', directly increment text & decrement word
	addi $t1 $t1 1		#txt ptr++
	add $t5 $t1 $s1
	lb $t3 ($t5)
	beq $t3 10 end		#if t3 =enter then end
	bne $t3 32 inc		#else if t3!= ' ', go to next index
	j next
found:	addi $t7 $t7 1		#found 1 more
next:	addi $t1 $t1 1		#increment text
	addi $t2 $0 0		#set word offset to 0
	j loop
	
end:	bne $t4 10 prin
	addi $t7 $t7 1
prin:	li $v0 4
	la $a0 occ
	syscall	
	li $v0 1
	la $a0 ($t7)
	syscall
	
ques:	li $v0 4		#print "press 'e' to enter..."
	la $a0 eorq
	syscall	
	
	li $v0 9
	la $a0 6
	syscall
	move $s2 $v0
	addi $s0 $0 0
	jal wait1	#2nd call of wait1: read word
	beq $v0 'e' main
	beq $v0 'q' exit
	j ques
	
exit:	li $v0,10		# exit
	syscall


wait1:
	lui $t0 0xffff		
	lb $t1 0($t0)      	# control
	andi $t1 $t1 0x0001
      	beq $t1 0 wait1		#back to wait
      	lb $v0 4($t0)		# Read character
	jr $ra
wait2:
	lui $t0 0xffff
	lb $t3 8($t0)		#control
	andi $t3 $t3 0x0001
	beq $t3 0 wait2
	sb $a0 12($t0)
	jr $ra

