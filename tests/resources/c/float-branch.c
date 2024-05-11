/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>
#include <math.h>

float pi = 3.142;
float e = 2.718;
float pi_copy = 3.142;

int normal_float_comp(void)
{
    int result = 0;
    if (pi == pi_copy)
    {
        result++;
    }

    if (pi != e)
    {
        result++;
    }

    if (e < pi)
    {
        result++;
    }

    if (pi <= pi_copy)
    {
        result++;
    }

    if (pi > e)
    {
        result++;
    }

    if (pi >= pi_copy)
    {
        result++;
    }

    return result;
}

int special_float_comp(void)
{
    // NOTE:
    //  0.0 = 0x0000_0000   ;; [rbp-0x14]
    // -0.0 = 0x8000_0000   ;; [rbp-0x10]
    //  nan = 0xffc0_0000   ;; [rbp-0xc]
    // +inf = 0x7f80_0000   ;; [rbp-0x8]
    // -inf = 0xff80_0000   ;; [rbp-0x4]

    int result = 0;

    float val_zero_pos = 0.0;
    float val_zero_neg = -0.0;
    float val_nan = val_zero_pos / val_zero_pos; // or sqrt(-1.0), or nanf()
    float val_inf_pos = 1.0 / val_zero_pos;
    float val_inf_neg = -1.0 / val_zero_pos;

    if (isnan(val_nan))
    {
        result++;
    }

    if (isinf(val_inf_pos))
    {
        result++;
    }

    if (isinf(val_inf_neg))
    {
        result++;
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan == val_nan)
    {
        return 0;
    }

    if (val_nan != val_nan)
    {
        result++;
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan > val_zero_pos)
    {
        return 0;
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan > val_inf_pos)
    {
        return 0;
    }

    if (val_inf_pos != val_inf_neg)
    {
        result++;
    }

    if (val_inf_pos > val_inf_neg)
    {
        result++;
    }

    if (val_inf_pos > 1.0)
    {
        result++;
    }

    if (val_inf_neg < -1.0)
    {
        result++;
    }

    // 0.0 == -0.0
    if (val_zero_pos == val_zero_neg)
    {
        result++;
    }

    if (1.0 > val_zero_pos)
    {
        result++;
    }

    if (-1.0 < val_zero_neg)
    {
        result++;
    }

    return result;
}

int main(void)
{
    printf("expect 6, actual: %d\n", normal_float_comp());
    printf("expect 12, actual: %d\n", special_float_comp());
    return 0;
}

/*
$ objdump -M intel -S -d float-branch.elf
*/

/*
int normal_float_comp(void)
{
    1139:       55                      push   rbp
    113a:       48 89 e5                mov    rbp,rsp
    int result = 0;
    113d:       c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0
    if (pi == pi_copy)
    1144:       f3 0f 10 05 cc 2e 00    movss  xmm0,DWORD PTR [rip+0x2ecc]        # 4018 <pi>
    114b:       00
    114c:       f3 0f 10 0d cc 2e 00    movss  xmm1,DWORD PTR [rip+0x2ecc]        # 4020 <pi_copy>
    1153:       00
    1154:       0f 2e c1                ucomiss xmm0,xmm1
    1157:       7a 09                   jp     1162 <normal_float_comp+0x29>
    1159:       0f 2e c1                ucomiss xmm0,xmm1
    115c:       75 04                   jne    1162 <normal_float_comp+0x29>
    {
        result++;
    115e:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    if (pi != e)
    1162:       f3 0f 10 05 ae 2e 00    movss  xmm0,DWORD PTR [rip+0x2eae]        # 4018 <pi>
    1169:       00
    116a:       f3 0f 10 0d aa 2e 00    movss  xmm1,DWORD PTR [rip+0x2eaa]        # 401c <e>
    1171:       00
    1172:       0f 2e c1                ucomiss xmm0,xmm1
    1175:       7a 05                   jp     117c <normal_float_comp+0x43>
    1177:       0f 2e c1                ucomiss xmm0,xmm1
    117a:       74 04                   je     1180 <normal_float_comp+0x47>
    {
        result++;
    117c:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    if (e < pi)
    1180:       f3 0f 10 0d 94 2e 00    movss  xmm1,DWORD PTR [rip+0x2e94]        # 401c <e>
    1187:       00
    1188:       f3 0f 10 05 88 2e 00    movss  xmm0,DWORD PTR [rip+0x2e88]        # 4018 <pi>
    118f:       00
    1190:       0f 2f c1                comiss xmm0,xmm1
    1193:       76 04                   jbe    1199 <normal_float_comp+0x60>
    {
        result++;
    1195:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    if (pi <= pi_copy)
    1199:       f3 0f 10 0d 77 2e 00    movss  xmm1,DWORD PTR [rip+0x2e77]        # 4018 <pi>
    11a0:       00
    11a1:       f3 0f 10 05 77 2e 00    movss  xmm0,DWORD PTR [rip+0x2e77]        # 4020 <pi_copy>
    11a8:       00
    11a9:       0f 2f c1                comiss xmm0,xmm1
    11ac:       72 04                   jb     11b2 <normal_float_comp+0x79>
    {
        result++;
    11ae:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    if (pi > e)
    11b2:       f3 0f 10 05 5e 2e 00    movss  xmm0,DWORD PTR [rip+0x2e5e]        # 4018 <pi>
    11b9:       00
    11ba:       f3 0f 10 0d 5a 2e 00    movss  xmm1,DWORD PTR [rip+0x2e5a]        # 401c <e>
    11c1:       00
    11c2:       0f 2f c1                comiss xmm0,xmm1
    11c5:       76 04                   jbe    11cb <normal_float_comp+0x92>
    {
        result++;
    11c7:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    if (pi >= pi_copy)
    11cb:       f3 0f 10 05 45 2e 00    movss  xmm0,DWORD PTR [rip+0x2e45]        # 4018 <pi>
    11d2:       00
    11d3:       f3 0f 10 0d 45 2e 00    movss  xmm1,DWORD PTR [rip+0x2e45]        # 4020 <pi_copy>
    11da:       00
    11db:       0f 2f c1                comiss xmm0,xmm1
    11de:       72 04                   jb     11e4 <normal_float_comp+0xab>
    {
        result++;
    11e0:       83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1
    }

    return result;
    11e4:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
}
    11e7:       5d                      pop    rbp
    11e8:       c3                      ret
*/

