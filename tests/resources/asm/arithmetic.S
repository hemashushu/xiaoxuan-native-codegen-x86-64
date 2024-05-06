;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dq      0x1180001122
var_b   dq      0x2290003344
var_c   dq      0

section .text
global _start
_start:
    ;; addition
    ;; 'add <dest>, <src>'
    ;; <dest> = <dest> + <src>
    mov rax, 11
    mov rcx, 13
    add rax, rcx
    ;; CHECK: rax == 24

    mov rax, 11
    add rax, 13
    ;; CHECK:: rax == 24

    ;; inc
    ;; 'inc <operand>'
    ;; <operand> = <operand> + 1
    mov rax, 11
    inc rax
    ;; CHECK:: rax == 12

do_adc:
    ;; addition with carry
    ;; 'adc <dest>, <src>
    ;; <dest> = <dest> + <src> + <carry bit>
    mov eax, dword [var_a]      ;; low a 0x80001122
    mov ecx, dword [var_a + 4]  ;; high a

    add eax, dword [var_b]      ;; low b 0x90003344
    adc ecx, dword [var_b + 4]  ;; high b

    mov dword [var_c], eax
    mov dword [var_c + 4], ecx
    ;; CHECK: var_c == 0x34_1000_4466

do_sub:
    ;; subtraction
    ;; 'sub <dest>, <src>
    ;; <dest> = <dest> - <src>
    mov rax, 19
    mov rcx, 11
    sub rax, rcx
    ;; CHECK: rax == 8

    mov rax, 19
    sub rax, 11
    ;; CHECK: rax == 8

    ;; dec
    ;; 'dec <operand>'
    ;; <operand> = <operand> - 1
    mov rax, 19
    dec rax
    ;; CHECK: rax == 18

do_mul:
    ;; multiplication

    ;; unsigned multiplication
    ;; mul <src(reg/mem)>
    ;;
    ;; al x op8 = ah al
    ;; ax x op16 = dx ax
    ;; eax x op32 = edx eax
    ;; rax x op64 = rdx rax

    mov eax, 4999   ;; note that 'mov ax,...' does not clear the high portion of reg, therefor use 'mov eax, ...' instead
    mov ecx, 5003   ;; note that 'mov ax,...' does not clear the high portion of reg, therefor use 'mov eax, ...' instead
    mul cx
    ;; CHECK: ax == low part == 40781 (0x9f4d)
    ;; CHECK: dx == high part == 381 (0x017d)

    mov eax, 0x2
    mov ecx, 0xfffffffe
    mul ecx
    ;; CHECK: eax = 0xfffffffc
    ;; CHECK: edx = 0x1

    mov rax, 0x2
    mov rcx, 0xfffffffe
    mul rcx
    ;; CHECK: rax = 0x1_fffffffc
    ;; CHECK: rdx = 0

do_imul:
    ;; signed multiplication
    ;; 'imul <src(reg/mem)>'
    ;;
    ;; 'imul <dest>, <src(reg/mem/imm)>'
    ;; <dest> = <dest> * <src>
    ;;
    ;; 'imul <dest>, <src(reg/mem)>, <imm>'
    ;; <dest> = <src> * <imm>
    ;;
    ;; NOTE byte operands are not supported!

    mov eax, 4999    ;; note that 'mov ax,...' does not clear the high portion of reg, therefor use 'mov eax, ...' instead
    mov ecx, 5003    ;; note that 'mov ax,...' does not clear the high portion of reg, therefor use 'mov eax, ...' instead
    imul cx
    ;; CHECK: ax == low part == 40781 (0x9f4d)
    ;; CHECK: dx == high part == 381 (0x017d)

    mov eax, 0x2
    mov ecx, 0xfffffffe ;; -2
    imul ecx
    ;; CHECK: eax = 0xFFFFFFFC  ;; -4
    ;; CHECK: edx = 0xFFFFFFFF

    mov rax, 0x2
    mov rcx, 0xfffffffe ;; NOT -2
    imul rcx
    ;; CHECK: rax = 0x1FFFFFFFC
    ;; CHECK: rdx = 0

do_div:
    ;; division
    ;;
    ;; 'div <src>'
    ;; 'idiv <src>'
    ;;
    ;; ah al / op8 => al, rem => ah
    ;; dx ax / op16 => ax, rem => dx
    ;; edx eax / op32 => eax, rem => edx
    ;; rdx rax / op64 => rax, rem => rdx

    mov edx, 0      ;; clear the high part of dividend
    mov eax, 113
    mov ecx, 11
    div ecx
    ;; CHECK: rax == quotient == 10
    ;; CHECK: rdx == remainder == 3

    mov edx, 0
    mov eax, 0xf0000001
    mov ecx, 0x2
    div ecx
    ;; CHECK: rax == 0x7800_0000
    ;; CHECK: rdx = 0x1

do_idiv:
    mov edx, 0      ;; clear the high part of dividend
    mov eax, 113
    mov ecx, 11
    idiv ecx
    ;; CHECK: rax == quotient == 10
    ;; CHECK: rdx == remainder == 3

    mov edx, 0xffffffff
    mov eax, 0xf0000001 ;; -268435455
    mov ecx, 0x2
    idiv ecx
    ;; CHECK: rax == 0xf8000001 ;; -134217727
    ;; CHECK: rdx = 0xffffffff

do_cdq:
    mov eax, 113
    cdq
    ;; CHECK: edx == 0
    mov ecx, 11
    idiv ecx
    ;; CHECK: rax == quotient == 10
    ;; CHECK: rdx == remainder == 3

    ;; the 'cdq' instruction
    ;; 'cdq'
    ;; eax -> signed-extension -> edx:eax
    ;; then 'idiv'
    mov eax, 0x80000001
    cdq
    ;; CHECK: edx == 0xffffffff
    mov ecx, 2
    idiv ecx
    ;; CHECK: rax == quotient == 0xc0000001
    ;; CHECK: rdx == remainder == 0xffffffff

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
