/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>

struct result
{
    int i;
    long j;
    int k;
};

void caller(struct result *r)
{
    int i = 11;
    long j = 13;
    int k = 17;

    r->i = i;
    r->j = j;
    r->k = k;

    /*
    0:   55                      push   rbp
    1:   48 89 e5                mov    rbp,rsp
    4:   48 89 7d e8             mov    QWORD PTR [rbp-0x18],rdi
        int i = 11;
    8:   c7 45 f0 0b 00 00 00    mov    DWORD PTR [rbp-0x10],0xb
        long j = 13;
    f:   48 c7 45 f8 0d 00 00    mov    QWORD PTR [rbp-0x8],0xd
    16:   00
        int k = 17;
    17:   c7 45 f4 11 00 00 00    mov    DWORD PTR [rbp-0xc],0x11

        r->i = i;
    1e:   48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
    22:   8b 55 f0                mov    edx,DWORD PTR [rbp-0x10]
    25:   89 10                   mov    DWORD PTR [rax],edx
        r->j = j;
    27:   48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
    2b:   48 8b 55 f8             mov    rdx,QWORD PTR [rbp-0x8]
    2f:   48 89 50 08             mov    QWORD PTR [rax+0x8],rdx
        r->k = k;
    33:   48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
    37:   8b 55 f4                mov    edx,DWORD PTR [rbp-0xc]
    3a:   89 50 10                mov    DWORD PTR [rax+0x10],edx
    }
    3d:   90                      nop
    3e:   5d                      pop    rbp
    3f:   c3                      ret
    */
}

int main(void)
{
    struct result r = {};
    caller(&r);
    printf("%d, %ld, %d\n", r.i, r.j, r.k);

    return 0;

    /*
    40:   55                      push   rbp
    41:   48 89 e5                mov    rbp,rsp
    44:   48 83 ec 20             sub    rsp,0x20
    48:   64 48 8b 04 25 28 00    mov    rax,QWORD PTR fs:0x28
    4f:   00 00
    51:   48 89 45 f8             mov    QWORD PTR [rbp-0x8],rax
    55:   31 c0                   xor    eax,eax
        struct result r = {};
    57:   66 0f ef c0             pxor   xmm0,xmm0
    5b:   0f 29 45 e0             movaps XMMWORD PTR [rbp-0x20],xmm0
    5f:   66 0f d6 45 f0          movq   QWORD PTR [rbp-0x10],xmm0
        caller(&r);
    64:   48 8d 45 e0             lea    rax,[rbp-0x20]
    68:   48 89 c7                mov    rdi,rax
    6b:   e8 00 00 00 00          call   70 <main+0x30>
        printf("%d, %ld, %d\n", r.i, r.j, r.k);
    70:   8b 4d f0                mov    ecx,DWORD PTR [rbp-0x10]
    73:   48 8b 55 e8             mov    rdx,QWORD PTR [rbp-0x18]
    77:   8b 45 e0                mov    eax,DWORD PTR [rbp-0x20]
    7a:   89 c6                   mov    esi,eax
    7c:   48 8d 05 00 00 00 00    lea    rax,[rip+0x0]        # 83 <main+0x43>
    83:   48 89 c7                mov    rdi,rax
    86:   b8 00 00 00 00          mov    eax,0x0
    8b:   e8 00 00 00 00          call   90 <main+0x50>

        return 0;
    90:   b8 00 00 00 00          mov    eax,0x0
    95:   48 8b 55 f8             mov    rdx,QWORD PTR [rbp-0x8]
    99:   64 48 2b 14 25 28 00    sub    rdx,QWORD PTR fs:0x28
    a0:   00 00
    a2:   74 05                   je     a9 <main+0x69>
    a4:   e8 00 00 00 00          call   a9 <main+0x69>
    a9:   c9                      leave
    aa:   c3                      ret
    */
}