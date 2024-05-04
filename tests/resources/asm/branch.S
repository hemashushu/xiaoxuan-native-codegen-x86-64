;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:

    ;; jmp
    mov rax, 0
    jmp post_jmp

start_je:
    mov rax, 11
    cmp rax, 11
    je post_je

start_jne:
    mov rax, 13
    cmp rax, 15
    je post_jne

start_jl:
    mov rax, 17
    cmp rax, 19
    ;; cmp <op1>, <op2>
    ;; signed, jump if <op1> < <op2>
    jl post_jl

start_jle:
    mov rax, -27
    cmp rax, 23
    jle post_jle

start_jg:
    mov rax, 37
    cmp rax, 31
    ;; cmp <op1>, <op2>
    ;; signed, jump if <op1> > <op2>
    jg post_jg

start_jge:
    mov rax, 41
    cmp rax, -43
    jge post_jge

start_ja:
    ;; jump if above
    mov rax, -11
    cmp rax, 13
    ;; cmp <op1>, <op2>
    ;; unsigned, jump if <op1> > <op2>
    ja post_ja

start_jae:
    mov rax, -17
    cmp rax, -17
    jae post_jae

start_jb:
    ;; jump if below
    mov rax, 23
    cmp rax, -19
    ;; cmp <op1>, <op2>
    ;; unsigned, jump if <op1> < <op2>
    jb post_jb

start_jbe:
    mov rax, 29
    cmp rax, 29
    jbe exit

    ;; exit with code 1
    mov rax, 60     ;; SYS_exit
    mov rdi, 1      ;; exit code, EXIT_FAILURE
    syscall

post_jmp:
    jmp start_je

post_je:
    jmp start_jne

post_jne:
    jmp start_jl

post_jl:
    jmp start_jle

post_jle:
    jmp start_jg

post_jg:
    jmp start_jge

post_jge:
    jmp start_ja

post_ja:
    jmp start_jae

post_jae:
    jmp start_jb

post_jb:
    jmp start_jbe

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
