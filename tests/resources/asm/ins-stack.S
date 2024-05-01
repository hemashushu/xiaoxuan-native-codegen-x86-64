;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:
    ;; read the rsp and rbp
    mov rcx, rsp
    mov rcx, rbp

    ;; push
    mov rax, 11
    push rax

    mov rax, 13
    push rax

    ;; read the rsp and rbp
    mov rcx, rsp
    mov rcx, rbp

    ;; clear rax
    mov rax, 0

    ;; pop
    pop rax
    pop rax

    ;; read the rsp and rbp
    mov rcx, rsp
    mov rcx, rbp

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
