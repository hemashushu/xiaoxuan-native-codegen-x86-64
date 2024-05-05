;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:
    mov rax, 11     ;; i64
    mov eax, 13     ;; i32
    mov ax, 17      ;; i16
    mov al, 19      ;; i8
    mov ah, 2       ;; 'ah' is the high 8-bit of i16, ax = 2 * 256 + 19 = 531
    mov rcx, rax    ;; rcx <= rax

    ;; NOTE:
    ;; when the dest reg is <reg32>, the high portion of reg (bits 32 to 63) will be set to ZERO,
    ;; includes instructions 'mov', 'movzx', 'movsx'

exit:
    ;; syscall 'exit'
    ;; https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/
    ;;
    ;; syscall NR   return  arg0    arg1    arg2    arg3    arg4    arg5
    ;; rax          rax     rdi     rsi     rdx     r10     r8      r9

    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
