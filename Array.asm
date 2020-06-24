	.data
#mang so nguyen dong 4 byte
arr: .space 1024
inputNumArrNotifi: .asciiz "Nhap so luong phan tu cua mang: "
inputArrNotifi: .asciiz "Nhap 1 phan tu: "
#so luong phan tu
n: .word 0
#bien option
option: .word 0
#max option
maxOption: .word 6
#Cac option menu
menuNotifi: .asciiz "\nCac chuc nang cua chuong trinh:\n"
optionNotifi1: .asciiz "1. Xuat ra cac phan tu\n"
optionNotifi2: .asciiz "2. Tinh tong cac phan tu\n"
optionNotifi3: .asciiz "3. Liet ke cac phan tu la so nguyen to\n"
optionNotifi4: .asciiz "4. Tim max\n"
optionNotifi5: .asciiz "5. Tim phan tu co gia tri x\n"
optionNotifi6: .asciiz "6. Thoat chuong trinh\n"
#thong bao nhap option
optionNotifi: .asciiz "Ban chon option nao >> "
outputArrNotifi: .asciiz " ------ Output Array: "
sumArrNotifi: .asciiz " ------ Sum Array: "
maxArrNotifi: .asciiz " ------ Max Array: "
inputXValueNotifi:.asciiz " Nhap gia tri x can tim: "
xNotFoundNotifi: .asciiz " ------ Khong tim thay "
xFoundNotifi: .asciiz " ------ Tim thay x -> tai vi tri thu:  "
primeNumNotifi: .asciiz " ------ Cac so nguyen to trong mang:  "
#thong bao nhap sai
inputWarning: .asciiz "\nNhap sai, nhap lai !\n"
#ky tu xuong dong
endl: .asciiz "\n"
space: .asciiz " "
	.globl main
	.text
# --- Ham main ---
main:
	#Nhap mang
	jal inputArray
	#Chon option
	loopInputOption:
		#xuat menu
		jal displayMenu
		#xuat thong bao nhap
		li $v0, 4
		la $a0, optionNotifi
		syscall
		#nhap option
		li $v0, 5
		syscall
		bgtz $v0, checkInputOption #if input > 0, check input <= 6
		jal errorMessage
		j loopInputOption
		checkInputOption:
			lw $t0, maxOption
			ble $v0, $t0,validOption #if input <= 6, option hop le
			jal errorMessage
			j loopInputOption
		validOption:
			sw $v0, option
	# Xu ly case option
	lw $s1, option	#lay gia tri option
	#case 1:
	addi $t1, $s1, -1
	bne $t1, $0, case2
	jal outputArray
	j loopInputOption
	case2:
		addi $t1, $s1, -2
		bne $t1, $0, case3
		jal sumArray
		j loopInputOption
	case3:
		addi $t1, $s1, -3
		bne $t1, $0, case4
		jal listPrimeNumber
		j loopInputOption
	case4:
		addi $t1, $s1, -4
		bne $t1, $0, case5
		jal findMax
		j loopInputOption
	case5:
		addi $t1, $s1, -5
		bne $t1, $0, case6
		jal findValueX
		j loopInputOption
	case6:
		j exit
	
# --- Ham nhap mang so ---
inputArray:
	#thong bao nhap chuoi
	li $v0, 4
	la $a0, inputNumArrNotifi
	syscall
	#Nhap so luong phan tu (voi N > 0)
	loopInputNumArr:
		li $v0, 5
		syscall
		bgtz $v0, doneInputNumArr	#if n > 0
		jal errorMessage
		j loopInputNumArr
	doneInputNumArr:
		sw $v0, n	#Luu lai so luong phan tu vao n
		#Sao luu cac gia tri su dung cho loop
		lw $s1, n	#s1 = n
		li $t0, 1	#t0 = i = 1
		la $a1, arr	#lay dia chi cua array luu vao thanh ghi
	#Nhap mang
	loopInputArr:
		bgt $t0, $s1, doneInputArr	#if i > N then done
		#Nhac thong bao nhap
		li $v0, 4
		la $a0, inputArrNotifi
		syscall
		#nhap cac phan tu
		li $v0, 5
		syscall
		sw $v0, ($a1)			#luu gia tri vua nhap vao mang
		addi $a1, $a1, 4		#di chuyen con tro a[0]->a[1]
		addi $t0, $t0, 1		#i++
		j loopInputArr			#quay lai
	doneInputArr:
	#thoat ham
		jr $ra
	
# --- Ham hien thi Menu ---
displayMenu:
	li $v0, 4
	la $a0, menuNotifi
	syscall
	li $v0, 4
	la $a0, optionNotifi1
	syscall
	li $v0, 4
	la $a0, optionNotifi2
	syscall
	li $v0, 4
	la $a0, optionNotifi3
	syscall
	li $v0, 4
	la $a0, optionNotifi4
	syscall
	li $v0, 4
	la $a0, optionNotifi5
	syscall
	li $v0, 4
	la $a0, optionNotifi6
	syscall
	jr $ra
	
