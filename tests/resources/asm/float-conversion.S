;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd  3.14    ;; 32 bits
var_b   dd  0.0     ;; 32 bits

var_c   dq  2.718   ;; 64 bits
var_d   dq  0.0     ;; 64 bits

var_e   dd  0x11    ;; 32 bits
var_f   dq  0x13    ;; 64 bits

round_a dd  3.4
round_b dd  3.6

round_c dd  3.5
round_d dd  4.5

zerof   dd  0.0     ;; single float
zerod   dq  0.0     ;; double float

section .text
global _start
_start:

promote:
    ;; f32 -> f64
    ;; cvtss2sd <xmm>, <src(xmm/mem)>

    ;; mem to xmm
    ;;
    cvtss2sd xmm0, dword [var_a]
    ;; (gdb) p $xmm0
    ;; v2_double = {3.1400001049041748, 0}

    ;; xmm to xmm
    ;;
    movss xmm0, dword [zerof]   ;; clear
    ;; (gdb) p $xmm0
    ;; v2_double = {0, 0}
    ;;
    ;; note that although the content of xmm0 is 'double precision',
    ;; it is also cleared when the 'single precision' instruction
    ;; "movss" is used, this is a bit like the instruction "mov eax, ..."
    ;; clears 'rax'.
    ;;
    movss xmm1, dword [var_a]
    ;; (gdb) p $xmm1
    ;; v4_float = {3.1400001, 0, 0, 0}
    cvtss2sd xmm0, xmm1
    ;; (gdb) p $xmm0
    ;; v2_double = {3.1400001049041748, 0}

demote:
    ;; f64 -> f32
    ;; cvtsd2ss <xmm>, <src(xmm/mem)>

    ;; mem to xmm
    movsd xmm0, qword [zerod]   ;; clear

    ;; (gdb) p $xmm0
    ;; v4_float = {0, 0, 0, 0}
    cvtsd2ss xmm0, qword [var_c]
    ;; (gdb) p $xmm0
    ;; v4_float = {2.71799994, 0, 0, 0}

    ;; xmm to xmm
    movsd xmm0, qword [zerod]   ;; clear

    movsd xmm1, qword [var_c]
    ;; (gdb) p $xmm1
    ;; v2_double = {2.718, 0}

    ;; (gdb) p $xmm0
    ;; v4_float = {0, 0, 0, 0}
    cvtsd2ss xmm0, xmm1
    ;; (gdb) p $xmm0
    ;; v4_float = {2.71799994, 0, 0, 0}

float32_to_int_nearest:
    movss xmm0, dword [var_a]
    ;; (gdb) p $xmm0
    ;; v4_float = {3.1400001, 0, 0, 0}

    ;; float32 -> int32
    cvtss2si eax, xmm0
    ;; (gdb) p $eax
    ;; 3

    ;; float32 -> int64
    cvtss2si rcx, xmm0
    ;; (gdb) p $rcx
    ;; 3

float64_to_int_nearest:
    movsd xmm0, qword [var_c]
    ;; (gdb) p $xmm0
    ;; v2_double = {2.718, 0}

    ;; float64 -> int32
    cvtsd2si eax, xmm0
    ;; (gdb) p $eax
    ;; 3

    ;; float64 -> int64
    cvtsd2si rcx, xmm0
    ;; 3

round_to_int:
    movss xmm0, dword [round_a] ;; 3.4
    cvtss2si eax, xmm0
    ;; (gdb) p $eax
    ;; 3

    movss xmm0, dword [round_b] ;; 3.6
    cvtss2si eax, xmm0
    ;; (gdb) p $eax
    ;; 4

    movss xmm0, dword [round_c] ;; 3.5
    cvtss2si eax, xmm0
    ;; (gdb) p $xmm0
    ;; v4_float = {3.5, 0, 0, 0}
    ;; (gdb) p $eax
    ;; 4

    movss xmm0, dword [round_d] ;; 4.5
    cvtss2si eax, xmm0
    ;; (gdb) p $xmm0
    ;; v4_float = {4.5, 0, 0, 0}
    ;; (gdb) p $eax
    ;; 4

    ;; cvtss2si convert f32 to i32, it also supports converting to i64
    ;;
    ;; per:
    ;; "Intel 64 and IA-32 Architectures Software Developer’s Manual" ->
    ;; Volumn 2 ->
    ;; Chapter 3 Instruction Set Reference, A-L ->
    ;; 3.3 Instructions (A-L) ->
    ;; CVTSS2SI
    ;;
    ;; > Description
    ;; >
    ;; > Converts a single precision floating-point value in the source operand (the second operand) to a signed doubleword
    ;; > integer (or signed quadword integer if operand size is 64 bits) i

    ;; 'cvtss2si' is 'rounding to nearest (even)' by default
    ;; it depends on MXCSR register 'Rounding Control' bits
    ;;
    ;; per:
    ;; "Intel 64 and IA-32 Architectures Software Developer’s Manual" ->
    ;; Volumn 2 ->
    ;; Chapter 3 Instruction Set Reference, A-L ->
    ;; 3.3 Instructions (A-L) ->
    ;; CVTSS2SI
    ;;
    ;; > When a conversion is inexact, the value returned is rounded according to the rounding control bits in the MXCSR
    ;; > register or the embedded rounding control bits. If a converted result cannot be represented in the destination
    ;; > format, the floating-point invalid exception is raised, and if this exception is masked, the indefinite integer value
    ;; > (2w-1, where w represents the number of bits in the destination format) is returned.
    ;;
    ;; per:
    ;; "Intel 64 and IA-32 Architectures Software Developer’s Manual" ->
    ;; - Volum2 1: Basic Architecture ->
    ;; - Chapter 4 Data Types ->
    ;; - 4.8 4.8 REAL NUMBERS AND FLOATING-POINT FORMATS ->
    ;; - 4.8.4 Rounding
    ;;
    ;; ref:
    ;; https://en.wikipedia.org/wiki/Rounding#Rounding_half_to_even
    ;;
    ;;
    ;; by contrast, instruction 'cvttss2si' is 'truncate'

truncate_to_int:
    ;; todo
    ;; cvttss2si <reg>, <src(xmm/mem)>

int_to_float32:
    ;; int32 -> float32
    mov eax, dword [var_e]
    cvtsi2ss xmm0, eax
    ;; (gdb) p $eax
    ;; 17
    ;; (gdb) p $xmm0
    ;; v4_float = {17, 0, 0, 0}

    ;; int64 -> float32
    mov rcx, qword [var_f]
    cvtsi2ss xmm0, rcx
    ;; (gdb) p $rcx
    ;; 19
    ;; (gdb) p $xmm0
    ;; v4_float = {19, 0, 0, 0}

int_to_float64:
    ;; int32 -> float64
    mov eax, dword [var_e]
    cvtsi2sd xmm0, eax
    ;; (gdb) p $eax
    ;; 17
    ;; (gdb) p $xmm0
    ;; v2_double = {17, 0}

    ;; int64 -> float64
    mov rcx, qword [var_f]
    cvtsi2sd xmm0, rcx
    ;; (gdb) p $rcx
    ;; 19
    ;; (gdb) p $xmm0
    ;; v2_double = {19, 0}

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
