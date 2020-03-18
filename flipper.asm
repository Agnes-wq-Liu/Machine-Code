#name: Agnes Liu
#studentID: 260713093

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
error: .asciiz "Error: file not found" #error check
ferror: .asciiz "Error: your specification for axis is wrong"
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
write1: .asciiz "P2\n24 7\n15\n" #contents to be written
buffer:  .space 2048		# buffer for read
array: 	 .space 2048		#buffer for array
flipArray: .space 2048 	#buffer for flip
newbuff: .space 2048		#buffer for write

#any extra data you specify MUST be after this line 


	.text
	.globl main

main:
    la $a0,input	#readfile takes $a0 as input
    jal readfile


	la $a0,  array 		#$a0 will specify the "2D array" we will be flipping
	la $a1,	 flipArray 	#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip


	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1, newbuff 	#$a1 takes location of what data we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall
#open file for reading 
readfile:
	li $v0 13		
	li $a1 0		
	li $a2 0	
	syscall			
	move $s0 $v0		#$s0 storing file descriptor
#error check	
	bge $s0 $0 read		
	li $v0 4
	la $a0 error
	syscall
	j close
#read file
read: 	li $v0 14		
	move $a0 $s0		#use the file descriptor as $a0
	la $a1 buffer
	li $a2 2048
	syscall

#transfer the buffer contents into 1D int array
	la $t0 buffer		
	la $s1 array		#let $s1 store array address
	li $t4 0		#offset initiated to 0
	
loop:	lb $t1 ($t0)		#load first entry of buffer into $t1
	beq $t1 $0 addlast  #ASCII =0: current char = null (end of the file)
	beq $t1 49 tens 	#if current char =1: go to tens check
	beq $t1 32 debug 	#current char = space: go to next index
	beq $t1 10 newline	#if 1 line ends
	addi $t1 $t1 -48	#else turn ASCII value into integer value
	add $t5 $t4 $s1		#output address ptr $s0+offset to get output[i] address ptr
	sb $t1 ($t5)		#store numerical value in array
	j incre
#check first for next index =space
tens:	addi $t0 $t0 1		#move buffer ptr to next index
	lb $t2 ($t0) 		#store value in $t2
	bne $t2 32 digit  	#if next content ASCII number !=32, real 2-digit 
	add $t5 $t4 $s1		#add the output address ptr and offset to get output[i] address ptr
	addi $t1 $t1 -48
	sb $t1 ($t5)
	
newline: 	
	addi $t1 $0 -2		#give newline sign value of -2
	add $t5 $t4 $s1		#output address ptr $s0+offset to get output[i] address ptr
	sb $t1 ($t5)	
	
incre:	addi $t0 $t0 1		
	addi $t4 $t4 1
	j loop			#increment both ptrs and jump to next index

debug: addi $t0 $t0 1
	j loop

digit:  addi $t2 $t2 -48
	addi $t3 $t2 10		#t2 value plus 10 stored in $t3 
	 add $t5 $t4 $s1
	 sb $t3 ($t5)		#store t3 value to t1
	 j incre
addlast:  
	addi $t1 $0 -1		#add a negative value to indicate the end
	add $t5 $t4 $s1
	sb $t1 ($t5)
	
close: li $v0 16		
	move $a0 $s0
	syscall
	jr $ra

flip:
#Can assume 24 by 7 again for the input.txt file
	lw $t0 axis 		#load axis indication into t0
	la $t1 array		#load integer array buffer addresses in $t1 & $t2
	la $t2 flipArray
	li $t4 0		#the other coordinate starting with zero
	li $s0 0		#the output pointer offset
	beq $t0 $0 xaxis	#if axis = 0: flip around xaxis
	beq $t0 1 yaxis 	#if axis = 1: flip around yaxis
	li $v0 4
	la $a0 ferror
	syscall
	jr $ra
xaxis:	li $t3 6		#load j offset starting with 6
rowloop:	
	blt $t3 $0 endx
	mul $t5 $t3 25 		#let t5 be 25j
	add $t5 $t5 $t4 	#let t5 be (25j)+i: the offset
	add $t5 $t1 $t5 	#the right address with offset
	lb $t6 ($t5)		#store the wanted value in t6
	beq $t6 -1 endx
	add $s1 $s0 $t2		#the right output address
	sb $t6 ($s1)		#store this value in the flipArray
	addi $t4 $t4 1		#increment my i coordinate
	addi $s0 $s0 1		#increment the 
	bgt $t4 24 nextrow
	j rowloop
