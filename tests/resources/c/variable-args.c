/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdarg.h>
#include <stdio.h>

int sum_int(int, ...);
double sum_float(int, ...);

int main(void)
{
    /*
        1151:       ba 0d 00 00 00          mov    edx,0xd
        1156:       be 0b 00 00 00          mov    esi,0xb

        ;; numbers of args
        115b:       bf 02 00 00 00          mov    edi,0x2

        ;; number zero is used to mark the type of last arg is int
        1160:       b8 00 00 00 00          mov    eax,0x0

        1165:       e8 72 00 00 00          call   11dc <sum_int>
        116a:       89 45 f8                mov    DWORD PTR [rbp-0x8],eax
    */
    int i = sum_int(2, 11, 13);

    /*
        116d:       f2 0f 10 0d a3 0e 00    movsd  xmm1,QWORD PTR [rip+0xea3]        # 2018 <_IO_stdin_used+0x18>
        1174:       00
        1175:       f2 0f 10 05 a3 0e 00    movsd  xmm0,QWORD PTR [rip+0xea3]        # 2020 <_IO_stdin_used+0x20>
        117c:       00
        117d:       48 8b 05 a4 0e 00 00    mov    rax,QWORD PTR [rip+0xea4]        # 2028 <_IO_stdin_used+0x28>
        1184:       66 0f 28 d1             movapd xmm2,xmm1
        1188:       66 0f 28 c8             movapd xmm1,xmm0
        118c:       66 48 0f 6e c0          movq   xmm0,rax

        ;; numbers of args
        1191:       bf 03 00 00 00          mov    edi,0x3

        ;; a non-zero number is used to mark the type of last arg is double
        1196:       b8 03 00 00 00          mov    eax,0x3

        119b:       e8 65 01 00 00          call   1305 <sum_float>
    */
    float j = sum_float(3, 1.1, 1.3, 1.7);
    printf("%d %.1f\n", i, j);

    return 0;
}

int sum_int(int num_args, ...)
{
    /*
        11dc:       55                      push   rbp
        11dd:       48 89 e5                mov    rbp,rsp
        11e0:       48 81 ec f0 00 00 00    sub    rsp,0xf0
        11e7:       89 bd 1c ff ff ff       mov    DWORD PTR [rbp-0xe4],edi
        11ed:       48 89 b5 58 ff ff ff    mov    QWORD PTR [rbp-0xa8],rsi
        11f4:       48 89 95 60 ff ff ff    mov    QWORD PTR [rbp-0xa0],rdx
        11fb:       48 89 8d 68 ff ff ff    mov    QWORD PTR [rbp-0x98],rcx
        1202:       4c 89 85 70 ff ff ff    mov    QWORD PTR [rbp-0x90],r8
        1209:       4c 89 8d 78 ff ff ff    mov    QWORD PTR [rbp-0x88],r9

        ;; is zero? check the type of last arg
        1210:       84 c0                   test   al,al

        1212:       74 20                   je     1234 <sum_int+0x58>
        1214:       0f 29 45 80             movaps XMMWORD PTR [rbp-0x80],xmm0
        1218:       0f 29 4d 90             movaps XMMWORD PTR [rbp-0x70],xmm1
        121c:       0f 29 55 a0             movaps XMMWORD PTR [rbp-0x60],xmm2
        1220:       0f 29 5d b0             movaps XMMWORD PTR [rbp-0x50],xmm3
        1224:       0f 29 65 c0             movaps XMMWORD PTR [rbp-0x40],xmm4
        1228:       0f 29 6d d0             movaps XMMWORD PTR [rbp-0x30],xmm5
        122c:       0f 29 75 e0             movaps XMMWORD PTR [rbp-0x20],xmm6
        1230:       0f 29 7d f0             movaps XMMWORD PTR [rbp-0x10],xmm7
    */
    va_list ap;

    /*
     void va_start(va_list ap, last_arg)

     The last_arg is the last known fixed argument being passed to the function
     i.e. the argument before the ellipsis.

     `last_arg` arg is used to get the start position of a variable parameter
     (all parameters have been copied onto the stack, so only the address of
     the parameter is needed to know which parameter to start with)
     */
    va_start(ap, num_args);

    /*
     The number of arguments needs to be passed in some way,
     for example, the current example gets it directly from the `num_args` argument.
     The `printf` function gets it by counting the placeholders
     in the `format` argument.
     */
    int sum = 0;
    for (int i = 0; i < num_args; i++)
    {
        /*
         type va_arg(va_list arg_ptr, type)
         */
        sum += va_arg(ap, int);
    }

    /*
     void va_end(va_list arg_ptr)
     */
    va_end(ap);

    return sum;
}

double sum_float(int num_args, ...)
{
    va_list ap;
    va_start(ap, num_args);

    double sum = 0;
    for (int i = 0; i < num_args; i++)
    {
        sum += va_arg(ap, double);
    }

    va_end(ap);
    return sum;
}