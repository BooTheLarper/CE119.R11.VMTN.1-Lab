# ==============================================================================
# B?NG PHÂN CÔNG THANH GHI:
#   $s0: L?u tr? t?ng ti?n ?i?n c?ng d?n (TongTien).
#   $s1: L?u tr? s? l??ng kWh ?i?n ??u vào còn l?i sau khi tính tr? d?n qua m?i b?c (x).
#   $s2: L?u ??a ch? c? s? (con tr? duy?t) c?a m?ng mang_dinh_muc.
#   $s3: L?u ??a ch? c? s? (con tr? duy?t) c?a m?ng mang_don_gia.
#   $t0: ??c và l?u giá tr? ??nh m?c kWh t?i ?a c?a b?c hi?n t?i t? b? nh?.
#   $t1: ??c và l?u giá tr? ??n giá c?a b?c hi?n t?i t? b? nh?.
#   $t2: L?u l??ng ?i?n n?ng th?c t? ???c tính ti?n trong b?c hi?n t?i (min(x, t0)).
#   $t3: Bi?n c? (flag) dùng trong l?nh so sánh ?? ki?m tra ?i?u ki?n.
#   $v0: Cài ??t mã d?ch v? (syscall code) và nh?n giá tr? x nh?p t? bàn phím.
#   $a0: L?u tr? ??a ch? các chu?i thông báo ho?c giá tr? t?ng ti?n ?? in ra màn hình.
# ==============================================================================

.data
    # Thông s? ??nh m?c các b?c (?? r?ng c?a m?i b?c)
    mang_dinh_muc: .word 50, 50, 100, 100, 100, 9599
    
    # ??n giá ?ng v?i các b?c
    mang_don_gia:  .word 1740, 1800, 2090, 2640, 2990, 3140

    # Các chu?i thông báo theo ??c t?
    msg_nhap:      .asciiz "Nhap so kWh (0..9999): "
    msg_loi:       .asciiz "Gia tri khong hop le, nhap lai.\n"
    msg_kq1:       .asciiz "Tien dien: "
    msg_kq2:       .asciiz " dong\n"

.text
.globl main

main:
# ------------------------------------------------------------------------------
# 1. NH?P VÀ KI?M TRA D? LI?U
# ------------------------------------------------------------------------------
nhap_du_lieu:
    # In l?i nh?c nh?p s? kWh
    li      $v0, 4
    la      $a0, msg_nhap
    syscall

    li      $v0, 5
    syscall
    move    $s1, $v0            # $s1 = x

    # Ki?m tra 0 <= x <= 9999:s? d?ng l?nh so sánh s? không d?u sltiu thu?n ti?n cho c? lo?i tr? các giá tr? nh?p vào < 0
    sltiu   $t3, $s1, 10000     
    bne     $t3, $zero, hop_le  

    # N?u không h?p l? ($t0 == 0)
    li      $v0, 4
    la      $a0, msg_loi
    syscall
    j       nhap_du_lieu

hop_le:
# ------------------------------------------------------------------------------
# 2. TÍNH TOÁN TI?N ?I?N (Vòng l?p duy?t qua các m?ng)
# ------------------------------------------------------------------------------
    li      $s0, 0              # TongTien = 0
    la      $s2, mang_dinh_muc  # Con tr? m?ng ??nh m?c
    la      $s3, mang_don_gia   # Con tr? m?ng ??n giá

vong_lap:
    # ?i?u ki?n d?ng: khi l??ng ?i?n còn l?i x <= 0
    blez    $s1, ket_thuc_tinh

    # ??c ??nh m?c và ??n giá c?a b?c hi?n t?i
    lw      $t0, 0($s2)         # $t0 = ??nh m?c b?c
    lw      $t1, 0($s3)         # $t1 = ??n giá b?c

    # Xác ??nh s? ?i?n tính cho b?c: D = min(x, dinh_muc)
    # N?u x < dinh_muc thì l?y x, ng??c l?i l?y dinh_muc
    slt     $t3, $s1, $t0       
    bne     $t3, $zero, lay_x
    move    $t2, $t0          
    j       tinh_tien

lay_x:
    move    $t2, $s1            # D = x

tinh_tien:
    # Ti?n b?c = D * don gia
    mul     $t1, $t2, $t1
    add     $s0, $s0, $t1       # TongTien += Tien bac

    # C?p nh?t s? ?i?n còn l?i: x = x - D
    sub     $s1, $s1, $t2

    # Ti?n con tr? ??n ph?n t? k? ti?p
    addi    $s2, $s2, 4
    addi    $s3, $s3, 4

    j       vong_lap

ket_thuc_tinh:
# ------------------------------------------------------------------------------
# 3. Xu?t k?t qu?
# ------------------------------------------------------------------------------
    # In "Tien dien: "
    li      $v0, 4
    la      $a0, msg_kq1
    syscall

    # In s? ti?n
    li      $v0, 1
    move    $a0, $s0
    syscall

    # In " dong\n"
    li      $v0, 4
    la      $a0, msg_kq2
    syscall

    # Thoát ch??ng trình
    li      $v0, 10
    syscall