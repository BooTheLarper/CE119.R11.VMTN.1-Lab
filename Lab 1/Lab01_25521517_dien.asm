# ==============================================================================
# BANG PHAN CONG THANH GHI:
#   $s0: Luu tru tong tien dien cong don (TongTien).
#   $s1: Luu tru so luong kWh dien dau vao con lai sau khi tinh tru dan qua moi bac (x).
#   $s2: Luu dia chi co so (con tro duyet) cua mang mang_dinh_muc.
#   $s3: Luu dia chi co so (con tro duyet) cua mang mang_don_gia.
#   $t0: Doc va luu gia tri dinh muc kWh toi da cua bac hien tai tu bo nho.
#   $t1: Doc va luu gia tri don gia cua bac hien tai tu bo nho.
#   $t2: Luu luong dien nang thuc te duoc tinh tien trong bac hien tai (min(x, t0)).
#   $t3: Bien co (flag) dung trong lenh so sanh de kiem tra dieu kien.
#   $v0: Cai dat ma dich vu (syscall code) va nhan gia tri x nhap tu ban phim.
#   $a0: Luu tru dia chi cac chuoi thong bao hoac gia tri tong tien de in ra man hinh.
# ==============================================================================

.data
    # Thong so dinh muc do rong cac bac (Bac 6: 9999 - 400 = 9599)
    mang_dinh_muc: .word 50, 50, 100, 100, 100, 9599
    
    # Don gia 6 bac voi tham so a = 7
    mang_don_gia:  .word 1740, 1800, 2090, 2640, 2990, 3140

    # Cac chuoi thong bao theo dung dac ta
    msg_nhap:      .asciiz "Nhap so kWh (0..9999): "
    msg_loi:       .asciiz "Gia tri khong hop le, nhap lai.\n"
    msg_kq1:       .asciiz "Tien dien: "
    msg_kq2:       .asciiz " dong\n"

.text
.globl main

main:
# ------------------------------------------------------------------------------
# 1. NHAP VA KIEM TRA DU LIEU 
# ------------------------------------------------------------------------------
nhap_du_lieu:
    # In loi nhac nhap so kWh
    li      $v0, 4
    la      $a0, msg_nhap
    syscall

    # Doc so nguyen co dau
    li      $v0, 5
    syscall
    move    $s1, $v0            # $s1 = x

    # Kiem tra 0 <= x <= 9999 
    sltiu   $t3, $s1, 10000    
    bne     $t3, $zero, hop_le  

    # Neu khong hop le
    li      $v0, 4
    la      $a0, msg_loi
    syscall
    j       nhap_du_lieu

hop_le:
# ------------------------------------------------------------------------------
# 2. TINH TOAN TIEN DIEN 
# ------------------------------------------------------------------------------
    li      $s0, 0              # TongTien = 0
    la      $s2, mang_dinh_muc  # Con tro duyet mang dinh muc
    la      $s3, mang_don_gia   # Con tro duyet mang don gia

vong_lap:
    # Dieu kien dung: khi luong dien con lai x <= 0
    blez    $s1, ket_thuc_tinh

    # Doc dinh muc ($t0) va don gia ($t1) cua bac hien tai
    lw      $t0, 0($s2)         
    lw      $t1, 0($s3)        

    # Xac dinh luong dien tinh cho bac: min(x, dinh_muc) luu vao $t2
    slt     $t3, $s1, $t0       
    bne     $t3, $zero, lay_x
    move    $t2, $t0            # $t2 = dinh muc
    j       tinh_tien

lay_x:
    move    $t2, $s1            # $t2 = x

tinh_tien:
    # Tien bac = $t2 * $t1 
    mul     $t1, $t2, $t1
    add     $s0, $s0, $t1       # TongTien += Tien bac ($t1)

    # Cap nhat so dien con lai: x = x - $t2
    sub     $s1, $s1, $t2

    # Tinh tien con tro toi phan tu ke tiep (4 bytes / word)
    addi    $s2, $s2, 4
    addi    $s3, $s3, 4

    j       vong_lap

ket_thuc_tinh:
# ------------------------------------------------------------------------------
# 3. XUAT KET QUA VA KET THUC
# ------------------------------------------------------------------------------
    # In "Tien dien: "
    li      $v0, 4
    la      $a0, msg_kq1
    syscall

    # In gia tri tong tien
    li      $v0, 1
    move    $a0, $s0
    syscall

    # In " dong\n"
    li      $v0, 4
    la      $a0, msg_kq2
    syscall

    # Thoat chuong trinh
    li      $v0, 10
    syscall