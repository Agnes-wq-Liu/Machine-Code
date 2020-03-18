#name: Agnes Liu
#studentID: 260713093

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
error: .asciiz "Error: file not found" #error checker
buffer:  .space 2048		# buffer for upto 2048 bytes
array: .space 2048
cropped: .space 2048
newbuff: .space 2048
x1: .word 1
x2: .word 2
y1: .word 3
y2: .word 4
len: .space 1	#length: x2-x1+1
wid: .space 1	#width: y2-y1+1
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	la $a0 x1
    	la $a1 x2
    	la $a2 y1
    	la $a3 y2
    	addi $s0 $sp 16
    	la $s0 array
    	addi $s1 $sp 20
    	la $s1 cropped
	jal crop

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
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


crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#There are more than 4 arguments, so use the stack accordingly.
	#16($sp)=array
	#20($sp)=cropped
#start with in-x=x1, in-y = y1
	la $s0 array
	la $s1 cropped	
	#la $s0 16($sp)
	#la $s1 20($sp)		#load the address of array & cropped into s0 & s1
	lb $t0 ($a0)		#(initial x)
	lb $t1 ($a2)		#(initial y)
	lb $s2 ($a0)		#load x1 to s2
	lb $s3 ($a2)		#load y1 to s3
	lb $t7 ($a1)		#x2
	lb $t8 ($a3)		#y2
	sub $t2 $t7 $s2 	#x2-x1
	addi $t2 $t2 1		#x2-x1+1: t2 storing my len to multiply
	sb $t2 len
	sub $t3 $t8 $s3		#y2-y1
	addi $t3 $t3 1		#y2-y1+1: t3 storing my wid
	sb $t3 wid
	addi $t7 $t7 -1
	#get the index of array: ly+x
croploop:
	bgt $t1 $t8 cropend	#if y>y2:outof range now
	mul $t6 $t1 25		#24y
	add $t6 $t6 $t0		#24y+x
	add $t6 $t6 $s0		#in-ptr
	lb $t5 ($t6)		#load from array to t5
	#check
	li $v0 1
	la $a0 ($t5)
	syscall
	#end of check
#	addi $s1 $s1 1
	sb $t5 ($s1)		#store t5 value in cropped ptr
	addi $s1 $s1 1

	bgt $t0 $t7 nextrow	#when x >x2: nextrow
	addi $t0 $t0 1		#increment x by 1
	j croploop
nextrow:
	add $t0 $0 $s2		#x back to 0
	addi $t1 $t1 1 		#y+=1
	j croploop	
cropend:
#write a -1 indicating end of string
	addi $t7 $0 -1
	#addi $s1 $s1 1
	sb $t7 ($s1)
	jr $ra	

writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

	la $t0 cropped		#load flipped array address to t0
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
	lb $t2 len
	bgt $t2 9 double
	addi $t2 $t2 48
	addi $t5 $t5 1
	sb $t2 ($t5)
	j s
double:
	li $t3 49
	addi $t5 $t5 1
	sb $t3 ($t5)
	addi $t2 $t2 38
	addi $t5 $t5 1
	sb $t2 ($t5)
	#space
s:	addi $t2 $0 32
	addi $t5 $t5 1
	sb $t2 ($t5)
	#width
	lb $t2 wid
	bgt $t2 9 doubl
	addi $t2 $t2 48
	addi $t5 $t5 1
	sb $t2 ($t5)
	j n
doubl:	li $t3 49
	addi $t5 $t5 1
	sb $t3 ($t5)
	addi $t2 $t2 38
	addi $t5 $t5 1
	sb $t2 ($t5)
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
	li $a2 10
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
