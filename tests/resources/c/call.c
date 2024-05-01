/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>

/*
    arguments
    NO. 64-bits 32-bits     float
    1   rdi     edi         xmm0
    2   rsi     esi         xmm1
    3   rdx     edx         xmm2
    4   rcx     ecx         xmm3
    5   r8      r8d         xmm4
    6   r9      r9d         xmm5
                            xmm6
                            xmm7

    return
    NO. 64-bits 32-bits     float
    1   rax     eax         xmm0

    usage
    rax         return value    \
    rcx         4th arg         |
    rdx         3rd arg         |
    rsi         2nd arg         | feel free to use it
    rdi         1st arg         | before making a single call
    r8          5th arg         |
    r9          6th arg         |
    r10         temporary       |
    r11         temporary       |
    xmm0..xmm15 temporary       /

    rbx         callee saved    \
    rbp         callee saved    |
    r12         callee saved    | it needs to be restored before return
    r13         callee saved    | if it is used
    r14         callee saved    |
    r15         callee saved    /
*/

int int_args(int a, int b, int c)
{
    return a * b + c;

    /*
    0000000000001139 <int_args>:
    1139:       55                      push   rbp
    113a:       48 89 e5                mov    rbp,rsp
    113d:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
    1140:       89 75 f8                mov    DWORD PTR [rbp-0x8],esi
    1143:       89 55 f4                mov    DWORD PTR [rbp-0xc],edx

    return a * b + c;
    1146:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
    1149:       0f af 45 f8             imul   eax,DWORD PTR [rbp-0x8]
    114d:       89 c2                   mov    edx,eax
    114f:       8b 45 f4                mov    eax,DWORD PTR [rbp-0xc]
    1152:       01 d0                   add    eax,edx
    1154:       5d                      pop    rbp
    1155:       c3                      ret
    */
}

float float_args(int a, float m, float n, int b)
{
    int c = a + b;
    float p = m + n;
    float q = (float)c;
    return p + q;

    /*
    0000000000001156 <float_args>:
    1156:       55                      push   rbp
    1157:       48 89 e5                mov    rbp,rsp
    115a:       89 7d ec                mov    DWORD PTR [rbp-0x14],edi
    115d:       f3 0f 11 45 e8          movss  DWORD PTR [rbp-0x18],xmm0
    1162:       f3 0f 11 4d e4          movss  DWORD PTR [rbp-0x1c],xmm1
    1167:       89 75 e0                mov    DWORD PTR [rbp-0x20],esi

    int c = a + b;
    116a:       8b 55 ec                mov    edx,DWORD PTR [rbp-0x14]
    116d:       8b 45 e0                mov    eax,DWORD PTR [rbp-0x20]
    1170:       01 d0                   add    eax,edx
    1172:       89 45 f4                mov    DWORD PTR [rbp-0xc],eax

    float p = m + n;
    1175:       f3 0f 10 45 e8          movss  xmm0,DWORD PTR [rbp-0x18]
    117a:       f3 0f 58 45 e4          addss  xmm0,DWORD PTR [rbp-0x1c]
    117f:       f3 0f 11 45 f8          movss  DWORD PTR [rbp-0x8],xmm0

    float q = (float)c;
    1184:       66 0f ef c0             pxor   xmm0,xmm0
    1188:       f3 0f 2a 45 f4          cvtsi2ss xmm0,DWORD PTR [rbp-0xc]
    118d:       f3 0f 11 45 fc          movss  DWORD PTR [rbp-0x4],xmm0

    return p + q;
    1192:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    1197:       f3 0f 58 45 fc          addss  xmm0,DWORD PTR [rbp-0x4]
    119c:       5d                      pop    rbp
    119d:       c3                      ret
    */
}