/*
int special_float_comp(void)
{
    11e9:       55                      push   rbp
    11ea:       48 89 e5                mov    rbp,rsp
    // -0.0 = 0x8000_0000
    //  nan = 0xffc0_0000
    // +inf = 0x7f80_0000
    // -inf = 0xff80_0000

    int result = 0;
    11ed:       c7 45 e8 00 00 00 00    mov    DWORD PTR [rbp-0x18],0x0

    float val_zero_pos = 0.0;
    11f4:       66 0f ef c0             pxor   xmm0,xmm0
    11f8:       f3 0f 11 45 ec          movss  DWORD PTR [rbp-0x14],xmm0
    float val_zero_neg = -0.0;
    11fd:       f3 0f 10 05 3b 0e 00    movss  xmm0,DWORD PTR [rip+0xe3b]        # 2040 <_IO_stdin_used+0x40>
    1204:       00
    1205:       f3 0f 11 45 f0          movss  DWORD PTR [rbp-0x10],xmm0
    float val_nan = val_zero_pos / val_zero_pos; // or sqrt(-1.0), or nanf()
    120a:       f3 0f 10 45 ec          movss  xmm0,DWORD PTR [rbp-0x14]
    120f:       f3 0f 5e c0             divss  xmm0,xmm0
    1213:       f3 0f 11 45 f4          movss  DWORD PTR [rbp-0xc],xmm0
    float val_inf_pos = 1.0 / val_zero_pos;
    1218:       f3 0f 10 05 24 0e 00    movss  xmm0,DWORD PTR [rip+0xe24]        # 2044 <_IO_stdin_used+0x44>
    121f:       00
    1220:       f3 0f 5e 45 ec          divss  xmm0,DWORD PTR [rbp-0x14]
    1225:       f3 0f 11 45 f8          movss  DWORD PTR [rbp-0x8],xmm0
    float val_inf_neg = -1.0 / val_zero_pos;
    122a:       f3 0f 10 05 16 0e 00    movss  xmm0,DWORD PTR [rip+0xe16]        # 2048 <_IO_stdin_used+0x48>
    1231:       00
    1232:       f3 0f 5e 45 ec          divss  xmm0,DWORD PTR [rbp-0x14]
    1237:       f3 0f 11 45 fc          movss  DWORD PTR [rbp-0x4],xmm0

    if (isnan(val_nan))
    123c:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    1241:       0f 2e 45 f4             ucomiss xmm0,DWORD PTR [rbp-0xc]
    1245:       7b 04                   jnp    124b <special_float_comp+0x62>
    {
        result++;
    1247:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (isinf(val_inf_pos))
    124b:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    1250:       f3 0f 10 0d f8 0d 00    movss  xmm1,DWORD PTR [rip+0xdf8]        # 2050 <_IO_stdin_used+0x50>
    1257:       00
    ;; xmm0 == 0x7f80_0000
    ;; xmm1 == [rip+0xdf8] == 0x7fff_ffff
    1258:       0f 54 c1                andps  xmm0,xmm1
    ;; xmm0 == 0x7f80_0000
    125b:       0f 2e 05 fe 0d 00 00    ucomiss xmm0,DWORD PTR [rip+0xdfe]        # 2060 <_IO_stdin_used+0x60>
    ;; [rip+0xdfe] == 0x7f7f_ffff
    ;; eflags == 0x202 == [IF]
    1262:       0f 96 c0                setbe  al
    ;; al == 0x0
    1265:       83 f0 01                xor    eax,0x1
    ;; eax == 0x1
    1268:       84 c0                   test   al,al
    ;; eflags 0x202 [IF]
    126a:       74 04                   je     1270 <special_float_comp+0x87>
    {
        result++;
    126c:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (isinf(val_inf_neg))
    1270:       f3 0f 10 45 fc          movss  xmm0,DWORD PTR [rbp-0x4]
    1275:       f3 0f 10 0d d3 0d 00    movss  xmm1,DWORD PTR [rip+0xdd3]        # 2050 <_IO_stdin_used+0x50>
    127c:       00
    127d:       0f 54 c1                andps  xmm0,xmm1
    ;; xmm0 == 0x7f80_0000
    1280:       0f 2e 05 d9 0d 00 00    ucomiss xmm0,DWORD PTR [rip+0xdd9]        # 2060 <_IO_stdin_used+0x60>
    ;; eflags 0x202 [IF]
    1287:       0f 96 c0                setbe  al       ;; set al to 0x1 when <= 0
    ;; al == 0x0
    128a:       83 f0 01                xor    eax,0x1
    ;; eax == 0x1
    128d:       84 c0                   test   al,al    ;; check if == 0
    ;; eflags 0x202 [IF]
    128f:       74 04                   je     1295 <special_float_comp+0xac>
    {
        result++;
    1291:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan == val_nan)
    1295:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    129a:       0f 2e 45 f4             ucomiss xmm0,DWORD PTR [rbp-0xc]
    129e:       7a 0a                   jp     12aa <special_float_comp+0xc1>
    {
        return 0;
    12a0:       b8 00 00 00 00          mov    eax,0x0
    12a5:       e9 cf 00 00 00          jmp    1379 <special_float_comp+0x190>
    }

    if (val_nan != val_nan)
    12aa:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    12af:       0f 2e 45 f4             ucomiss xmm0,DWORD PTR [rbp-0xc]
    12b3:       7b 04                   jnp    12b9 <special_float_comp+0xd0>
    {
        result++;
    12b5:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan > val_zero_pos) {
    12b9:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    12be:       0f 2f 45 ec             comiss xmm0,DWORD PTR [rbp-0x14]
    12c2:       76 0a                   jbe    12ce <special_float_comp+0xe5>
        return 0;
    12c4:       b8 00 00 00 00          mov    eax,0x0
    12c9:       e9 ab 00 00 00          jmp    1379 <special_float_comp+0x190>
    }

    // NaN is not comparable.
    // therefor, everything includes itself compares with NaN is always FALSE.
    if (val_nan > val_inf_pos) {
    12ce:       f3 0f 10 45 f4          movss  xmm0,DWORD PTR [rbp-0xc]
    12d3:       0f 2f 45 f8             comiss xmm0,DWORD PTR [rbp-0x8]
    12d7:       76 0a                   jbe    12e3 <special_float_comp+0xfa>
        return 0;
    12d9:       b8 00 00 00 00          mov    eax,0x0
    12de:       e9 96 00 00 00          jmp    1379 <special_float_comp+0x190>
    }

    if (val_inf_pos != val_inf_neg)
    12e3:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    12e8:       0f 2e 45 fc             ucomiss xmm0,DWORD PTR [rbp-0x4]
    12ec:       7a 0b                   jp     12f9 <special_float_comp+0x110>
    12ee:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    12f3:       0f 2e 45 fc             ucomiss xmm0,DWORD PTR [rbp-0x4]
    12f7:       74 04                   je     12fd <special_float_comp+0x114>
    {
        result++;
    12f9:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (val_inf_pos > val_inf_neg)
    12fd:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    1302:       0f 2f 45 fc             comiss xmm0,DWORD PTR [rbp-0x4]
    1306:       76 04                   jbe    130c <special_float_comp+0x123>
    {
        result++;
    1308:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (val_inf_pos > 1.0)
    130c:       f3 0f 10 45 f8          movss  xmm0,DWORD PTR [rbp-0x8]
    1311:       f3 0f 10 0d 2b 0d 00    movss  xmm1,DWORD PTR [rip+0xd2b]        # 2044 <_IO_stdin_used+0x44>
    1318:       00
    1319:       0f 2f c1                comiss xmm0,xmm1
    131c:       76 04                   jbe    1322 <special_float_comp+0x139>
    {
        result++;
    131e:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (val_inf_neg < -1.0)
    1322:       f3 0f 10 05 1e 0d 00    movss  xmm0,DWORD PTR [rip+0xd1e]        # 2048 <_IO_stdin_used+0x48>
    1329:       00
    132a:       0f 2f 45 fc             comiss xmm0,DWORD PTR [rbp-0x4]
    132e:       76 04                   jbe    1334 <special_float_comp+0x14b>
    {
        result++;
    1330:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    // 0.0 == -0.0
    if (val_zero_pos == val_zero_neg)
    1334:       f3 0f 10 45 ec          movss  xmm0,DWORD PTR [rbp-0x14]
    1339:       0f 2e 45 f0             ucomiss xmm0,DWORD PTR [rbp-0x10]
    133d:       7a 0f                   jp     134e <special_float_comp+0x165>
    133f:       f3 0f 10 45 ec          movss  xmm0,DWORD PTR [rbp-0x14]
    1344:       0f 2e 45 f0             ucomiss xmm0,DWORD PTR [rbp-0x10]
    1348:       75 04                   jne    134e <special_float_comp+0x165>
    {
        result++;
    134a:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (1.0 > val_zero_pos)
    134e:       f3 0f 10 05 ee 0c 00    movss  xmm0,DWORD PTR [rip+0xcee]        # 2044 <_IO_stdin_used+0x44>
    1355:       00
    1356:       0f 2f 45 ec             comiss xmm0,DWORD PTR [rbp-0x14]
    135a:       76 04                   jbe    1360 <special_float_comp+0x177>
    {
        result++;
    135c:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    if (-1.0 < val_zero_neg)
    1360:       f3 0f 10 45 f0          movss  xmm0,DWORD PTR [rbp-0x10]
    1365:       f3 0f 10 0d db 0c 00    movss  xmm1,DWORD PTR [rip+0xcdb]        # 2048 <_IO_stdin_used+0x48>
    136c:       00
    136d:       0f 2f c1                comiss xmm0,xmm1
    1370:       76 04                   jbe    1376 <special_float_comp+0x18d>
    {
        result++;
    1372:       83 45 e8 01             add    DWORD PTR [rbp-0x18],0x1
    }

    return result;
    1376:       8b 45 e8                mov    eax,DWORD PTR [rbp-0x18]
}
    1379:       5d                      pop    rbp
    137a:       c3                      ret
*/

