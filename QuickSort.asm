	.data
#Duong dan den file input
inputFilePath: .asciiz "C:/Users/Admin/Desktop/temp_MIPS/ASM_MIPS_Quicksort-master/input_2.txt"
#Duong dan den file output
outputFilePath: .asciiz "C:/Users/Admin/Desktop/temp_MIPS/ASM_MIPS_Quicksort-master/output.txt"
#so phan tu cua mang so
n: .word 0
#luu du lieu input tu file
#n max = 1000 -> 4 char
#1 word 4 byte -> max = 10 char * 1000 (word) = 10000 char
#1 char endline, ky tu space max = 998 char, 1 char eof
#max char cua fileData = 4 + 10000 + 1000 = 11004
fileData: .space 11004
#buffer trong ham itoa
buffer: .space 32
#buffer luu chuoi de ghi file
bufferOutput: .space 11000
#mang luu cac so chuyen tu input tren (Max = 1000 ptu = 4000 word)
arrNum: .space 4000
#Luu so hien tai dang token
currentNum: .asciiz ""

	.globl main
	.text
	
# -------- Ham main -------- 
main:
	#Doc file va luu du lieu vao fileData sau do dong file
	jal readFile
	#Du lieu luu vao $a1 la tham so dau vao tokenData
	la $a1, fileData	
	#Token de Lay gia tri n = so luong ptu mang
	jal tokenData
	sw $v0, n	
	#chuyen data string sang data arr
	jal strToArr	
	#quicksort, $a0 = left
	la $a0, arrNum	
	#lay dia chi phan tu cuoi cung (right) = left * (n-1) * 4 (byte)
	lw $t1, n
	addi $t1, $t1, -1	#n-1
	li $t2, 4
	mult $t1, $t2
	mflo $t3
	add $a1, $a0, $t3 #$a1 = right
	jal quickSort
	#chuyen mang ket qua sau quicksort thanh string
	jal arrToStr
	#ghi ket qua ra file va dong file	
	jal writeFile		
	#Thoat chuong trinh
	j exit
	
# -------- Ham chuyen string to integer  -------- 
atoi:
	#$a0 luu dia chi ky tu hien tai, v0 luu ket qua
	#Luu gia tri thanh ghi $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#di chuyen dau vao den dia chi hien tai
	la $t0, ($a0)
	#khoi tao result = 0
	li $v0, 0
	nextCharacter:
		#lay ky tu hien hanh
		lb $t1, ($t0)
		#kiem tra cac ky tu co nam trong '0' -> '9'
		blt $t1, 48, endLoop
		bgt $t1, 57, endLoop
		#result $v0 = $v0*10 + $t1 - 48
		mul $v0, $v0, 10
		add $v0, $v0, $t1
		sub $v0, $v0, 48
		#den ky tu ke tiep
		addi $t0, $t0, 1
		#tiep tuc den het chuoi
		b nextCharacter
	endLoop:
		#lay lai $ra va quay lai
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra

# -------- Ham doc file  -------- 
readFile:
	#Mo file voi syscall 13
	li $v0, 13
	la $a0, inputFilePath #Lay duong dan file
	li $a1, 0		 #flag = 0 -> read file, 1 write
	syscall
	move $s0, $v0	#Luu lai file descriptor
	#Doc file
	li $v0, 14		#doc file = 14
	move $a0, $s0		#file descriptor
	la $a1, fileData  	#luu thong tin vao data
	la $a2, 11004
	syscall
	#dong file
	li $v0, 16
   move $a0,$s0  		
   syscall 
	jr $ra
    
# -------- Ham token input thanh mang so nguyen -------- 
tokenData:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#lay va sao luu dia chi ky tu hien
	la $t0, currentNum
	loopToken:
		#lay ky tu hien tai voi $a1 la dia chi ky tu hien tai truyen vao
		lb $t1, ($a1)
		#kiem tra cac ky tu token
		blt $t1, 48, endToken
		bgt $t1, 57, endToken
		#luu ky tu vao currentNum
		sb $t1, ($t0)
		addi $a1, $a1, 1
		addi $t0, $t0, 1
		j loopToken
	endToken:
		#atoi va luu vao $v0
		la $a0, currentNum
		jal atoi
		#gan lai gia tri "" cho currentNum
		jal resetCurrentNumber
		#quay ve
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra
	resetCurrentNumber:
		la $t8, currentNum
		loopReset:
			lb $t9, ($t8)
			beq $t9, '\0', endReset
			li $t7, '\0'
			sb $t7, ($t8)
			addi $t8, $t8, 1
			j loopReset
		endReset:
			jr $ra
			
#  -------- Ham chuyen string sang array number -------- 
strToArr:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#Loop de tach string thanh mang so
	li $t6, 1
	lw $s1, n
	la $s2, arrNum
	loopToArr:
		bgt $t6, $s1, endToArr	#if i > N then done
		#lay ky tu hien tai va kiem tra co thuoc '0'->'9'
		lb $t7, ($a1)
		blt $t7, 48, nextChar
		bgt $t7, 57, nextChar
	token:
		#token data thanh so
		jal tokenData
		addi $t6, $t6, 1
		#luu vao mang arr num
		sw $v0, ($s2)
		addi $s2, $s2, 4
		j nextChar
	nextChar:
		addi $a1, $a1, 1
		j loopToArr
	endToArr:
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra

