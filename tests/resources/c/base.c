/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>
#include <stdlib.h>

int j = 13;

int main(void)
{
    int i = 11;
    int k = i + j;
    return k;

    /*
    $ objdump -S -M intel -d base.elf
    $ objdump -M intel -d base.elf

    0000000000001119 <main>:
        1119:       55                      push   rbp
        111a:       48 89 e5                mov    rbp,rsp
        111d:       c7 45 f8 0b 00 00 00    mov    DWORD PTR [rbp-0x8],0xb
        1124:       8b 15 e6 2e 00 00       mov    edx,DWORD PTR [rip+0x2ee6]        # 4010 <j>
        112a:       8b 45 f8                mov    eax,DWORD PTR [rbp-0x8]
        112d:       01 d0                   add    eax,edx
        112f:       89 45 fc                mov    DWORD PTR [rbp-0x4],eax
        1132:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
        1135:       5d                      pop    rbp
        1136:       c3                      ret
    */
}