int long_args(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10)
{
    int left = a1 + a2 + a3 + a4 + a5;
    int right = a6 + a7 + a8 + a9 + a10;
    return left + right;

    /*
    arguments
    NO. 64-bits 32-bits
    1   rdi     edi
    2   rsi     esi
    3   rdx     edx
    4   rcx     ecx
    5   r8      r8d
    6   r9      r9d

    | ... | other args
    | 9th | rbp + 32
    | 8th | rbp + 24
    | 7th | rbp + 16
    | rip | (return addr, auto push by 'call' instruction)
    | rbp | <-- rbp
    | rbx | \
    | r10 | | callee saved regs and local variables
    | r12 | /
    | ... | <-- rsp
    */

    /*
    000000000000119e <long_args>:
    119e:       55                      push   rbp
    119f:       48 89 e5                mov    rbp,rsp
    11a2:       89 7d ec                mov    DWORD PTR [rbp-0x14],edi
    11a5:       89 75 e8                mov    DWORD PTR [rbp-0x18],esi
    11a8:       89 55 e4                mov    DWORD PTR [rbp-0x1c],edx
    11ab:       89 4d e0                mov    DWORD PTR [rbp-0x20],ecx
    11ae:       44 89 45 dc             mov    DWORD PTR [rbp-0x24],r8d
    11b2:       44 89 4d d8             mov    DWORD PTR [rbp-0x28],r9d

    int left = a1 + a2 + a3 + a4 + a5;
    11b6:       8b 55 ec                mov    edx,DWORD PTR [rbp-0x14]
    11b9:       8b 45 e8                mov    eax,DWORD PTR [rbp-0x18]
    11bc:       01 c2                   add    edx,eax
    11be:       8b 45 e4                mov    eax,DWORD PTR [rbp-0x1c]
    11c1:       01 c2                   add    edx,eax
    11c3:       8b 45 e0                mov    eax,DWORD PTR [rbp-0x20]
    11c6:       01 c2                   add    edx,eax
    11c8:       8b 45 dc                mov    eax,DWORD PTR [rbp-0x24]
    11cb:       01 d0                   add    eax,edx
    11cd:       89 45 f8                mov    DWORD PTR [rbp-0x8],eax

    int right = a6 + a7 + a8 + a9 + a10;
    11d0:       8b 55 d8                mov    edx,DWORD PTR [rbp-0x28]
    11d3:       8b 45 10                mov    eax,DWORD PTR [rbp+0x10]
    11d6:       01 c2                   add    edx,eax
    11d8:       8b 45 18                mov    eax,DWORD PTR [rbp+0x18]
    11db:       01 c2                   add    edx,eax
    11dd:       8b 45 20                mov    eax,DWORD PTR [rbp+0x20]
    11e0:       01 c2                   add    edx,eax
    11e2:       8b 45 28                mov    eax,DWORD PTR [rbp+0x28]
    11e5:       01 d0                   add    eax,edx
    11e7:       89 45 fc                mov    DWORD PTR [rbp-0x4],eax

    return left + right;
    11ea:       8b 55 f8                mov    edx,DWORD PTR [rbp-0x8]
    11ed:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
    11f0:       01 d0                   add    eax,edx
    11f2:       5d                      pop    rbp
    11f3:       c3                      ret
    */
}

