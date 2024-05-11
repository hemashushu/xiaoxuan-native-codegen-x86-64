;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd      3.14    ;; 32 bits
var_b   dd      0.0     ;; 32 bits
var_c   dq      2.718   ;; 64 bits
var_d   dq      0.0     ;; 64 bits

section .text
global _start
_start:

move_between_memory_reg:

    ;; floatint point mov
    ;;
    ;; 'movss    <dest(xmm/mem)>, <src(xmm/mem)>'
    ;; copy 32-bits operand to 32-bits dest operand
    ;;
    ;; 'movsd    <dest(xmm/mem)>, <src(xmm/mem)>'
    ;; copy 64-bits operand to 64-bits dest operand
    ;;
    ;; <dest> and <src> can be xmm registers or memory, but
    ;; can not be general register such as rax, rcx.
    ;;
    ;; note that floating point 'mov' does not support imm.

    ;; check the preset DATA
    ;; ---------------------
    ;; (gdb) x/wf &var_a
    ;; 0x402000:       3.1400001
    ;; (gdb) x/gf &var_c
    ;; 0x402008:       2.718

    ;; (gdb) p $xmm0
    ;; v4_float = {0, 0, 0, 0}
    movss xmm0, dword [var_a]
    ;; (gdb) p $xmm0
    ;; v4_float = {3.1400001, 0, 0, 0}

    ;; (gdb) x/wf &var_b
    ;; 0x402004:       0
    movss dword [var_b], xmm0
    ;; check var_b
    ;; (gdb) x/wf &var_b
    ;; 0x402004:       0

    ;; (gdb) p $xmm1
    ;; v2_double = {0, 0}
    movsd xmm1, qword [var_c]
    ;; (gdb) p $xmm1
    ;; v2_double = {2.718, 0}

    ;; (gdb) x/gf &var_d
    ;; 0x402010:       0
    movsd qword [var_d], xmm1
    ;; check var_d
    ;; (gdb) x/gf &var_d
    ;; 0x402010:       2.718

move_between_regs:
    ;; (gdb) p $xmm2
    ;; v4_float = {0, 0, 0, 0}
    movss xmm2, xmm0
    ;; check xmm2
    ;; (gdb) p $xmm2
    ;; v4_float = {3.1400001, 0, 0, 0}

    ;; (gdb) p $xmm3
    ;; v2_double = {0, 0}
    movsd xmm3, xmm1
    ;; check xmm3
    ;; (gdb) p $xmm3
    ;; v2_double = {2.718, 0}

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall

; about the xmm registers as arguments:
;
; arguments
; NO. 64-bits 32-bits     float
; 1   rdi     edi         xmm0
; 2   rsi     esi         xmm1
; 3   rdx     edx         xmm2
; 4   rcx     ecx         xmm3
; 5   r8      r8d         xmm2
; 6   r9      r9d         xmm3
;                         xmm6
;                         xmm7
;
; return
; NO. 64-bits 32-bits     float
; 1   rax     eax         xmm0
;
; usage
; rax         return value    \
; rcx         4th arg         |
; rdx         3rd arg         |
; rsi         2nd arg         | feel free to use it
; rdi         1st arg         | before making a single call
; r8          5th arg         |
; r9          6th arg         |
; r10         temporary       |
; r11         temporary       |
; xmm0..xmm15 temporary       /
;
; rbx         callee saved    \
; rbp         callee saved    |
; r12         callee saved    | it needs to be restored before return
; r13         callee saved    | if it is used
; r14         callee saved    |
; r15         callee saved    /