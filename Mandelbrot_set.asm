#MIPS Projekt
#Temat:6 Zbiory Mandelbrota
#Szymon Sidoruk 12N

.data
buff: .space 4
size: .space 4
offset: .space 4
width: .space 4
height: .space 4
start: .space 4
padding: .space 1

hello: .asciiz "Mandelbrot set\n"
input: .asciiz "inon.bmp"
output: .asciiz "output.bmp"
error: .asciiz "File error\n"

.text
.globl main

main:
	li $v0, 4
	la $a0, hello
	syscall
read_file:
	#------------------------
	#register content
	#------------------------
	#$t0: file descriptor
	#$s0: size
	#$s1: memory address
	#$s2: width
	#$s3: heigth
	#------------------------
	li $v0, 13
	la $a0, input
	li $a1, 0
	li $a2, 0
	syscall
	
	move $t0, $v0
	
	bltz $t0, file_error
	
	li $v0, 14
	move $a0, $t0
	la $a1, buff
	la $a2, 2
	syscall
	
	li $v0, 14
	move $a0, $t0
	la $a1, size
	la $a2, 4
	syscall
	
	lw $s0, size
	
	li $v0, 9
	move $a0, $s0
	syscall
	
	move $s1, $v0
	sw $s1, start
	
	li $v0, 14
	move $a0, $t0
	la $a1, buff
	la $a2, 4
	syscall
	
	li $v0, 14
	move $a0, $t0
	la $a1, offset
	la $a2, 4
	syscall
	
	li $v0, 14
	move $a0, $t0
	la $a1, buff
	la $a2, 4
	syscall
	
	li $v0, 14
	move $a0, $t0
	la $a1, width
	la $a2, 4
	syscall
	
	lw $s2, width
	
	li $v0, 14
	move $a0, $t0
	la $a1, height
	la $a2, 4
	syscall
	
	lw $s3, height
	
	li $v0, 16
	move $a0, $t0
	syscall
read_bytes:
	li $v0, 13
	la $a0, input
	li $a1, 0
	li $a2, 0
	syscall
	
	move $t0, $v0
	
	bltz $t0, file_error
	
	li $v0, 14
	move $a0, $t0
	la $a1, ($s1)
	la $a2, ($s0)
	syscall
	
	li $v0, 16
	move $a0, $t0
	syscall
	
	lw $t9, offset
	addu $s1, $s1, $t9
math:
	#0x80000000 = -16 // -32
	#0x7fffffff = 16  //  32
	#$s4 x per pixel
	#$s5 y per pixel
	#$t5 horizontal value
	#$t6 vertical value
	#range -2 - 2
	#0xf0000000 - 0x10000000
	#1 - 0x08000000
	li $t6, 0xf0000000
	li $t5, 0xf0000000
	li $s6, 0x20000000
	div $s4, $s6, $s2
	mflo $s4
	div $s5, $s6, $s3
	mflo $s5
	mul $s6, $s2, $s3 # total pixels
	li $t9,0 #no. pixels iterator
padding_check:
	mul $t8, $s2, 3
	andi $t8, $t8, 0x00000003
	
	li $t7, 1 #pixels in line iterator
	
	beq $t8, 0, padding_0
	beq $t8, 1, padding_1
	beq $t8, 2, padding_2
	beq $t8, 3, padding_3	
padding_0:
	li $t8, 0
	sw $t8, padding
	b loop_line
padding_1:
	li $t8, 3
	sw $t8, padding
	b loop_line
padding_2:
	li $t8, 2
	sw $t8, padding
	b loop_line
padding_3:
	li $t8, 1
	sw $t8, padding
loop_line:
	beq $t9, $s6, save_file
	jal pixel
	lw $s2, width
	beq $t7, $s2, next_line
	add $t5, $t5, $s4
	b loop_line
file_error:
	li $v0, 4
	la $a0, error
	syscall
	b end
save_file:	
	li $v0, 13
	la $a0, output
	li $a1, 1
	li $a2, 0
	syscall
	
	move $t0, $v0
	
	bltz $t0, file_error
	
	lw $s0, size
	lw $s1, start
		
	li $v0, 15
	move $a0, $t0
	la $a1, ($s1)
	la $a2, ($s0)
	syscall
	
	li $v0, 16
	move $a0, $t0
	syscall
end:
	li $v0, 10
	syscall
pixel:
	move $s7, $ra  #saving $ra to main loop
	li $t3,0x00000000	# Zx
	li $t8,0x00000000	# Zy
	li $s2,0x00000000
	li $s3,0x00000000
	li $t4,-1
pixel_loop:
	# 4 = maximum radius
	# 4 = 0x20000000
	add $t4, $t4, 1
	bge $t4, 100, color
	
	#new Zy
	mul $t2, $t3, $t8
	mfhi $t1
	sll $t1, $t1, 5
	mflo $t2
	sra $t2, $t2, 27
	or $t8, $t2, $t1
		
	sll $t8, $t8, 1
	bgt $t8, 0x20000000, color
	blt $t8, 0xe0000000, color
	add $t8, $t8, $t6
	
	#new Zx
	sub $t3, $s2, $s3
	bgt $t3, 0x20000000, color
	blt $t3, 0xe0000000, color
	add $t3, $t3, $t5
	
	# $s2 Zx*Zx
	# $s3 Zy*Zy
	mul $t2, $t3, $t3
	mfhi $t1
	sll $t1, $t1, 5
	mflo $t2
	srl $t2, $t2, 27
	or $s2, $t2, $t1
	
	bgt $s2, 0x20000000, color
	blt $s2, 0x00000000, color
	
	mul $t2, $t8, $t8
	mfhi $t1
	sll $t1, $t1, 5
	mflo $t2
	srl $t2, $t2, 27
	or $s3, $t2, $t1
	
	bgt $s3, 0x20000000, color
	blt $s3, 0x00000000, color
	
	add $t0, $s2, $s3
	blt $t0, 0x20000000, pixel_loop
color:
	bge $t4, 100, color_black
	bge $t4, 75, color_brown
	bge $t4, 50, color_dark_green
	bge $t4, 25, color_light_green
	#bge $t4, 15, color_light_blue
	bge $t4, 10, color_dark_blue
	#bge $t4, 8, color_purple
	#bge $t4, 6, color_pink
	#bge $t4, 4, color_red
	#bge $t4, 2, color_orange
	bge $t4, 1, color_yellow
	b color_white
new:
	
	
	jr $ra
square:
	
	
	jr $ra
next_line:
	add $t9, $t9, $t7
	li $t7, 0
	li $t5, 0xf0000000
	add $t6, $t6, $s5
	lw $t8, padding
	add $s1, $s1, $t8
	b loop_line
return:
	jr $ra
color_black:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_brown:
	li $t0, 0x2a		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x2a		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xa5		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_dark_green:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x64		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_light_green:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_light_blue:
	li $t0, 0xeb		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xce		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x87		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_dark_blue:
	li $t0, 0x8b		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_purple:
	li $t0, 0x80		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x80		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_pink:
	li $t0, 0xcb		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xc0		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_red:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0x00		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_orange:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xa5		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_yellow:
	li $t0, 0x00		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
color_white:
	li $t0, 0xff		#B
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#G
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	li $t0, 0xff		#R
	sb $t0, ($s1)
	addiu $s1, $s1, 1
	
	addiu $t7, $t7, 1
	jr $s7
