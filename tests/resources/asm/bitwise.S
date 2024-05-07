;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd  0xaa55f0f0
var_b   dd  0x55aa0f0f
var_c   dd  0

section .text
global _start
_start:

do_and:
    ;; 'and <dest>, <src>'
    ;; <dest> = <dest> and <src>
    mov eax, 0xf0f0aa55
    mov ecx, 0x0f0f55aa
    and ax, cx              ;; the high portion beyonds i16 will keep unchanged
    ;; ax == 0xf0f0_0000

    mov eax, 0xf0f0aa55
    mov ecx, 0x0f0f55aa
    and eax, ecx
    ;; eax == 0x0000_0000

    mov eax, 0xf0f0aa55
    mov ecx, 0xaa55f0f0
    and eax, ecx
    ;; eax == 0xa050_a050

    mov eax, 0xf0f0aa55
    and eax, dword [var_a]  ;; 0xf0f0aa55 & 0xaa55f0f0 = 0xa050a050
    ;; eax == 0xa050_a050

    mov dword [var_c], 0xaa55f0f0
    mov eax, 0xf0f0aa55
    and dword [var_c], eax
    ;; var_c == 0xa050_a050

do_or:
    ;; 'or <dest>, <src>'
    ;; <dest> = <dest> or <src>

    mov eax, 0xf0f0aa55
    mov ecx, 0x0f0f55aa
    or eax, ecx
    ;; eax == 0xffff_ffff

    mov eax, 0xf0f0aa55
    mov ecx, 0xaa55f0f0
    or eax, ecx
    ;; eax == 0xfaf5_faf5

do_xor:
    ;; 'xor <dest>, <src>'
    mov eax, 0xf0f0aa55
    mov ecx, 0x0f0f55aa
    xor eax, ecx
    ;; eax == 0xffff_ffff

    mov eax, 0xf0f0aa55
    mov ecx, 0xaa55f0f0
    xor eax, ecx
    ;; eax == 0x5aa5_5aa5

do_not:
    ;; 'not <op>'
    mov eax, 0xf0f0aa55
    not eax
    ;; eax == 0x0f0f_55aa

do_shift_left_logical:
    ;; 'shl <dest>, <imm>'
    ;; 'shl <dest>, cl'
    ;; both imm and cl must be between 1 and 64
    mov eax, 0x80038001
    shl eax, 3
    ;; eax == 0x1c_0008

    mov cl, 5
    shl eax, cl
    ;; eax == 0x380_0100

    ;; note that the instruction 'sal' (Shift left arithmetic) is the
    ;; same as 'shl'

do_shift_right_logical:
    ;; 'shr <dest>, <imm>'
    ;; 'shr <dest>, cl'
    ;; both imm and cl must be between 1 and 64
    mov eax, 0x80038001
    shr eax, 3
    ;; eax == 0x10007000

    mov cl, 5
    shr eax, cl
    ;; eax == 0x80_0380

do_shift_right_arithmetic:
    ;; 'sar <dest>, <imm>'
    ;; 'sar <dest>, cl'
    ;; both imm and cl must be between 1 and 64
    mov eax, 0x80038001
    sar eax, 3
    ;; eax == 0xf000_7000

    mov cl, 5
    sar eax, cl ;; todo
    ;; eax == 0xff80_0380

do_rotate_left:
    ;; 'rol <dest>, <imm>'
    ;; 'rol <dest>, cl'
    ;; both imm and cl must be between 1 and 64
    mov eax, 0x80038001
    rol eax, 1
    ;; eax == 0x7_0003

    mov cl, 3
    rol eax, cl
    ;; eax == 0x38_0018

do_rotate_right:
    ;; 'ror <dest>, <imm>'
    ;; 'ror <dest>, cl'
    ;; both imm and cl must be between 1 and 64
    mov eax, 0x80038001
    ror eax, 1
    ;; eax == 0xc001_c000

    mov cl, 3
    ror eax, cl
    ;; eax == 0x1800_3800

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
