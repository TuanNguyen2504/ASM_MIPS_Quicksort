.data
#Duong dan den file input
inputFilePath: .asciiz "D:/BACHELOR OF IT/SEMETER FOUR/KTMT&HOPNGU/input.txt"
#Duong dan den file output
outputFilePath: .asciiz "D:/BACHELOR OF IT/SEMETER FOUR/KTMT&HOPNGU/output.txt"
#cau xuat thong bao (xoa khi hoan thanh)
outputArrNotifi: .asciiz "------ Output Array: "
space: .asciiz " "
#so phan tu cua mang so
n: .word 0
#luu du lieu input tu file
#n max = 1000 -> 4 char
#1 word 4 byte -> max = 10 char * 1000 (word) = 10000 char
#1 char endline, ky tu space max = 998 char, 1 char eof
#max char cua fileData = 4 + 10000 + 1000 = 11004
fileData: .space 11004
#buffer trong ham itoa
buffer:		.space 32
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
	#Doc file va luu du lieu vao fileData
	jal readFile
	#dong file vua doc
	jal closeFile
	
	#Du lieu luu vao $a1 la tham so dau vao tokenData
	la $a1, fileData
	
	#Token de Lay gia tri n = so luong ptu mang
	jal tokenData
	sw $v0, n
	
	#chuyen data string sang data arr
	jal strToArr
	
	#quicksort
	la $a0, arrNum	#$a0 = left
	#lay dia chi phan tu cuoi cung (right) = left * (n-1) * 4 (byte)
	lw $t1, n
	addi $t1, $t1, -1	#n-1
	li $t2, 4
	mult $t1, $t2
	mflo $t3
	add $a1, $a0, $t3 #$a1 = right
	jal quickSort
	
	#xuat mang
	jal outputArray
	
	jal arrToStr

	# Chua ro cho nay comment nhu the nao
	la $a1, bufferOutput
	
	# Ghi ra file
	jal writeFile
	
	
	#Thoat chuong trinh
	j exit
	
# ----------- Ham xuat mang ra console, de kiem tra khi code (xoa khi hoan thanh) -------------
outputArray:
		#Luu thanh ghi $ra vao stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		#Xuat thong bao mang:
		li $v0, 4
		la $a0, outputArrNotifi
		syscall
		#gan cac du lieu t0 = n, t1 = i = 1
		lw $t0, n
		addi $t1, $0, 1
		la $a1, arrNum	
		loopOutputArr:
			#if i > N
			bgt $t1, $t0, doneOuputArr
			#print
			li $v0, 1		
			lw $a0,($a1)
			syscall
			jal printSpace
			#tang don vi		
			addi $a1, $a1, 4		
			addi $t1, $t1, 1		
			j loopOutputArr
		doneOuputArr:
			#Phuc hoi thanh ghi ra
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
printSpace:
		li $v0, 4
		la $a0, space
		syscall
		jr $ra	
		
		
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
		li $t2, 10
		mul $v0, $v0, $t2
		add $v0, $v0, $t1
		sub $v0, $v0, 48
		# den ky tu ke tiep
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
	jr $ra

#  -------- Ham Close file sau khi doc file --------
# $s0 = file descriptor 
closeFile:
	li $v0, 16
    move $a0,$s0  		
    syscall
    jr $ra
    


# ------- Ham ghi file  -------- 
writeFile:
	#mo file ghi voi syscall 13
	li $v0, 13
	la $a0, outputFilePath #Lay duong dan file
	li $a1, 1 	#flag = 0 -> read file, 1 write
	syscall
	move $s1, $v0

	#ghi file
	li $v0, 15
	move $a0, $s1
	la $a1, bufferOutput
	la $a2, 11000
	syscall
	
	#dong file
	li $v0, 16
	move $a0, $s1
	syscall

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


#  -------- Ham chuyen array number sang string -------- 
arrToStr:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#khai bao vong lap
	li $t6, 1
	lw $s1, n
	la $s2, bufferOutput
	li $t8, ' '
	loopConvert:
		bgt $t6, $s1, endToStr	#if i > N then done
		# Lam gi do cho nay
		jal itoa
	looptoWrite:
		#lay ky tu hien tai va kiem tra co thuoc '0'->'9'
		lb $t7, ($v0)
		blt $t7, 48, writeSpace
		bgt $t7, 57, writeSpace
	writeByte:
		# Ghi du lieu la cac ky tu so
		sb $v0,($s2)
		addi $s2, $s2, 1
		addi $v0, $v0, 1
		j looptoWrite
	writeSpace:
		# Ghi dau cach giua cac con so
		addi $v0, $v0, 1
		sb $t8, ($s2)
		addi $s2, $s2, 1
		addi $t6, $t6, 1
		j loopConvert
	endToStr:
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra
	

#  -------- Ham chuyen number sang string --------
itoa:
	 	la   $t0, buffer    # load buf
      add  $t0, $t0, 30   # seek the end
      sb   $0, 1($t0)      # null-terminated str
      li   $t1, '0'  
      sb   $t1, ($t0)     # init. with ascii 0
      slt  $t2, $a0, $0   # keep the sign
      li   $t3, 10        # preload 10
      beq  $a0, $0, iend  # end if 0
      beq $t2, 0, loop
      neg  $a0, $a0
loop:
      div  $a0, $t3       # a /= 10
      mflo $a0
      mfhi $t4            # get remainder
      add  $t4, $t4, $t1  # convert to ASCII digit
      sb   $t4, ($t0)     # store it
      sub  $t0, $t0, 1    # dec. buf ptr
      bne  $a0, $0, loop  # if not zero, loop
      addi $t0, $t0, 1    # adjust buf ptr
iend:
      beq  $t2, $0, nolz  # was < 0?
      addi $t0, $t0, -1
      li   $t1, '-'
      sb   $t1, ($t0)
nolz:
      move $v0, $t0     # return the addr.
      jr   $ra           # of the string
      
			
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

# ---- Ham Thoat chuong trinh
exit:
	li $v0, 10
	syscall