/*
about the instruction 'JP'
--------------------------

> jne is jump if not equal, i.e. jump if the zero flag is not set.
> jp is jump if parity.
>
> ucomisd is defined to compare two doubles. It will indicate that
> they are one of four things: unordered, equal, greater than or less than.
>
> The zero flag is set if the numbers are unordered or equal.
> So the jne avoids the remaining cases of greater than or less than.
>
> Parity is set only if the result is unordered. The jp catches that.
>
> So the two together avoid: unordered, greater than, less than.
> Leaving only the fourth possibility, of equal.

- JPO/JNP Jump if parity odd/Jump if not parity.
- JPE/JP Jump if parity even/Jump if parity.

per:
- Intel 64 and IA-32 Architectures Software Developer’s Manual ->
- Volume 2 ->
- Chapter 3 Instruction Set Reference, A-L ->
- 3.3 Instructions (A-L) ->
- Jcc—Jump if Condition Is Met

about the instructions 'ucomiss' and 'comiss'
---------------------------------------------

The UCOMISS instruction differs from the COMISS instruction in that it signals a SIMD floating-point invalid opera-
tion exception (#I) only if a source operand is an SNaN. The COMISS instruction signals an invalid operation excep-
tion when a source operand is either a QNaN or SNaN.

per:
- Intel 64 and IA-32 Architectures Software Developer’s Manual ->
- Volume 2 ->
- Chapter 4 Instruction Set Reference, M-U ->
- 4.3 Instructions (M-U) ->
- UCOMISS—Unordered Compare Scalar Single Precision Floating-Point Values and Set EFLAGS

*/