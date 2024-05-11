;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text
global _start
_start:

compare_i64:
    ;; comparison

    ;; the 'eflags' register:
    ;;
    ;;   Bit Name    Symbol  Bit  Use
    ;; - Carry       CF      0    Used to indicate if the previous operation resulted in a carry.
    ;; - Zero        ZF      6    Used to indicate if the previous operation resulted in a zero result.
    ;; - Sign        SF      7    Used to indicate if the result of the previous operation resulted in a 1 in the most significant bit (indicating negative in the context of signed data).
    ;; - Overflow    OF      11   Used to indicate if the previous operation resulted in an overflow.

    ;; less than
    mov rax, 11
    mov rcx, 13
    cmp rax, rcx    ;; 'cmp <op-left> <op-right>'
    ;; eflags == (CF, SF)

    ;; greater than
    mov rax, 17
    cmp rax, 5
    ;; eflags == ()

    ;; equals
    mov rax, 19
    cmp rax, 19
    ;; eflags == (ZF)

compare_i32_i16_i8:
    ;; compare i32, i16 and i8
    mov rax, 0x80000000ffee11aa
    mov rcx, 0x90000000887766aa

    cmp rax, rcx    ;; lt
    ;; eflags == (CF, SF)

    cmp eax, ecx    ;; gt
    ;; eflags == ()

    cmp ax, cx      ;; lt
    ;; eflags == (CF, SF)

    cmp al, cl      ;; eq
    ;; eflags == (ZF)

start_branch:
    ;; unconditional jump
    ;; 'jmp <label>'
    jmp post_jmp

    ;; conditional jump
    ;; je      <label>     ; if <op1> == <op2>
    ;; jne     <label>     ; if <op1> != <op2>
    ;; jl      <label>     ; signed, if <op1> < <op2>
    ;; jle     <label>     ; signed, if <op1> <= <op2>
    ;; jg      <label>     ; signed, if <op1> > <op2>
    ;; jge     <label>     ; signed; if <op1> >= <op2>
    ;; jb      <label>     ; unsigned, if <op1> < <op2>
    ;; jbe     <label>     ; unsigned, if <op1> <= <op2>
    ;; ja      <label>     ; unsigned, if <op1> > <op2>
    ;; jae     <label>     ; unsigned, if <op1> >= <op2>

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
