.data
    ROWS = 9
    COLUMNS = 9
    DIM = ROWS * COLUMNS
    ITERATIONS = 15
    matrix1: 
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 1, 0, 0, 0, 0
    .byte 0, 0, 0, 1, 1, 1, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    matrix2: .space DIM
    nextLine: .asciiz "\n"
.text
    .globl main
    .ent main

main:
    addi $sp $sp -20
    sw $ra 0($sp)
    sw $s0 4($sp)
    sw $s1 8($sp)
    sw $s2 12($sp)
    sw $s3 16($sp)

    la $a0 matrix1
    li $a1 ROWS
    li $a2 COLUMNS
    jal printMatrix

    li $s1 ITERATIONS
    li $s0 0

    la $s2 matrix1
    la $s3 matrix2

    loop:
       beq $s0 $s1 endLoop

       move $a0 $s2
       move $a1 $s3
       li $a2 ROWS
       li $a3 COLUMNS
       jal evolution

       move $a0 $s3
       li $a1 ROWS
       li $a2 COLUMNS
       jal printMatrix

       addi $s0 $s0 1
       move $t9 $s3
       move $s3 $s2
       move $s2 $t9
       j loop
       
endLoop:
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    addi $sp $sp 12
    jr $ra

.end main

.ent evolution
evolution:
    addi $sp $sp -36
    sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 16($sp)
    sw $s4 20($sp)
    sw $s5 24($sp)
    sw $s6 28($sp)
    sw $s7 32($sp)
    sw $ra 12($sp)

    li $s0 0
    li $s4 0
    move $s1 $a2
    move $s2 $a3
    move $s5 $a0
    move $s7 $a1
    #pass all the cells and set the new value in the results matrix
    loopEv:
       beq $s0 $s1 endEv
       li $s3 0
       loopEvI:
          beq $s3 $s2 endEvI
          move $a1 $s4
          move $a2 $s1
          move $a3 $s2
          move $a0 $s5
          jal countNearCells
          move $s6 $v0
          
          add $t8 $s5 $s4
          lb $t0 0($t8)
          add $t1 $s7 $s4
          beq $t0 $0 zeroCell 
          j oneCell
         next:
          addi $s3 $s3 1
          addi $s4 $s4 1
          j loopEvI
        endEvI:
            addi $s0 $s0 1
            j loopEv
    endEv:
        lw $s0 0($sp)
        lw $s1 4($sp)
        lw $s2 8($sp)
        lw $s3 16($sp)
        lw $s4 20($sp)
        lw $s5 24($sp)
        lw $s6 28($sp)
        lw $s7 32($sp)
        lw $ra 12($sp)
        addi $sp $sp 36
        jr $ra

zeroCell:
   bne $s6 3 repl
   li $t2 1
   sb $t2 0($t1)
   j next

oneCell:
  beq $s6 2 repl
  beq $s6 3 repl
  li $t2 0
  sb $t2 0($t1)
  j next

repl:
  sb $t0 0($t1)
  j next
    
.end evolution


#sum of the cells that are in the square at distance 1 from the cell that we are considering
.ent countNearCells
countNearCells:
  move $t0 $a0#matrix
  move $t1 $a1#cell
  move $t2 $a2#number of rows
  move $t3 $a3#number of columns

  divu $t4 $t1 $t3 #index of the row of the cell
  mul $t5 $t4 $t2
  subu $t5 $t1 $t5 #index of the colum of the cell
  
  upperRow:
    move $t6 $t4 #index upper row
    beq $t4 $0 bottomRow
    addi $t6 $t6 -1
  bottomRow:
    move $t7 $t4 #index bottom row
    addi $t2 $t2 -1
    beq $t4 $t2 leftColumn
    addiu $t7 $t7 1
  leftColumn:
    addiu $t2 $t2 1
    move $t8 $t5  #index left column
    beq $t8 $0 rightColumn
    addi $t8 $t8 -1
  rightColumn:
    move $t9 $t5 #index right column
    addi $t3 $t3 -1
    beq $t5 $t3 sum 
    addiu $t9 $t9 1

sum:
  addi $t3 $t3 1
  mul $t5 $t6 $t3
  addu $t5 $t5 $t8 
  addu $t5 $t0 $t5 #address of cell upper row left
  mul $t4 $t6 $t3
  addu $t4 $t4 $t9
  addu $t4 $t0 $t4 #address of the cell in upper right 
  mul $t9 $t7 $t3
  addu $t9 $t9 $t8
  addu $t9 $t0 $t9 #address of the bottom left cell

  addu $t1 $t1 $t0 
  lbu $t1 0($t1)

  #remove to the sum the cell passed
  sub $t8 $0 $t1

  #sum of the cell in the square identified before
  loopSumE:
    bgt $t5 $t9 endSum
    move $t7 $t5
    loopSumI:
      bgt $t7 $t4 endSumE
      lbu $t6 0($t7)
      add $t8 $t8 $t6
      addu $t7 $t7 1
      j loopSumI
  endSumE:
    addu $t5 $t5 $t3
    addu $t4 $t4 $t3
    j loopSumE

endSum:
  move $v0 $t8
  jr $ra
.end countNearCells


.ent printMatrix
printMatrix:
    move $t2 $a0
    la $a0 nextLine
    li $v0 4
    syscall
    li $t0 0
    loopEP:
        beq $t0 $a1 endPrintMatrix
        li $t1 0
        loopIP:
            beq $t1 $a2 endLoopEP
            lb $t3 0($t2)
            move $a0 $t3
            li $v0 1
            syscall
            addi $t1 $t1 1
            addi $t2 $t2 1
            j loopIP

    endLoopEP:
        la $a0 nextLine
        li $v0 4
        syscall
        addi $t0 $t0 1
        j loopEP
endPrintMatrix:
    jr $ra

.end printMatrix