# --- 1. Xuat mang so ---
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
	la $a1, arr	
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
		
# --- 2. Tinh tong ---
sumArray:
	#Xuat thong bao mang:
	li $v0, 4
	la $a0, sumArrNotifi
	syscall
	#gan cac du lieu t0 = n, t1 = i = 1, s2 = sum
	lw $t0, n
	addi $t1, $0, 1
	la $a1, arr
	li $s2,0
	loopSumArr:
		#if i > N
		bgt $t1, $t0, doneSumArr
		#sum
		lw $t2, 0($a1)	#t2 = arr[i]
		add $s2, $s2, $t2 
		#tang don vi		
		addi $a1, $a1, 4		
		addi $t1, $t1, 1		
		j loopSumArr
	doneSumArr:
		li $v0, 1
		move $a0, $s2
		syscall
		jr $ra
		
# --- 3. Liet ke cac thanh phan la so nguyen to ---
listPrimeNumber:
	#Xuat thong bao tim so nt
	li $v0, 4
	la $a0, primeNumNotifi
	syscall
	#Gan du lieu
	lw $t0, n
	addi $t1, $0, 1
	la $a1, arr
	#Lap va tim so nguyen to
	loopPrimeArr:
		#if i > N
		bgt $t1, $t0, donePrimeArr
		#t2 = arr[i]
		lw $t2, 0($a1)
		#Tang don vi
		addi $a1, $a1, 4		
		addi $t1, $t1, 1
		#if arr[i] > 2 thi xet no co phai SNT ?
		bgt $t2, 2, isPrimeNumber
		j loopPrimeArr
	isPrimeNumber:
		#Gan bien chay j = 1 -> arr[i] - 1
		addi $t3, $t2, -1
		addi $t4, $0, 2
		loopIsPrime:
			#if j > arr[i] - 1 thi arr[i] la snt va thoat vong lap
			bgt $t4, $t3, doneIsPrimeAndPrint
			#if arr[j] chia het j thi thoat
			div $t2, $t4
			mfhi $t5
			addi $t4, $t4, 1
			beq $t5, $0, doneIsPrime
			j loopIsPrime
		doneIsPrime:
			j loopPrimeArr
		doneIsPrimeAndPrint:
			sw $ra, -4($sp) #Luu thanh ghi $ra vao stack
			#In so NT
			li $v0, 1
			move $a0, $t2
			syscall
			jal printSpace	#In khoang trang
			lw $ra, -4($sp)	#Phuc hoi thanh ghi $ra
			j loopPrimeArr
	donePrimeArr:
		jr $ra

# --- 4. tim phan tu lon nhat ---
findMax:
	#Xuat thong bao tim max
	li $v0, 4
	la $a0, maxArrNotifi
	syscall
	#gan cac du lieu t0 = n, t1 = i = 1, s2 = max
	lw $t0, n
	addi $t1, $0, 1
	la $a1, arr
	lw $s2, 0($a1)
	loopMaxArr:
		#if i > N
		bgt $t1, $t0, doneMaxArr
		#t2 = arr[i]
		lw $t2, 0($a1)	
		#tang don vi
		addi $a1, $a1, 4		
		addi $t1, $t1, 1
		#if max < arr[i] => max = arr[i] 
		blt $t2, $s2, notMax
		move $s2, $t2				
		j loopMaxArr
		notMax:
			j loopMaxArr
	doneMaxArr:
		li $v0, 1
		move $a0, $s2
		syscall
		jr $ra
	
# --- 5. Tim phan tu co gia tri x ---
findValueX:
	#Thong bao nhap x
	li $v0, 4
	la $a0, inputXValueNotifi
	syscall
	#Nhap va luu gia tri x vao s0
	li $v0, 5
	syscall
	move $s0, $v0
	#Tim x
	#gan cac du lieu t0 = n, t1 = i = 1
	lw $t0, n
	addi $t1, $0, 1
	la $a1, arr
	loopFindArr:
		#if i > N
		bgt $t1, $t0, doneFindArr
		#t2 = arr[i]
		lw $t2, 0($a1)	
		#if  arr[i] = x => Tim thay va ket thuc
		beq $t2, $s0, foundX	
		#tang don vi
		addi $a1, $a1, 4		
		addi $t1, $t1, 1		
		j loopFindArr
	foundX:
		li $v0, 4
		la $a0,xFoundNotifi 
		syscall
		li $v0, 1
		move $a0, $t1
		syscall
		jr $ra
	doneFindArr:
		li $v0, 4
		la $a0,xNotFoundNotifi 
		syscall
		jr $ra
			
# --- 6. Thoat chuong trinh ---
exit:
	li $v0, 10
	syscall
	
# --- Ham Xuat thong bao loi khi nhap ---
errorMessage:
	li $v0, 4
	la $a0, inputWarning
	syscall
	jr $ra
# --- Ham in khoang trang ---
printSpace:
	li $v0, 4
	la $a0, space
	syscall
	jr $ra
#################################################################
