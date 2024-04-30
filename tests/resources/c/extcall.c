/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    puts("Hello");
    puts("World");
    return EXIT_SUCCESS;

    /*
    $ objdump -M intel -d extcall.o

    Disassembly of section .text:

    0000000000000000 <main>:
    0:   55                      push   rbp
    1:   48 89 e5                mov    rbp,rsp
    4:   48 8d 05 00 00 00 00    lea    rax,[rip+0x0]        # b <main+0xb>
    b:   48 89 c7                mov    rdi,rax
    e:   e8 00 00 00 00          call   13 <main+0x13>
    13:   48 8d 05 00 00 00 00    lea    rax,[rip+0x0]        # 1a <main+0x1a>
    1a:   48 89 c7                mov    rdi,rax
    1d:   e8 00 00 00 00          call   22 <main+0x22>
    22:   b8 00 00 00 00          mov    eax,0x0
    27:   5d                      pop    rbp
    28:   c3                      ret
    */

    /*
    $ objdump -s -j .rodata extcall.o

    Contents of section .rodata:
     0000 48656c6c 6f00           Hello.
     0006 576f 726c6400           World.
    */

    /*
    $ objdump -h extcall.o

    Sections:
    Idx Name          Size      VMA               LMA               File off  Algn
    0 .text         00000029  0000000000000000  0000000000000000  00000040  2**0
                    CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
    3 .rodata       0000000c  0000000000000000  0000000000000000  00000069  2**0
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    */

    /*
    $ objdump -r extcall.o
    $ readelf -r extcall.o

    Relocation section '.rela.text' at offset 0x1a8 contains 4 entries:
    Offset          Info           Type           Sym. Value    Sym. Name + Addend
    000000000007  000300000002 R_X86_64_PC32     0000000000000000 .rodata - 4
    00000000000f  000500000004 R_X86_64_PLT32    0000000000000000 puts - 4
    000000000016  000300000002 R_X86_64_PC32     0000000000000000 .rodata + 2
    00000000001e  000500000004 R_X86_64_PLT32    0000000000000000 puts - 4
    */

    /*
    $ objdump -t extcall.o
    $ readelf -s extcall.o

    Symbol table '.symtab' contains 6 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name
        0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
        1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS extcall.c
        2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 .text
        3: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 .rodata
        4: 0000000000000000    41 FUNC    GLOBAL DEFAULT    1 main
        5: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
    */
}