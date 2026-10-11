# ==============================================================================
# THONG SO CA NHAN:
# MSSV: 25521517 -> a = 7, b = 1
# - Do lech cao do: a = 7
# - Do dai 1 nhip: 150 + 10*1 = 160 ms
# - Nhac cu: b % 4 = 1 % 4 = 1 -> So hieu 24
# ==============================================================================

.data
    # Mang cao do goc cua 15 not (chua cong a)
    mang_cao_do: .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
    
    # Mang do dai (tinh theo don vi nhip)
    mang_do_dai: .word 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1, 4
    
    # So luong not nhac
    so_not:      .word 15
    
    # Chuoi thong bao
    str_space:   .asciiz " "
    str_nl:      .asciiz "\n"
    msg_du_kien: .asciiz "Tong du kien (ms): "
    msg_do_duoc: .asciiz "Thoi gian do duoc (ms): "

.text
.globl main

main:
    # ---------------------------------------------------------
    # Bat dau do thoi gian (syscall 30)
    # ---------------------------------------------------------
    li      $v0, 30
    syscall
    move    $s6, $a0            # $s6 = Thoi gian bat dau 

    # ---------------------------------------------------------
    # Khoi tao vong lap phat nhac
    # ---------------------------------------------------------
    la      $s0, mang_cao_do    # $s0 = Con tro mang cao do
    la      $s1, mang_do_dai    # $s1 = Con tro mang do dai
    lw      $s2, so_not         # $s2 = Bo dem so not (15)
    li      $s3, 0              # $s3 = Tong thoi gian du kien (ms)

vong_lap_nhac:
    blez    $s2, ket_thuc_nhac

    # Doc cao do va tinh toan (Cao do thuc = Cao do goc + 7)
    lw      $t0, 0($s0)
    addi    $t0, $t0, 7         # $t0 = cao do thuc phat
    
    # Doc do dai va tinh toan (ms = Do dai * 160)
    lw      $t1, 0($s1)
    mul     $t1, $t1, 160       # $t1 = thoi luong ms
    
    # Cong don vao tong thoi gian du kien
    add     $s3, $s3, $t1

    # In thong so not: "<cao do> "
    li      $v0, 1
    move    $a0, $t0
    syscall
    
    li      $v0, 4
    la      $a0, str_space
    syscall
    
    # In thong so not: "<ms>\n"
    li      $v0, 1
    move    $a0, $t1
    syscall
    
    li      $v0, 4
    la      $a0, str_nl
    syscall

    # =========================================================
    # Phat nhac theo cau hinh
    # =========================================================
    
    # 1. Phat nhac (syscall 31 hoac 33)
    move    $a0, $t0            # pitch (cao do)
    move    $a1, $t1            # duration (do dai ms)
    li      $a2, 24             # instrument (nhac cu)
    li      $a3, 100            # volume (am luong)
    li      $v0, 31             # Dung 31 hoac 33 (31 thi ket hop them 32, 33 thi khong can)
    syscall

    # 2. Ngu (sleep) bang dung thoi gian ngan not (syscall 32 khi ket hop voi syscall 31)
    move    $a0, $t1            # $a0 = thoi gian ngu (lay tu $t1)
    li      $v0, 32             # syscall 32: Sleep
    syscall

    # =========================================================

    # Tinh tien con tro va giam bo dem
    addi    $s0, $s0, 4
    addi    $s1, $s1, 4
    addi    $s2, $s2, -1
    j       vong_lap_nhac

ket_thuc_nhac:
    # ---------------------------------------------------------
    # Ket thuc do thoi gian va tinh toan (syscall 30)
    # ---------------------------------------------------------
    li      $v0, 30
    syscall
    sub     $s7, $a0, $s6       # $s7 = Thoi gian thuc te do duoc (Ket thuc - Bat dau)

    # ---------------------------------------------------------
    # In ket qua tong hop
    # ---------------------------------------------------------
    # In "Tong du kien (ms): <so>"
    li      $v0, 4
    la      $a0, msg_du_kien
    syscall
    li      $v0, 1
    move    $a0, $s3
    syscall
    li      $v0, 4
    la      $a0, str_nl
    syscall

    # In "Thoi gian do duoc (ms): <so>"
    li      $v0, 4
    la      $a0, msg_do_duoc
    syscall
    li      $v0, 1
    move    $a0, $s7
    syscall
    li      $v0, 4
    la      $a0, str_nl
    syscall

    # Thoat chuong trinh
    li      $v0, 10
    syscall