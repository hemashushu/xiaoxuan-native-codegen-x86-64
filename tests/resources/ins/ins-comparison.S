;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:
    ;; comparison

    ;; less than
    mov rax, 11
    mov rcx, 13
    cmp rax, rcx

    ;; greater than
    mov rax, 17
    cmp rax, 5

    ;; equals
    mov rax, 19
    cmp rax, 19

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
