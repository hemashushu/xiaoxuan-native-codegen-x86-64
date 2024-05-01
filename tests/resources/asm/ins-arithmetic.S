;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:
    ;; add
    mov rax, 11
    mov rcx, 13
    add rax, rcx

    mov rax, 11
    add rax, 13

    ;; subtract
    mov rax, 19
    mov rcx, 11
    sub rax, rcx

    mov rax, 19
    sub rax, 11

    ;; multiple
    mov ax, 4999
    mov cx, 5003
    mul cx          ;; 'ax' = low part = 40781 (0x9f4d), 'dx' = high part = 381 (0x017d)

    mov rax, 11
    mov rcx, 13
    mul rcx         ;; 'ax' = 143 (0x8f), 'dx' = 0

    ;; divid
    ;;
    ;; ah al / op8 => al, rem => ah
    ;; dx ax / op16 => ax, rem => dx
    ;; edx eax / op32 => eax, rem => edx
    ;; rdx rax / op64 => rax, rem => rdx

    mov rax, 113
    mov rcx, 11
    mov rdx, 0      ;; clear the high part of dividend
    div rcx         ;; 'rax' = quotient = 10, 'dx' = remainder = 3

    mov rax, 143
    mov rcx, 13
    mov rdx, 0      ;; clear the high part of dividend
    div rcx         ;; 'rax' = 11, 'rdx' = 0

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
