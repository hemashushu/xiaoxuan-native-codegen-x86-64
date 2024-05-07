;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   db  0x81                ;; i8
var_b   dw  0x8001              ;; i16
var_c   dd  0x80000001          ;; i32
var_d   dq  0x8000000000000001  ;; i64

section .bss
;; the bss format:
;; "variable_name resource_data_type count"
var_e   resq    1               ;; one i64 data

section .text
global _start
_start:

truncate:
    ;; truncate and mov to reg (i.e. portion mov)
    mov rcx, 0xffeeddcc99887766

    mov rax, -1
    mov al, cl              ;; to i8, the high portion beyonds i8 will keep UNCHANGED

    mov rax, -1
    mov ax, cx              ;; to i16, the high portion beyonds i16 will keep UNCHANGED

    mov rax, -1
    mov eax, ecx

    ;; NOTE:
    ;; when the dest reg is <reg32>, the high portion of reg (bits 32 to 63) will be set to ZERO,
    ;; includes instructions 'mov', 'movzx', 'movsx'

truncate_to_memory:
    ;; truncate and store to memory (i.e. portion store)
    mov qword [var_e], 0
    mov byte [var_e], cl    ;; to i8

    mov qword [var_e], 0
    mov word [var_e], cx    ;; to i16

    mov qword [var_e], 0
    mov dword [var_e], ecx  ;; to i32

unsign_extension:
    ;; unsign extension
    ;;
    ;; 'movzx <reg16/32/64>, <op8/16>'
    ;;
    ;; unsign extend i32 -> i64
    ;; 'mov <reg32>, <op32>'

    ;; unsign extension from reg
    mov ecx, 0x84838281

    mov rax, 0xffeeddcc99887766
    movzx ax, cl    ;; i8 -> i16, the high portion beyonds i16 keep UNCHANGED, instead of ZERO !!

    mov rax, 0xffeeddcc99887766
    movzx eax, cl   ;; i8 -> i32

    mov rax, 0xffeeddcc99887766
    movzx rax, cl   ;; i8 -> i64

    mov rax, 0xffeeddcc99887766
    movzx eax, cx   ;; i16 -> i32

    mov rax, 0xffeeddcc99887766
    movzx rax, cx   ;; i16 -> i64

    mov rax, 0xffeeddcc99887766
    mov eax, ecx    ;; i32 -> i64 (note: i32 -> reg32)

unsign_extension_from_memory:
    ;; unsign extension from memory
    mov rax, 0xffeeddcc99887766
    movzx ax, byte [var_a]      ;; i8 -> i16, the high portion beyonds i16 will keep UNCHANGED, instead of ZERO

    mov rax, 0xffeeddcc99887766
    movzx eax, byte [var_a]     ;; i8 -> i32

    mov rax, 0xffeeddcc99887766
    movzx rax, byte [var_a]     ;; i8 -> i64

    mov rax, 0xffeeddcc99887766
    movzx eax, word [var_b]     ;; i16 -> i32

    mov rax, 0xffeeddcc99887766
    movzx rax, word [var_b]     ;; i16 -> i64

    mov rax, 0xffeeddcc99887766
    mov eax, dword [var_c]      ;; i32 -> i64 (note: i32 -> reg32)

sign_extension:
    ;; sign extension
    ;;
    ;; 'movsx <reg16/32/64>, <op8/16>'
    ;; 'movsxd <reg64>, <op32>

    ;; sign extension from reg
    mov ecx, 0x84838281

    mov rax, 0xffeeddcc99887766
    movsx ax, cl    ;; i8 -> i16, the high portion beyonds i16 will keep UNCHANGED, instead of ONE or ZERO

    mov rax, 0xffeeddcc99887766
    movsx eax, cl   ;; i8 -> i32

    mov rax, 0xffeeddcc99887766
    movsx rax, cl   ;; i8 -> i64

    mov rax, 0xffeeddcc99887766
    movsx eax, cx   ;; i16 -> i32

    mov rax, 0xffeeddcc99887766
    movsx rax, cx   ;; i16 -> i64

    mov rax, 0xffeeddcc99887766
    movsxd rax, ecx ;; i32 -> i64

sign_extension_from_memory:
    ;; sign extension from memory
    mov rax, 0xffeeddcc99887766
    movsx ax, byte [var_a]      ;; i8 -> i16, the high portion beyonds i16 will keep UNCHANGED, instead of ONE or ZERO

    mov rax, 0xffeeddcc99887766
    movsx eax, byte [var_a]     ;; i8 -> i32

    mov rax, 0xffeeddcc99887766
    movsx rax, byte [var_a]     ;; i8 -> i64

    mov rax, 0xffeeddcc99887766
    movsx eax, word [var_b]     ;; i16 -> i32

    mov rax, 0xffeeddcc99887766
    movsx rax, word [var_b]     ;; i16 -> i64

    mov rax, 0xffeeddcc99887766
    movsxd rax, dword [var_c]   ;; i32 -> i64

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
