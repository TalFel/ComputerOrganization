#Maman11 Tal Feldman 328441670 que 4
.data
msg: .asciiz "\nPlease insert a stringocta no longer than 30 characters: "
wrong: .asciiz "\nwrong input\n"
newln: .asciiz "\n"
spaces: .asciiz "  "
stringocta: .space 31
NUM: .space 10
sortarray: .space 10
.text
.macro SYS_PRINT(%s)
	la $a0, %s
	li $v0, 4
	syscall
.end_macro
.globl main

main:

#request input
SYS_PRINT(msg)

#input to inp
la $a0, stringocta
li $a1, 31
li $v0, 8
syscall
SYS_PRINT(newln)

#call procedure is_valid
la $a0, stringocta
li, $v0, 0
jal is_valid

beq $v0, 0, main #input was not valid
move $t3, $v0 #store number for next procedures

#input is valid - call procedure convert
move $a2, $t3
la $a0, stringocta
la $a1, NUM
jal convert

#call procedure print for unsorted array
move $a2, $t3
la $a1, NUM
jal print

#call procedure sort
move $a2, $t3
la $a3, sortarray
la $a1, NUM
jal sort

#call procedure print for sorted array
SYS_PRINT(newln)
move $a2, $t3
la $a1, sortarray
jal print




#---procedures---#
END:
	li $v0,10
	syscall

is_valid:
	#first char
	lb $t0, ($a0)
	addu $a0, $a0, 1
	
	#first char is null/enter - valid
	beq $t0, $zero, ret
	beq $t0, 0xa, ret
	
	#second char
	lb $t1, ($a0)
	addu $a0, $a0, 1
	
	
	#base-7 numbers
	bgt $t0, '7', not_valid
	blt $t0, '0', not_valid

	bgt $t1, '7', not_valid
	blt $t1, '0', not_valid


	#$ char
	lb $t0, ($a0)
	addu $a0, $a0, 1
	
	addiu $v0, $v0, 1
	beq $t0, '$', is_valid #continue with procedure if valid
	
	j not_valid #not valid, return to main

ret: #return to ra
	jr $ra
not_valid: #string not valid
	SYS_PRINT(wrong)
	li $v0, 0
	jr $ra
convert:
	#numbers
	lb $t1, ($a0)
	addu $a0, $a0, 1
	lb $t2, ($a0)
	addu $a0, $a0, 2
	
	#ascii to dec
	subiu $t1, $t1, 48
	subiu $t2, $t2, 48
	
	#base-10 from octa
	li $t0, 8
	mult $t1, $t0
	mflo $t1
	add $t1, $t1, $t2
	
	#move to next number
	sb $t1, ($a1)
	addu $a1, $a1, 1
	subi $a2, $a2, 1
	bnez $a2, convert
	
	jr $ra
print:
	#print element
	lb $a0, ($a1)
	li $v0, 1
	syscall

	SYS_PRINT(spaces)
	
	#move to next element
	addu $a1, $a1, 1
	subi $a2, $a2, 1
	bnez $a2, print
	
	jr $ra
sort:
	#for loop counter
	li $t0, 0
	subi $a2, $a2, 1
	move $t6, $a3
	#calls outer loop with params
	bnez $a2, outer_loop
	#return array address and return to ra
	move $a3, $t6
	jr $ra

outer_loop: 
	bgt $t0, $a2 ret #for loop condition
	li $t1, 0 #reset inner loop counter
	move $t2, $ra #save ra
	move $t6, $a1 #save array address
	li $t4, 63 #init min
	jal inner_loop #call inner loop
	
	#insert min to new array
	sb $t4, ($a3)
	addu $a3, $a3, 1
	
	#delete min from last array
	li $t4, 63
	sb $t4, ($t7)
	
	move $a1, $t6 #move array adress back
	move $ra, $t2 #move ra adress back
	
	#add to counter
	addi $t0, $t0, 1
	j outer_loop

inner_loop:
	bgt $t1, $a2 ret #for loop condition
	lb $t5, ($a1) #get next number
	#move to next element
	addu $a1, $a1, 1
	addi $t1, $t1, 1
	bge $t5, $t4, inner_loop #check if greater than min
	#new min
	move $t4, $t5
	la $t7, -1($a1) #save min adress in array to delete
	j inner_loop