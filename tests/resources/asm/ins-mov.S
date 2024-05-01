;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd  31      ;; dd = double word = 2 * 16 = 32bits
var_b   dd  37
var_c   dd  0

section .text
global _start
_start:
    mov rax, 11     ;; i64
    mov eax, 13     ;; i32
    mov ax, 17      ;; i16
    mov al, 19      ;; i8
    mov ah, 2       ;; 'ah' is the high 8-bit of i16, ax = 2 * 256 + 19 = 531
    mov rcx, rax    ;; rcx <= rax

    ;; accessing memory
    mov eax, [var_a]        ;; eax = 0x1f
    mov ecx, [var_a + 4]    ;; ecx = 0x25
    mov [var_c], ecx        ;; [var_c] = 0x0000_0025

exit:
    ;; syscall 'exit'
    ;; https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/
    ;;
    ;; syscall NR   return  arg0    arg1    arg2    arg3    arg4    arg5
    ;; rax          rax     rdi     rsi     rdx     r10     r8      r9

    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
