;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   db  11      ;; 0x0b, i8

align   2
var_b   dw  13      ;; 0x0d, i16

align   4
var_c   dd  17      ;; 0x11, i32

;; i64 array with 4 elements
;;      [0x13, 0x17, 0x1d, 0x1f]
;; idx:  0     1     2     3
align   8
var_d   dq  19,23,29,31

section .bss
var_e   resq    1   ;; 1 qword data

section .text
global _start
_start:

load_address:
    ;; load the address of var_a
    lea rax, [var_a]
    ;; rax == address of var_a
    ;; '(gdb) i var var_a' should output '0x402000' etc.

    mov rax, 0      ;; clear
    mov rax, var_a
    ;; rax == address of var_a

    lea rax, [var_b]
    ;; address of var_b == var_a + 2

    lea rax, [var_c]
    ;; address of var_c == var_a + 4

    lea rax, [var_d]
    ;; address of var_d == var_a + 8

    lea rax, [var_e]
    ;; address of var_e > var_d

load_value:
    ;; load i8
    mov rax, 0xffeeddcc99887766 ;; for testing
    mov al, byte [var_a]        ;; load i8, the high portion beyonds i8 will keep unchanged
    ;; rax == 0xffeeddcc9988770b
    ;; to check the value var_a:
    ;; (gdb) p (char) var_a
    ;; or
    ;; (gdb) p/x (char) var_a
    ;;
    ;; x = hexadecimal
    ;; - o - octal
    ;; - x - hexadecimal
    ;; - d - decimal
    ;; - u - unsigned decimal
    ;; - t - binary
    ;; - f - floating point
    ;; - a - address
    ;; - c - char
    ;; - s - string
    ;;
    ;; or
    ;; (gdb) x/xb &var_a
    ;; (gdb) x/1xb &var_a
    ;;
    ;; b = byte
    ;; - b - byte
    ;; - h - halfword (16-bit value)
    ;; - w - word (32-bit value)
    ;; - g - giant word (64-bit value)
    ;;
    ;; 1 = length/element count
    ;;
    ;; note that 'x' command supports additional format 'i - instruction', e.g.
    ;; (gdb) x/10i $rip

    mov rax, 0                  ;; clear
    mov al, byte [var_a]        ;; load i8
    ;; rax == 0xb

    ;; load i16
    mov rax, 0xffeeddcc99887766 ;; for testing
    mov ax, word [var_b]        ;; load i16, the high portion beyonds i16 will keep unchanged
    ;; rax == 0xffeeddcc9988000d

    mov rax, 0                  ;; set to '0' first
    mov ax, word [var_b]        ;; load i16
    ;; rax == 0xd

    ;; load i32
    mov rax, 0xffeeddcc99887766 ;; for testing
    mov eax, dword [var_c]
    ;; rax == 0x11

    ;; NOTE:
    ;; when the dest reg is <reg32>, the high portion of reg (bits 32 to 63) will be set to ZERO,
    ;; includes instructions 'mov', 'movzx', 'movsx'

    ;; load i64
    lea rax, [var_d]
    mov rax, qword [var_d]
    ;; rax == 0x13

indirect_load:
    ;; memory address:
    ;;
    ;; [base_address + (index_register * scale) + displacement]
    ;; - base_address: 64-bits reg or variable name
    ;; - index_register: reg
    ;; - scale: 1, 2, 4, 8
    ;; - displacement: imm
    ;;
    ;;
    ;; displacement usage:
    ;; - The displacement is often used to access specific elements within data
    ;;   structures or arrays. For example, to access the second element
    ;;   (starting at index 1) of an array stored at baseAddr, you could use
    ;;   a displacement of 4 (assuming each element is 4 bytes).
    ;; - It can also be used to fine-tune memory access when the base address
    ;;   doesn't directly point to the desired location.

    lea rcx, [var_d]
    mov rax, qword [rcx]
    ;; rcx == address of var_d
    ;; rax == 0x13

    mov rax, 0  ;; clear
    mov rax, qword [var_d + 8]
    ;; rax == 0x17

    mov rax, 0  ;; clear
    mov rax, qword [rcx + 8]
    ;; rax == 0x17

    mov rax, 0  ;; clear
    mov rsi, 8
    mov rax, qword [rcx + rsi]
    ;; rax == 0x17

    mov rax, 0  ;; clear
    mov rsi, 2  ;; let index = 2
    mov rax, qword [rcx + (rsi * 8)]
    ;; rax == 0x1d

    mov rax, 0  ;; clear
    mov rsi, 2  ;; let index = 2
    mov rax, qword [rcx + (rsi * 8) + 8]
    ;; rax == 0x1f

loop_test:
    mov rax, 0
    mov r10, 0
    mov ecx, 4      ;; loop count

loop_point:
    mov r10, qword [var_d + (ecx * 8) - 8]
    add rax, r10
    loop loop_point ;; loop if ecx != 0
    ;; rax = 19 + 23 + 29 + 31 = 102, 0x66

store_imm:
    ;; store with immediate numbers
    mov dword [var_e], 0x99887766   ;; write the low portion
    ;; (gdb) p/x (int) var_e
    ;; (gdb) x/wx &_var_e
    ;;
    ;; expect: 0x99887766

    mov dword [var_e+4], 0xffeeddcc ;; write the high portion
    ;; (gdb) p/x (long) var_e
    ;; (gdb) x/gx &_var_e           ;; g=int64
    ;;
    ;; expect: 0xffeeddcc_99887766

    mov byte [var_e], 0x81          ;; rewrite the low portion with i8, the high portion beyonds i8 should keep unchanged
    ;; (gdb) p/x (long) var_e
    ;; (gdb) x/gx &_var_e
    ;;
    ;; expect: 0xffeeddcc_998877_81

    mov word [var_e], 0x8001        ;; rewrite the low portion with i16, the high portion beyonds i16 should keep unchanged
    mov dword [var_e], 0x80000001   ;; rewrite the low portion with i32, the high portion beyonds i32 should keep unchanged
    mov qword [var_e], 0x13         ;; rewrite the whole memory with i64

store:
    ;; initialize 'rax'
    mov rax, 0xddccbbaa44332211

    ;; store i8 from reg
    mov qword [var_e], 0x0          ;; clear
    mov byte [var_e], 0xff          ;; store i8 imm
    mov byte [var_e], al            ;; store i8 from reg

    ;; store i16 from reg
    mov qword [var_e], 0x0
    mov word [var_e], 0xffee
    mov word [var_e], ax

    ;; store i32 from reg
    mov qword [var_e], 0x0
    mov dword [var_e], 0xffeeddcc
    mov dword [var_e], eax

    ;; store i64 from reg
    mov qword [var_e], 0x17
    mov qword [var_e], rax

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
