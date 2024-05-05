;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:
    ;; comparison

    ;; the 'eflags' register:
    ;;
    ;;   Bit Name    Symbol  Bit  Use
    ;; - Carry       CF      0    Used to indicate if the previous operation resulted in a carry.
    ;; - Zero        ZF      6    Used to indicate if the previous operation resulted in a zero result.
    ;; - Sign        SF      7    Used to indicate if the result of the previous operation resulted in a 1 in the most significant bit (indicating negative in the context of signed data).
    ;; - Overflow    OF      11   Used to indicate if the previous operation resulted in an overflow.

    ;; less than -> (CF, SF)
    mov rax, 11
    mov rcx, 13
    cmp rax, rcx    ;; 'cmp <op-left> <op-right>'

    ;; greater than -> ()
    mov rax, 17
    cmp rax, 5

    ;; equals -> (ZF)
    mov rax, 19
    cmp rax, 19

    ;; compare i32, i16 and i8
    mov rax, 0x80000000ffee11aa
    mov rcx, 0x90000000887766aa

    cmp rax, rcx    ;; lt, (CF, SF)
    cmp eax, ecx    ;; gt, ()
    cmp ax, cx      ;; lt, (CF, SF)
    cmp al, cl      ;; eq, (ZF)

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
