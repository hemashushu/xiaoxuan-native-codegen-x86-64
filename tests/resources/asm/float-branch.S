;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
; count   dd  0

pi      dd  3.142
e       dd  2.718
pi_copy dd  3.142

zero_pos    dd  0x0000_0000
zero_neg    dd  0x8000_0000
nan         dd  0xffc0_0000
inf_pos     dd  0x7f80_0000
inf_neg     dd  0xff80_0000

is_inf_mask dd  0x7fff_ffff
is_inf_ref  dd  0x7f7f_ffff

section .text
global _start
_start:

    ;; for 'eq' and 'neq'
    ;; - ucomiss <reg(xmm)>, <src(xmm/mem)>
    ;; - ucomisd <reg(xmm)>, <src(xmm/mem)>
    ;;
    ;; for 'lt' 'le' 'gt' 'ge'
    ;; - comiss <reg(xmm)>, <src(xmm/mem)>
    ;; - comisd <reg(xmm)>, <src(xmm/mem)>
    ;;
    ;; je   <label>     ;; <left(op1)> == <right(op2)>
    ;; jne  <label>     ;; <left> != <right>
    ;;
    ;; jb   <label>     ;; unsigned <left> < <right>
    ;; jbe  <label>     ;; unsigned <left> <= <right>
    ;; ja   <label>     ;; unsigned <left> > <right>
    ;; jae  <label>     ;; unsigned <left> >= <right>

normal_float_comp:
    mov eax, 0    ;; reset 'count'

if_pi_equals_pi_copy:
    ;; if (pi == pi_copy) count++

    movss xmm0, dword [pi]
    movss xmm1, dword [pi_copy]

    ucomiss xmm0, xmm1
    jp if_pi_not_equals_e   ;; comparing to NaN is always false
    ucomiss xmm0, xmm1
    jne if_pi_not_equals_e
    inc eax       ;; count++

if_pi_not_equals_e:
    ;; if (pi != e) count++

    movss xmm0, dword [pi]
    movss xmm1, dword [e]

    ucomiss xmm0, xmm1
    jp if_e_less_than_pi   ;; comparing to NaN is always false
    ucomiss xmm0, xmm1
    je if_e_less_than_pi
    inc eax       ;; count++

if_e_less_than_pi:
    ;; if (e < pi) count++

    movss xmm0, dword [e]
    movss xmm1, dword [pi]

    comiss xmm0, xmm1
    jae if_pi_less_than_or_equals_pi_copy
    inc eax

if_pi_less_than_or_equals_pi_copy:
    ;; if (pi <= pi_copy) count++

    movss xmm0, dword [pi]
    movss xmm1, dword [pi_copy]

    comiss xmm0, xmm1
    ja if_pi_greater_than_e
    inc eax

if_pi_greater_than_e:
    ;; if (pi > e) count++

    movss xmm0, dword [pi]
    movss xmm1, dword [e]

    comiss xmm0, xmm1
    jbe if_pi_greater_than_or_equals_pi_copy
    inc eax

if_pi_greater_than_or_equals_pi_copy:
    ;; if (pi >= pi_copy) count++

    movss xmm0, dword [pi]
    movss xmm1, dword [pi_copy]

    comiss xmm0, xmm1
    jb special_float_comp
    inc eax

    ;; assert 'eax' == 6

special_float_comp:
    mov eax, 0    ;; reset 'count'

if_is_nan:
    movss xmm0, dword [nan]
    movss xmm1, dword [nan]
    ucomiss xmm0, xmm1
    jnp if_is_inf   ;; jnp, check the 'parity' bit of eflags reg
    inc eax

if_is_inf:
    ;; disassembly from GCC
    movss xmm0, dword [inf_pos]         ;; the number to be checked
    movss xmm1, dword [is_inf_mask]     ;; inf mask
    andps xmm0, xmm1
    ucomiss xmm0, dword [is_inf_ref]   ;; inf reference
    ;; eflags == 0x202 == [IF]
    setbe al
    ;; set 'al' to 0x1 when unsigned below and equals
    ;; al == 0x0
    xor eax, 0x1
    ;; eax == 0x1
    test al,al
    ;; check if 'al' equals 0
    ;; eflags == 0x202 == [IF]
    je exit

    inc eax
    ;; eax == 1

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall


;; about the instruction 'JP'
;; --------------------------
;;
;; > jne is jump if not equal, i.e. jump if the zero flag is not set.
;; > jp is jump if parity.
;; >
;; > ucomisd is defined to compare two doubles. It will indicate that
;; > they are one of four things: unordered, equal, greater than or less than.
;; >
;; > The zero flag is set if the numbers are unordered or equal.
;; > So the jne avoids the remaining cases of greater than or less than.
;; >
;; > Parity is set only if the result is unordered. The jp catches that.
;; >
;; > So the two together avoid: unordered, greater than, less than.
;; > Leaving only the fourth possibility, of equal.
;;
;; - JPO/JNP Jump if parity odd/Jump if not parity.
;; - JPE/JP Jump if parity even/Jump if parity.
;;
;; per:
;; - Intel 64 and IA-32 Architectures Software Developer’s Manual ->
;; - Volume 2 ->
;; - Chapter 3 Instruction Set Reference, A-L ->
;; - 3.3 Instructions (A-L) ->
;; - Jcc—Jump if Condition Is Met
;;
;; about the instructions 'ucomiss' and 'comiss'
;; ---------------------------------------------
;;
;; The UCOMISS instruction differs from the COMISS instruction in that it signals a SIMD floating-point invalid opera-
;; tion exception (#I) only if a source operand is an SNaN. The COMISS instruction signals an invalid operation excep-
;; tion when a source operand is either a QNaN or SNaN.
;;
;; per:
;; - Intel 64 and IA-32 Architectures Software Developer’s Manual ->
;; - Volume 2 ->
;; - Chapter 4 Instruction Set Reference, M-U ->
;; - 4.3 Instructions (M-U) ->
;; - UCOMISS—Unordered Compare Scalar Single Precision Floating-Point Values and Set EFLAGS

