;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .data
var_a   dd      11,13,0,0
                ;; 0xb, 0xd, 0, 0

section .text
global _start
_start:
    ;; 'push <op64>'
    ;; e.g.
    ;; - push rax
    ;; - push qword [var]   ;; read the value of variable, and push
    ;; - push var           ;; push the address of variable
    ;;
    ;; 'pop <op64>'
    ;; e.g.
    ;; - pop rax            ;;
    ;; - pop qword [var]    ;; pop the value and write into memory

    mov rcx, rsp
    ;; check the values of rsp and rbp
    ;; (gdb) layout regs
    ;; or
    ;; (gdb) i r
    ;; (gdb) p/x $rsp
    ;; assume rsp == 0x7fff_ffff_cf40

    mov rcx, rbp
    ;; assume 0

    ;; push
    mov rax, 11
    push rax
    ;; rsp == 0x7fff_ffff_cf38
    ;; 0x38 = 0x40 - 8 (the length of int64 is 8 bytes)

    mov rax, 13
    push rax
    ;; rsp == 0x7fff_ffff_cf30
    ;; 0x30 = 0x48 - 8 (the length of int64 is 8 bytes)

    ;; clear rax
    mov rax, 0

    ;; pop
    pop rax
    ;; check the values of rsp and rbp
    ;; (gdb) p/x $rsp
    ;; 0x7fff_ffff_cf38
    ;; (gdb) p/x $rbp
    ;; 0x0

    pop rax
    ;; check the values of rsp and rbp
    ;; (gdb) p/x $rsp
    ;; 0x7fff_ffff_cf40
    ;; (gdb) p/x $rbp
    ;; 0x0

access_memory:
    push qword [var_a]
    ;; check stack top
    ;; (gdb) x/gx $rsp
    ;; 0x7fff_ffff_cf38: 0x????????_0000000b
    ;; (gdb) x/wx $rsp
    ;; 0x7fff_ffff_cf38: 0000000b

    push qword [var_a + 4]
    ;; check stack top
    ;; (gdb) x/wx $rsp
    ;; 0x7fff_ffff_cf30: 0000000d

    ;; check [var_a + 8]
    ;;
    ;; (gdb) x/wx (void *)&var_a + 8
    ;; 0x402008: 0x00000000

    pop qword [var_a + 8]
    ;; check stack top and [var_a + 8]
    ;; (gdb) x/wx $rsp
    ;; 0x7fff_ffff_cf38: 0000000b
    ;;
    ;; (gdb) x/wx (void *)&var_a + 8
    ;; 0x402008: 0x0000000d

    ;; check [var_a + 8]
    ;;
    ;; (gdb) x/wx (void *)&var_a + 12
    ;; 0x40200c: 0x00000000
    pop qword [var_a + 12]
    ;; check stack top and [var_a + 12]
    ;;
    ;; (gdb) p $rsp
    ;; 0x7fff_ffff_cf40
    ;;
    ;; (gdb) x/wx (void *)&var_a + 12
    ;; 0x40200c: 0x0000000b

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall
