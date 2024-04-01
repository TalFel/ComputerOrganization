#Maman11 Tal Feldman 328441670 que 3
.data
msg: .asciiz "\nPlease insert a string no longer than 30 characters: "
newln: .asciiz "\n"
inp: .space 31

.macro PRINT(%s)
	la $a0, %s
	li $v0, 4
	syscall
.end_macro

.text
.globl main

main:

#request input
PRINT(msg)

#input to inp
la $a0, inp
li $a1, 31
li $v0, 8
syscall

#new line
PRINT(newln)


li $t0 0
li $t1 0xa

#get the length of the string
LENGTH_LOOP:
	lb $t2, inp($t0)
	addi $t0, $t0, 1
	#got to the end of the string, now need to print it
	beq $t2, $zero, PRINT_LOOP
	beq $t2, $t1, PRINT_LOOP
	j LENGTH_LOOP

#print string in the needed format
PRINT_LOOP:
	#put null value in the last character of the string
	sb $zero, inp($t0)
	#steps the counter one char back
	subi $t0, $t0, 1
	#sets the char to 0xa
	sb $t1, inp($t0)
	#print current string
	PRINT(inp)
	#end prog or return to top
	beq $t0, $zero END
	j PRINT_LOOP
END:
	li $v0,10
	syscall