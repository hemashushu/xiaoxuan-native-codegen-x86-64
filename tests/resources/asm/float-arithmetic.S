;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd  3.142
var_b   dd  2.718

var_c   dq  6.626
var_d   dq  2.998

var_e   dd  2.0
var_f   dq  3.0

section .text
global _start
_start:

    ;; addition
    ;; addss <dest(xmm)>, <src(xmm/mem)>
    ;; addsd <dest(xmm)>, <src(xmm/mem)>
    ;;
    ;; subtraction
    ;; subss <dest(xmm)>, <src(xmm/mem)>
    ;; subsd <dest(xmm)>, <src(xmm/mem)>
    ;;
    ;; multiplication
    ;; mulss <dest(xmm)>, <src(xmm/mem)>
    ;; mulsd <dest(xmm)>, <src(xmm/mem)>
    ;;
    ;; division
    ;; divss <dest(xmm)>, <src(xmm/mem)>
    ;; divsd <dest(xmm)>, <src(xmm/mem)>
    ;;
    ;; math/square root
    ;; sqrtss <dest(xmm)>, <src(xmm/mem)>
    ;; sqrtsd <dest(xmm)>, <src(xmm/mem)>

addition:
    movss xmm0, dword [var_a]
    addss xmm0, dword [var_b]
    ;; v4_float = {5.85999966, 0, 0, 0}

    movsd xmm0, qword [var_c]
    addsd xmm0, qword [var_d]
    ;; v2_double = {9.6240000000000006, 0}

subtraction:
    movss xmm0, dword [var_a]
    subss xmm0, dword [var_b]
    ;; v4_float = {0.424000025, 0, 0, 0}

    movsd xmm0, qword [var_c]
    subsd xmm0, qword [var_d]
    ;; v2_double = {3.6280000000000001, 0}

multiplication:
    movss xmm0, dword [var_a]
    mulss xmm0, dword [var_b]
    ;; v4_float = {8.53995609, 0, 0, 0}

    movsd xmm0, qword [var_c]
    mulsd xmm0, qword [var_d]
    ;; v2_double = {19.864748000000002, 0}

division:
    movss xmm0, dword [var_a]
    divss xmm0, dword [var_b]
    ;; v4_float = {1.15599704, 0, 0, 0}

    movsd xmm0, qword [var_c]
    divsd xmm0, qword [var_d]
    ;; v2_double = {2.210140093395597, 0}

math_square_root:
    sqrtss xmm0, dword [var_e]
    ;; v4_float = {1.41421354, 2.02626729, 0, 0}

    sqrtsd xmm0, qword [var_f]
    ;; v2_double = {1.7320508075688772, 0}

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
