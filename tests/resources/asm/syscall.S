;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

STDOUT_FILENO   equ     1
SYS_write       equ     1

EXIT_SUCCESS    equ     0
SYS_exit        equ     60

global _start
global main

section .rodata
    msg         db  "hello", 10 ;; line feed (LF) = 10
    msg_len     dq  6

section .text
_start:
    ;; call function 'main'
    ;;
    ;; instruction 'call' is used for calling a function.
    ;; push the 64-bit rip register and jump to the <funcName>.
    call    main

    ;; exit
    mov     rdi, EXIT_SUCCESS     ;; exit with '0'
    mov     rax, SYS_exit
    syscall

main:
    ;; prologue
    push    rbp
    mov     rbp,rsp

    mov     rcx, 0x22   ;; for testing
    mov     r11, 0x33   ;; for testing

    ;; write(file_number, string_addr, string_length)
    ;;
    ;; arguments
    ;; 1   rdi
    ;; 2   rsi
    ;; 3   rdx
    ;; 4   r10
    ;; 5   r8
    ;; 6   r9

    mov     rdx, [msg_len]
    mov     rsi, msg
    mov     rdi, STDOUT_FILENO
    mov     rax, SYS_write
    syscall

    ;; check the values of 'rcx' and 'r11' here

    ;; epilogue
    pop     rbp

    ;; 'ret' is used for returning from a function.
    ;; pop the stack into the rip register,
    ;; effecting a jump to the line after the call.
    ret

; $ yasm -f elf64 -o base.o base.S
;
; $ objdump -d -M intel base.o
;
; 0000000000000000 <_start>:
;    0:   e8 0c 00 00 00          call   11 <main>
;    5:   48 89 c7                mov    rdi,rax
;    8:   48 c7 c0 3c 00 00 00    mov    rax,0x3c
;    f:   0f 05                   syscall
;
; 0000000000000011 <main>:
;   11:   55                      push   rbp
;   12:   48 89 e5                mov    rbp,rsp
;   15:   48 c7 c0 0b 00 00 00    mov    rax,0xb
;   1c:   48 8b 0c 25 00 00 00    mov    rcx,QWORD PTR ds:0x0
;   23:   00
;   24:   48 01 c8                add    rax,rcx
;   27:   5d                      pop    rbp
;   28:   c3                      ret
;
; $ objdump -h base.o
;
; Sections:
; Idx Name          Size      VMA               LMA               File off  Algn
;   0 .text         00000026  0000000000000000  0000000000000000  00000040  2**4
;                   CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
;   1 .rodata       00000008  0000000000000000  0000000000000000  00000080  2**2
;                   CONTENTS, ALLOC, LOAD, READONLY, DATA
;
; $ readelf -r base.o
;
; Relocation section '.rela.text' at offset 0x68 contains 1 entry:
;   Offset          Info           Type           Sym. Value    Sym. Name + Addend
; 00000000001d  00030000000a R_X86_64_32       0000000000000000 .rodata + 0
;
; $ readelf -s base.o
;
; Symbol table '.symtab' contains 7 entries:
;    Num:    Value          Size Type    Bind   Vis      Ndx Name
;      0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
;      1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS base.S
;      2: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT    6
;      3: 0000000000000000     0 SECTION LOCAL  DEFAULT    6 .rodata
;      4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 .text
;      5: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT    4 _start
;      6: 000000000000000e     0 NOTYPE  GLOBAL DEFAULT    4 main

; to run this program:
; $ ld -g -o base.elf base.o
; $ ./base.elf
; $ echo $?
;
; the expect result is '24'