int no_args()
{
    int i = int_args(11, 13, 17);                     // 160
    float j = float_args(11, 1.3, 1.7, 19);           // 33
    int k = long_args(1, 2, 3, 4, 5, 6, 7, 8, 9, 10); // 55

    int m = i + (int)j + k; // 248
    return m;

    /*
    00000000000011f4 <no_args>:
    11f4:       55                      push   rbp
    11f5:       48 89 e5                mov    rbp,rsp

    ;; allocate the space for local variables.

    11f8:       48 83 ec 10             sub    rsp,0x10

    int i = int_args(11, 13, 17);                     // 160
    11fc:       ba 11 00 00 00          mov    edx,0x11
    1201:       be 0d 00 00 00          mov    esi,0xd
    1206:       bf 0b 00 00 00          mov    edi,0xb
    120b:       e8 29 ff ff ff          call   1139 <int_args>
    1210:       89 45 f0                mov    DWORD PTR [rbp-0x10],eax

    float j = float_args(11, 1.3, 1.7, 19);           // 33
    1213:       be 13 00 00 00          mov    esi,0x13
    1218:       f3 0f 10 0d f4 0d 00    movss  xmm1,DWORD PTR [rip+0xdf4]        # 2014 <_IO_stdin_used+0x14>
    121f:       00
    1220:       8b 05 f2 0d 00 00       mov    eax,DWORD PTR [rip+0xdf2]        # 2018 <_IO_stdin_used+0x18>
    1226:       66 0f 6e c0             movd   xmm0,eax
    122a:       bf 0b 00 00 00          mov    edi,0xb
    122f:       e8 22 ff ff ff          call   1156 <float_args>
    1234:       66 0f 7e c0             movd   eax,xmm0
    1238:       89 45 f4                mov    DWORD PTR [rbp-0xc],eax

    int k = long_args(1, 2, 3, 4, 5, 6, 7, 8, 9, 10); // 55

    ;; arguments
    ;; NO. 64-bits 32-bits
    ;; 1   rdi     edi
    ;; 2   rsi     esi
    ;; 3   rdx     edx
    ;; 4   rcx     ecx
    ;; 5   r8      r8d
    ;; 6   r9      r9d
    ;;
    ;; | ... | other args
    ;; | 8th | rbp + 24
    ;; | 7th | rbp + 16
    ;; | rip |
    ;; | rbp | <-- rbp
    ;; | rbx |
    ;; | r10 |
    ;; | r12 |
    ;; | ... | <-- rsp

    123b:       6a 0a                   push   0xa
    123d:       6a 09                   push   0x9
    123f:       6a 08                   push   0x8
    1241:       6a 07                   push   0x7
    1243:       41 b9 06 00 00 00       mov    r9d,0x6
    1249:       41 b8 05 00 00 00       mov    r8d,0x5
    124f:       b9 04 00 00 00          mov    ecx,0x4
    1254:       ba 03 00 00 00          mov    edx,0x3
    1259:       be 02 00 00 00          mov    esi,0x2
    125e:       bf 01 00 00 00          mov    edi,0x1
    1263:       e8 36 ff ff ff          call   119e <long_args>
    1268:       48 83 c4 20             add    rsp,0x20
    126c:       89 45 f8                mov    DWORD PTR [rbp-0x8],eax

    int m = i + (int)j + k; // 248
    126f:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    1274:       f3 0f 2c d0             cvttss2si edx,xmm0
    1278:       8b 45 f0                mov    eax,DWORD PTR [rbp-0x10]
    127b:       01 c2                   add    edx,eax
    127d:       8b 45 f8                mov    eax,DWORD PTR [rbp-0x8]
    1280:       01 d0                   add    eax,edx
    1282:       89 45 fc                mov    DWORD PTR [rbp-0x4],eax

    return m;
    1285:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
    1288:       c9                      leave
    1289:       c3                      ret
    */
}

int main(void)
{
    int a = no_args();

    // variable args
    printf("%d, %d, %d, %d\n", a, 11, 13, 15);

    return 0;

    /*
    000000000000128a <main>:
    128a:       55                      push   rbp
    128b:       48 89 e5                mov    rbp,rsp
    128e:       48 83 ec 10             sub    rsp,0x10
    int a = no_args();
    1292:       b8 00 00 00 00          mov    eax,0x0
    1297:       e8 58 ff ff ff          call   11f4 <no_args>
    129c:       89 45 fc                mov    DWORD PTR [rbp-0x4],eax

    printf("%d, %d, %d, %d\n", a, 11, 13, 15);
    129f:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
    12a2:       41 b8 0f 00 00 00       mov    r8d,0xf
    12a8:       b9 0d 00 00 00          mov    ecx,0xd
    12ad:       ba 0b 00 00 00          mov    edx,0xb
    12b2:       89 c6                   mov    esi,eax
    12b4:       48 8d 05 49 0d 00 00    lea    rax,[rip+0xd49]        # 2004 <_IO_stdin_used+0x4>
    12bb:       48 89 c7                mov    rdi,rax
    12be:       b8 00 00 00 00          mov    eax,0x0
    12c3:       e8 68 fd ff ff          call   1030 <printf@plt>

    return 0;
    12c8:       b8 00 00 00 00          mov    eax,0x0
    12cd:       c9                      leave
    12ce:       c3                      ret
    */
}