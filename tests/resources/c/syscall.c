/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(void)
{
    const char *s = "hello\n";
    write(STDOUT_FILENO, s, strlen(s));
    exit(EXIT_SUCCESS);

    /*
    $ objdump -M intel -d base.elf

    0000000000001159 <main>:
        1159:       55                      push   rbp
        115a:       48 89 e5                mov    rbp,rsp
        115d:       48 83 ec 10             sub    rsp,0x10
        1161:       48 8d 05 9c 0e 00 00    lea    rax,[rip+0xe9c]        # 2004 <_IO_stdin_used+0x4>
        1168:       48 89 45 f8             mov    QWORD PTR [rbp-0x8],rax
        116c:       48 8b 45 f8             mov    rax,QWORD PTR [rbp-0x8]
        1170:       48 89 c7                mov    rdi,rax
        1173:       e8 c8 fe ff ff          call   1040 <strlen@plt>

        ;; len
        1178:       48 89 c2                mov    rdx,rax

        ;; string address
        117b:       48 8b 45 f8             mov    rax,QWORD PTR [rbp-0x8]
        117f:       48 89 c6                mov    rsi,rax

        ;; number of stdout
        1182:       bf 01 00 00 00          mov    edi,0x1

        ;; libc wrapper
        1187:       e8 a4 fe ff ff          call   1030 <write@plt>

        118c:       bf 00 00 00 00          mov    edi,0x0
        1191:       e8 ba fe ff ff          call   1050 <exit@plt>
    */
}