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
    mov ah, 19      ;; 'ah' is the high 8-bit of i16
    mov al, 23      ;; i8
    mov rcx, rax

exit:
    ;; syscall 'exit'
    ;; https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/
    ;;
    ;; syscall NR   return  arg0    arg1    arg2    arg3    arg4    arg5
    ;; rax          rax     rdi     rsi     rdx     r10     r8      r9

    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
