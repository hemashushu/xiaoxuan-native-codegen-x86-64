;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

extern printf

section .data
one         dq  11
two         dq  13
fmt_msg     db  "one=%d, two=%d", 0xa, 0x0  ;; "\n\0"

section .text
global main
main:
    enter       0,0
    ;; 'enter N,0' equivalent to:
    ;;
    ;; push ebp
	;; mov	ebp, esp
	;; sub	esp, N

    ; arguments
    ; NO. 64-bits 32-bits     float
    ; 1   rdi     edi         xmm0
    ; 2   rsi     esi         xmm1
    ; 3   rdx     edx         xmm2
    ; 4   rcx     ecx         xmm3
    ; 5   r8      r8d         xmm4
    ; 6   r9      r9d         xmm5
    ;                         xmm6
    ;                         xmm7
    ;
    ; return
    ; NO. 64-bits 32-bits     float
    ; 1   rax     eax         xmm0

    ;; call the "printf" function
    mov         rdx, qword [two]    ;; 3rd arg
    mov         rsi, qword [one]    ;; 2nd arg
    lea         rdi, [fmt_msg]  ;; 1st arg

    ;; for variable-args function, to indicate that there is no floating-point args
    mov         eax, 0
    call        printf

    mov         eax, 0      ;; 'main' function return value

    leave

    ;; 'leave' equivalent to:
    ;; mov	esp, ebp
	;; pop ebp

    ret