#  -------- Ham chuyen number sang string --------
itoa:
	 	la   $t0, buffer    #load buffer
      add  $t0, $t0, 30   #nhay den cuoi
      sb   $0, 1($t0)
      li   $t1, '0'  
      sb   $t1, ($t0)
      slt  $t2, $a0, $0   #$t2 = 1 (neu so am)
      li   $t3, 10
      beq  $a0, $0, endItoa  #dung neu bang 0
      beq $t2, 0, loop
      neg  $a0, $a0
loop:
      div  $a0, $t3       #num /= 10
      mflo $a0
      mfhi $t4            #$t4 = num % 10
      add  $t4, $t4, $t1  #$t4 = $t4 + '0'
      sb   $t4, ($t0)
      sub  $t0, $t0, 1
      bne  $a0, $0, loop
      addi $t0, $t0, 1
endItoa:
      beq  $t2, $0, returnItoa  #if negative num = -num
      addi $t0, $t0, -1
      li   $t1, '-'
      sb   $t1, ($t0)
returnItoa:
      move $v0, $t0      #$v0 = result
      jr   $ra 
      
#  -------- Ham chuyen array number sang string -------- 
arrToStr:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	la $s0, arrNum
	lw $s1, n
	la $a1, bufferOutput
	li $s4, ' '
	loopConvert:
		beq $s1, $0, endToStr	#if i = 0 then done
		subi $s1, $s1, 1
		lw $a0, ($s0)
		addi $s0, $s0, 4
		jal itoa	
		#luu $v0 vao buffer			
		loopDigits:
			lb $t0, ($v0)
			#kiem tra $t0 co thuoc '0' -> '9' khong
			blt $t0, 48, endLoopDigits
			bgt $t0, 57, endLoopDigits			
			#luu ky tu vao buffer
			sb $t0, 0($a1)
			addi $v0, $v0, 1
			addi $a1, $a1, 1		
			j loopDigits			
		endLoopDigits:
			sb $s4, 0($a1)		#xuat khoang trang giua cac so
			addi $a1, $a1, 1
			j loopConvert			
	endToStr:
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra
			
# ===============================
# ========== QuickSort ========== 
# ===============================
#$a0 = left, $a1 = right, $a2 = pivot, $t0 = leftPointer, $t1 = rightPointer, $v0 = newPivot
quickSort:
	#left > right, ket thuc
	bgt $a0, $a1, endQuickSort
	lw $a2, 0($a1)
	#luu thanh ghi $ra
	move $s0, $ra
	#vao vong lap chinh tim pivot moi
	jal partitionFunc
	#Luu cac gia tri vao stack de de quy
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $v0, 4($sp)
	sw $a1, 8($sp)
	#de quy
	addi $a1, $v0, -4
	jal quickSort
	#Lay lai cac gia tri tu stack
	lw $v0, 4($sp)
	lw $a1, 8($sp)
	#de quy
	addi $a0, $v0, 4
	jal quickSort
	#lay lai $ra de quay ve
	lw $ra, 0($sp)
	addi $sp, $sp, 12
endQuickSort:
	jr $ra

#bat dau voi ham partitionFunc (left, right, pivot) de tim pivot moi
partitionFunc:
	addi $t0, $a0, -4 #$t0 = leftPointer = left - 1
	addi $t1, $a1, 0  #$t1 = rightPointer
	la $t2, arrNum	  #$t2 = arrNum
loopLeft:
	#while A[++leftPointer] < pivot
	addi $t0, $t0, 4
	lw $t3, 0($t0)
	#arr[leftP] >= pivot  -> loopRight
	bge $t3, $a2, loopRight
	j loopLeft
loopRight:
	#if left > right then done loop
	bgt $t2, $t1, doneLoop
	addi $t1, $t1, -4
	lw $t3, 0($t1)
	#arr[rightP] <= pivot  -> done loop
	ble $t3, $a2, doneLoop
	j loopRight
doneLoop:
	#if leftPointer >= rightPointer then return, else swap
	bge $t0, $t1, return
	#hoan doi (swap) 
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)
	j loopLeft
return:
	#swap leftPointer, right return leftPointer (new pivot)
	lw $t2, 0($t0)
	lw $t3, 0($a1)
	sw $t3, 0($t0)
	sw $t2, 0($a1)
	#pivot moi de de quy
	move $v0, $t0
	jr $ra

# -------- Ham ghi vao file  --------
writeFile: 
	#mo file ghi
	li $v0, 13
	la $a0, outputFilePath
	li $a1, 1
	li $a2, 0
	syscall
	move $s1, $v0	
	#ghi file
	li $v0, 15
	move $a0, $s1
	la $a1, bufferOutput
	la $a2, 11000
	syscall
	#dong file
	# $s1 = file descriptor 
	li $v0, 16
	move $a0, $s1
	syscall	
	jr $ra

# ---- Ham Thoat chuong trinh
exit:
	li $v0, 10
	syscall

#####################################################################