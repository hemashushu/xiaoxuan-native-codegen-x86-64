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

    ;; -   Name        Symbol  Bit Use
    ;; - Y Carry       CF      0   Used to indicate if the previous operation resulted in a carry.
    ;; - n Zero        ZF      6   Used to indicate if the previous operation resulted in a zero result.
    ;; - Y Sign        SF      7   Used to indicate if the result of the previous operation resulted in a 1 in the most significant bit (indicating negative in the context of signed data).
    ;; - n Overflow    OF      11  Used to indicate if the previous operation resulted in an overflow.

    ;; greater than
    mov rax, 17
    cmp rax, 5

    ;; -   Name        Symbol
    ;; - n Carry       CF
    ;; - n Zero        ZF
    ;; - n Sign        SF
    ;; - n Overflow    OF

    ;; equals
    mov rax, 19
    cmp rax, 19

    ;; -   Name        Symbol
    ;; - n Carry       CF
    ;; - Y Zero        ZF
    ;; - n Sign        SF
    ;; - n Overflow    OF

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
