;; Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
;;
;; This Source Code Form is subject to the terms of
;; the Mozilla Public License version 2.0 and additional exceptions,
;; more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

section .text

global _start
global fn_without_prologue_epilogue
global fn_typical
global fn_local_variables

_start:
    ;; call the 1st function
    mov         rsi, 13     ;; 2nd arg
    mov         rdi, 11     ;; 1st arg
    call        fn_without_prologue_epilogue
    ;; expect return value 'rax == 24'

    ;; call the 2nd function
    mov         rdi, 23     ;; 1st arg
    call        fn_typical
    ;; expect return value 'rax == 23 + 100 == 123'

    ;; for testing
    mov         rbx, 0x22
    mov         r10, 0x33

    ;; call the 3rd function
    call        fn_local_variables
    ;; expect return value 'rax == 160'

    ;; check rbx==0x22, r10=0x33

exit:
    mov rax, 60     ;; SYS_exit
    mov rdi, 0      ;; exit code, EXIT_SUCCESS
    syscall

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

fn_without_prologue_epilogue:
    ;; fn add(int a, int b) { a + b }
    mov     rax, rdi
    add     rax, rsi
    ret

fn_typical:
    ;; fn inc(int c) { add(c, 100) }
    ;; prologue
    push    rbp
    mov     rbp, rsp

    mov     rsi, 100    ;; 2nd arg
    ;; mov     rdi, rdi ;; 1st arg
    call    fn_without_prologue_epilogue

    ;; epilogue
    mov     rsp, rbp
    pop     rbp
    ret

    ; |     | caller frame
    ; | ... |
    ; | rip | (return addr, auto push by 'call' instruction)
    ; | rbp | <-- rbp <-- rsp
    ; | ... |
    ; |     | callee frame

fn_local_variables:
    ;; fn accu() {
    ;;    a = add(11, 13)   ;; 24
    ;;    b = add(17, 19)   ;; 36
    ;;    c = add(a, b)     ;; 60
    ;;    return inc(c)     ;; 160
    ;;}

    ; arguments
    ; NO. 64-bits 32-bits
    ; 1   rdi     edi
    ; 2   rsi     esi
    ; 3   rdx     edx
    ; 4   rcx     ecx
    ; 5   r8      r8d
    ; 6   r9      r9d
    ;
    ; | ... | other args
    ; | 9th | rbp + 32
    ; | 8th | rbp + 24
    ; | 7th | rbp + 16
    ; | rip | (return addr, auto push by 'call' instruction)
    ; | rbp | <-- rbp
    ; | rbx | rbp - 8  (callee saved reg)
    ; | r10 | rbp - 16 (callee saved reg)
    ; | v2  | rbp - 24 (local variable)
    ; | v1  | rbp - 32 (local variable) <-- rsp
    ; | ... |

    ;; prologue
    push    rbp
    mov     rbp, rsp

    push    rbx     ;; callee saved reg
    push    r10     ;; callee saved reg
    sub     rsp, 16 ;; 16-bytes local variable slot

    ;;    a = add(11, 13)   ;; 24
    ;;    b = add(17, 19)   ;; 36
    ;;    c = add(a, b)     ;; 60
    ;;    d = inc(c)        ;; 160

    mov     rsi, 13
    mov     rdi, 11
    call    fn_without_prologue_epilogue
    mov     r10, rax    ;; rax=24 save to 'a'  (reg r10)

    mov     rsi, 19
    mov     rdi, 17
    call    fn_without_prologue_epilogue
    mov     rbx, rax    ;; rax=36 save to 'b'  (reg rbx)

    mov     rsi, rbx
    mov     rdi, r10
    call    fn_without_prologue_epilogue
    mov     [rbp-32], rax    ;; rax=60 save to 'c' (local var 1)

    mov     rdi, [rbp-32]
    call    fn_typical
    mov     [rbp-24], rax   ;; rax=160 save to 'd' (local var 2)

    ;; load var2 to rax for returning
    mov     rax, [rbp-24]

    ;; restore saved regs
    mov     r10, [rbp-16]
    mov     rbx, [rbp-8]

    ;; epilogue
    mov     rsp, rbp
    pop     rbp
    ret
