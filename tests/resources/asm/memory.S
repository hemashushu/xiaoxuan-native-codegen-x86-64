;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   db  11      ;; i8
var_b   dw  13      ;; i16
var_c   dd  17      ;; i32
var_d   dq  19      ;; i64

section .bss
var_e   resq    1   ;; 1 qword data

section .text
global _start
_start:
    ;; load i8
    lea rax, [var_a]
    mov rax, 0xffeeddcc99887766

    mov al, byte [var_a]    ;; load i8, the high portion beyonds i8 will keep unchanged
    mov rax, 0              ;; set to '0' first
    mov al, byte [var_a]    ;; load i8

    ;; load i16
    lea rax, [var_b]
    mov rax, 0xffeeddcc99887766

    mov ax, word [var_b]    ;; load i16, the high portion beyonds i16 will keep unchanged
    mov rax, 0              ;; set to '0' first
    mov ax, word [var_b]    ;; load i16

    ;; load i32
    lea rax, [var_c]
    mov rax, 0xffeeddcc99887766
    mov eax, dword [var_c]

    ;; NOTE:
    ;; when the dest reg is <reg32>, the high portion of reg (bits 32 to 63) will be set to ZERO,
    ;; includes instructions 'mov', 'movzx', 'movsx'

    ;; load i64
    lea rax, [var_d]
    mov rax, qword [var_d]

store:
    mov dword [var_e], 0x99887766   ;; write the low portion
    mov dword [var_e+4], 0xffeeddcc ;; write the high portion
    mov byte [var_e], 0x81          ;; rewrite the low portion, the high portion should keep unchanged
    mov word [var_e], 0x8001        ;; rewrite the low portion, the high portion should keep unchanged
    mov dword [var_e], 0x80000001   ;; rewrite the low portion, the high portion should keep unchanged
    mov qword [var_e], 0x13         ;; rewrite whole i64

    ;; initialize 'rax'
    mov rax, 0xddccbbaa44332211

    ;; store i8
    mov qword [var_e], 0x0          ;; clear
    mov byte [var_e], 0xff          ;; store i8 imm
    mov byte [var_e], al            ;; store i8 from reg

    ;; store i16
    mov qword [var_e], 0x0
    mov word [var_e], 0xffee
    mov word [var_e], ax

    ;; store i32
    mov qword [var_e], 0x0
    mov dword [var_e], 0xffeeddcc
    mov dword [var_e], eax

    ;; store i64
    mov qword [var_e], 0x17
    mov qword [var_e], rax

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