nextrow: 
	addi $t3 $t3 -1		#decrement j with 1
	addi $t4 $0 0		#let i go back to 0
	j rowloop
endx:   
	addi $t6 $0 -1		
	add $s1 $s0 $t2
	sb $t6 ($s1)
	jr $ra	

yaxis:  li $t3 24		#load i offset starting with 24
colloop:	
	bgt $t4 6 endy
	mul $t5 $t4 25 		#let t5 be 25i
	add $t5 $t5 $t3 	#let t5 be (24j)+i: the offset
	add $t5 $t1 $t5 	#the right address with offset
	lb $t6 ($t5)		#store the wanted value in t6
	beq $t6 -1 endy
	add $s1 $s0 $t2		#the right output address
	sb $t6 ($s1)		#store this value in the flipArray
	addi $t3 $t3 -1		#increment my j coordinate
	addi $s0 $s0 1		#increment the 
	blt  $t3 0  nextcol
	j colloop
nextcol: 
	addi $t4 $t4 1		#increment j with 
	j yaxis
endy:   
	addi $t6 $0 -1		
	add $s1 $s0 $t2
	sb $t6 ($s1)
	jr $ra	

writefile:
#slightly different from Q1.
#make sure the header matches the new dimensions!
#first i want to convert array back to ASCII and store in newbuff
	la $t0 flipArray 	#load flipped array address to t0
	la $s2 newbuff		#load newbuff address to s2
	li $t1 0		#offset initiated to 0

wloop:	lb $t2 ($t0)		#load first entry of buffer into $t2
	beq $t2 -1 null		#if finished
	beq $t2 -2 wnewline	#if meeting -2, add ASCII = 10
	bgt $t2 9 edit		#if value >9: edit

	addi $t2 $t2 48		#else turn numerical value into ASCII value (add 48)
	add $t3 $t1 $s2		#output address ptr $s2+offset to get output[i] address ptr
	sb $t2 ($t3)		#store numerical value in newbuff
	j inc1
edit:	addi $t4 $0 49		#first get 1 ASCII
	add $t3 $t1 $s2		
	sb $t4 ($t3)	
	addi $t2 $t2 38		#original value -10+48
	addi $t1 $t1 1		#increment offset by 1
	add $t3 $t1 $s2
	sb $t2 ($t3)		#store next ASCII in newbuff
	j inc2

wnewline:
	addi $t5 $0 10		#code for newline ASCII
	add $t3 $t1 $s2		
	sb $t5 ($t3)	
	j inc2
	
inc1:	addi $t1 $t1 1		#encode a space
	addi $t4 $0 32		#ASCII=32 for space
	add $t3 $t1 $s2		
	sb $t4 ($t3)		#store space in newbuff
	addi $t1 $t1 1		#encode a space
	addi $t4 $0 32		#ASCII=32 for space
	add $t3 $t1 $s2		
	sb $t4 ($t3)
	addi $t0 $t0 1		#update array ptr
	addi $t1 $t1 1		#update offset
	j wloop
	
inc2:  addi $t1 $t1 1		#encode a space
	addi $t4 $0 32		#ASCII=32 for space
	add $t3 $t1 $s2		
	sb $t4 ($t3)
	addi $t0 $t0 1		#update array ptr
	addi $t1 $t1 1		#update offset
	j wloop

inc3:	addi $t0 $t0 1		#update array ptr
	addi $t1 $t1 1		#update offset
	j wloop

null:  
	addi $t4 $0 0		#add 0 to newbuff as null-termination
	add $t3 $t1 $s2		
	sb $t4 ($t3)
#open file for writing
	add $t0 $a1 $0	#store the address of buffer stored in a1 in t0
	li $v0 13		
	la $a0 output
	li $a1 	1		
	li $a2 0	
	syscall	
	move $s2 $v0		#output file descriptor
#error check	
	bge $s2 $0 write	
	li $v0 4
	la $a0 error
	syscall
	j wclose

write:	li $v0 15		
	move $a0 $s2
	la $a1 write1
	li $a2 11
	syscall
	
	li $v0 15
	move $a0 $s2
	add $a1 $t0 $0		#restore buffer address into a1
	li $a2 2048
	syscall
#close the file (make sure to check for errors)
wclose: li $v0 16		
	move $a0 $t0
	syscall
	jr $ra
