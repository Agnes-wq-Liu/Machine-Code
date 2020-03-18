#name: Agnes Liu
#studentID: 260713093

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output
error: .asciiz "Error: file not found" #error check
buffer:  .space 2048		# buffer for upto 2048 bytes
write1: .asciiz "P2\n24 7\n15\n" #contents to be written

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile: 
#Open the file to be read,using $a0
#Conduct error check, to see if file exists
# You will want to keep track of the file descriptor*
	li $v0 13		#open file for reading 
	li $a1 0		
	li $a2 0	
	syscall			#store returned reading values to a1 
	move $t0 $v0
	
	bge $t0 $0 read		#error check
	li $v0 4
	la $a0 error
	syscall
	j close

# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
read: 	li $v0 14		#read file
	move $a0 $t0
	la $a1 buffer
	li $a2 2048
	syscall
	
	li $v0 4		#print the buffer
	la $a0 buffer
	syscall
	
# close the file (make sure to check for errors)	
close: li $v0 16		#close file
	move $a0 $t0
	syscall
	jr $ra
# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer

writefile:
#open file to be written to, using $a0.
	add $t0 $a1 $0	#store the address of buffer stored in a1 in t0
	li $v0 13		#open file for writing
	la $a0 output
	li $a1 	1		
	li $a2 0	
	syscall	
	move $s0 $v0		#output file descriptor
	
	bge $s0 $0 write	#error check
	li $v0 4
	la $a0 error
	syscall
	j close
#write the specified characters as seen on assignment PDF:
write:	li $v0 15		
	move $a0 $s0
	la $a1 write1
	li $a2 11
	syscall
#write the content stored at the address in $a1.
	li $v0 15
	move $a0 $s0
	add $a1 $t0 $0		#restore buffer address into a1
	li $a2 2048
	syscall

#close the file (make sure to check for errors)
wclose: li $v0 16
	move $a0 $t0
	syscall
	jr $ra
