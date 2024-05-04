;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   db  11
var_b   dw  13
var_c   dd  17
var_d   dq  19

section .text
global _start
_start:
    mov rax, var_a
    mov al, byte [var_a]    ;; the high part will keep unchanged
    lea rax, [var_a]

    mov rax, var_b
    mov ax, word [var_b]    ;; the high part will keep unchanged
    lea rax, [var_b]

    mov rax, var_c
    mov eax, dword [var_c]
    lea rax, [var_c]

    mov rax, var_d
    mov rax, qword [var_d]
    lea rax, [var_d]

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
