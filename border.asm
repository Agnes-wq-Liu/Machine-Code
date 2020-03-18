#name: Agnes Liu
#studentID: 260713093

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output
error: .asciiz "Error: file not found" #error checker
borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
array: .space 2048
borded: .space 2048
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 


	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,array		#$a1 will specify the "2D array" we will be flipping
	la $a1,borded		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
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

bord:
#a0=array
#a1=borded
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
	la $s0 array		#array
	la $s1 borded		#borded
	li $t1 0 		#y start with 0
	lb $s2 borderwidth	#s2 = w
	mul $t2 $s2 2		#2w
	addi $t2 $t2 25		#t2 = 24+2w
	addi $t3 $s2 25 	#t3 = 24+w 
	addi $s3 $s2 7		#s3 = 7+w
	add $s4 $s3 $s2		#s4 = 7+2w
	li $t4 15
bloop:	li $t0 0		#x start with 0		
	blt $t1 $s2 hori	#when y<w, upper border
	beq $t1 $s4 bend	#when y = 7+2w, ending
	bge $t1 $s3 hori	#y>=7+w go to lower border
	
body:	
	sb $t4 ($s1)
	addi $s1 $s1 1
	addi $t0 $t0 1
	#addi $t7 $s2 -1
	blt $t0 $s2 body	#if x <w then still add 15
body2:	
	lb $t5 ($s0)		#load from array
	sb $t5 ($s1)		#store to borded
	addi $s0 $s0 1		#increment array ptr
	addi $s1 $s1 1		#increment borded 
	addi $t0 $t0 1
	blt $t0 $t3 body2	#if out-x<24+w still add from array	
	
body3:	
	sb $t4 ($s1)
	addi $s1 $s1 1
	addi $t0 $t0 1
	#addi $t7 $t2 -1
	blt $t0 $t2 body3	#if out-x <24+2w still add 15
	addi $t1 $t1 1
	j bloop
	
hori:	#store 15
	sb $t4 ($s1)
	addi $s1 $s1 1
	addi $t0 $t0 1		#counter ++
	blt $t0 $t2 hori	#if x<24+2w, again
	addi $t1 $t1 1		#else y+=1
	j bloop

bend:	
	addi $t7 $0 -1
	sb $t7 ($s1)
	jr $ra

writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
	la $t0 borded		#load flipped array address to t0
	la $s2 newbuff		#load newbuff address to s2
	li $t1 0		#offset initiated to 0

#make the headerbuff
	la $t5 headerbuff	
	addi $t2 $0 80		#p ASCII
	sb $t2 ($t5)
	addi $t5 $t5 1
	addi $t2 $0 50		#2
	sb $t2 ($t5)
	addi $t2 $0 10
	addi $t5 $t5 1
	sb $t2 ($t5)		#\n
	#length
	lb $t2 borderwidth
	mul $t2 $t2 2		#borderwidh*2
	addi $t6 $t2 24		#x+2w
	addi $t7 $t2 7		#y+2w
	li $t3 50
	addi $t5 $t5 1
	sb $t3 ($t5)
	addi $t6 $t6 28
	addi $t5 $t5 1
	sb $t6 ($t5)
	#space
s:	addi $t2 $0 32
	addi $t5 $t5 1
	sb $t2 ($t5)
	#width
	bgt $t7 9 doubl
	addi $t7 $t7 48
	addi $t5 $t5 1
	sb $t7 ($t5)
	j n
doubl:	li $t3 49
	addi $t5 $t5 1
	sb $t3 ($t5)
	addi $t7 $t7 38
	addi $t5 $t5 1
	sb $t7 ($t5)
	#\n
n:	addi $t2 $0 10
	addi $t5 $t5 1
	sb $t2 ($t5)
	#15
	addi $t2 $0 49
	addi $t5 $t5 1
	sb $t2 ($t5)
	addi $t2 $0 53
	addi $t5 $t5 1
	sb $t2 ($t5)
	#\n
	addi $t2 $0 10
	addi $t5 $t5 1
	sb $t2 ($t5)
			
wloop:	lb $t2 ($t0)		#load first entry of buffer into $t2
	beq $t2 -1 null		#if finished
	beq $t2 -2 wnewline	#if meeting -2, add ASCII = 10
	bgt $t2 9 edit		#if value >9: edit

	addi $t2 $t2 48		#else turn numerical value into ASCII value (add 48)
	add $t3 $t1 $s2		#output address ptr $s2+offset to get output[i] address ptr
	sb $t2 ($t3)		#store numerical value in newbuff
	j inc2
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
	j inc3
	
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
	la $a1 headerbuff		#note: need modification
	li $a2 12
	syscall
	
	li $v0 15
	#move $a0 $s2
	la $a1, ($t0)		#restore buffer address into a1
	li $a2 2048
	syscall
#close the file (make sure to check for errors)
wclose: li $v0 16		
	move $a0 $t0
	syscall
	jr $ra
