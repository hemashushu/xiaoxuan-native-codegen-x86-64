/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>

void if_statement(int a)
{
    int b = 10;
    if (a > b)
    {
        b = 20;
    }

    /*
    $ objdump -M intel -S -d control-flow.o

    void if_statement(int a)
    {
    0:   55                      push   rbp
    1:   48 89 e5                mov    rbp,rsp
    4:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int b = 10;
    7:   c7 45 fc 0a 00 00 00    mov    DWORD PTR [rbp-0x4],0xa
        if (a > b)
    e:   8b 45 ec                mov    eax,DWORD PTR [rbp-0x14]
    11:   3b 45 fc                cmp    eax,DWORD PTR [rbp-0x4]
    14:   7e 07                   jle    1d <if_statement+0x1d>    ---\
        {                                                             |
            b = 20;                                                   |
    16:   c7 45 fc 14 00 00 00    mov    DWORD PTR [rbp-0x4],0x14     |
        }                                                             |
    }                                                                 |
    1d:   90                      nop                              <--/ append inst 'nop' before epilogue
    1e:   5d                      pop    rbp
    1f:   c3                      ret
    */
}

void if_else(int a)
{
    int b = 10;
    if (a > b)
    {
        b = 20;
    }
    else
    {
        b = 30;
    }

    /*
    20:   55                      push   rbp
    21:   48 89 e5                mov    rbp,rsp
    24:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int b = 10;
    27:   c7 45 fc 0a 00 00 00    mov    DWORD PTR [rbp-0x4],0xa
        if (a > b)
    2e:   8b 45 ec                mov    eax,DWORD PTR [rbp-0x14]
    31:   3b 45 fc                cmp    eax,DWORD PTR [rbp-0x4]
    34:   7e 09                   jle    3f <if_else+0x1f>       ----\
        {                                                            |
            b = 20;                                                  |
    36:   c7 45 fc 14 00 00 00    mov    DWORD PTR [rbp-0x4],0x14    |
    3d:   eb 07                   jmp    46 <if_else+0x26>       ----|--\
        }                                                            |  |
        else                                                         |  |
        {                                                            |  |
            b = 30;                                                  |  |
    3f:   c7 45 fc 1e 00 00 00    mov    DWORD PTR [rbp-0x4],0x1e <--/  |
    }                                                                   |
    46:   90                      nop                             <-----/ append inst 'nop' before epilogue
    47:   5d                      pop    rbp
    48:   c3                      ret
    */
}

int if_else_if(int a)
{
    int b = 0;
    if (a > 30)
    {
        b = 3;
    }
    else if (a > 20)
    {
        b = 2;
    }
    else
    {
        b = 1;
    }

    return b;

    /*
    49:   55                      push   rbp
    4a:   48 89 e5                mov    rbp,rsp
    4d:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int b = 0;
    50:   c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0
        if (a > 30)
    57:   83 7d ec 1e             cmp    DWORD PTR [rbp-0x14],0x1e
    5b:   7e 09                   jle    66 <if_else_if+0x1d>       ----\ jump to else if
        {                                                               |
            b = 3;                                                      |
    5d:   c7 45 fc 03 00 00 00    mov    DWORD PTR [rbp-0x4],0x3        |
    64:   eb 16                   jmp    7c <if_else_if+0x33>       ----|---------------\
        }                                                               |               |
        else if (a > 20)                                                |               |
    66:   83 7d ec 14             cmp    DWORD PTR [rbp-0x14],0x14  <---/               |
    6a:   7e 09                   jle    75 <if_else_if+0x2c>       ----\ jump to else  |
        {                                                               |               |
            b = 2;                                                      |               |
    6c:   c7 45 fc 02 00 00 00    mov    DWORD PTR [rbp-0x4],0x2        |               |
    73:   eb 07                   jmp    7c <if_else_if+0x33>       ----|---------------|
        }                                                               |               |
        else                                                            |               |
        {                                                               |               |
            b = 1;                                                      |               |
    75:   c7 45 fc 01 00 00 00    mov    DWORD PTR [rbp-0x4],0x1    <---/               |
        }                                                                               |
                                                                                        |
        return b;                                                                       |
    7c:   8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]    <-------------------/ jump to the last inst that before epilogue
    }
    7f:   5d                      pop    rbp
    80:   c3                      ret

    */
}

void while_statement(int a)
{
    int b = 0;
    while (b < a)
    {
        b++;
    }

    /*
    81:   55                      push   rbp
    82:   48 89 e5                mov    rbp,rsp
    85:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int b = 0;
    88:   c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0
        while (b < a)
    8f:   eb 04                   jmp    95 <while_statement+0x14> ---------------------\ jump to comparison
        {                                                                               | only exists on statement `while(...) {...}`
            b++;                                                                        |
    91:   83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1   <---\                |
        while (b < a)                                                  |                |
    95:   8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]   <---|----------------/
    98:   3b 45 ec                cmp    eax,DWORD PTR [rbp-0x14]      |
    9b:   7c f4                   jl     91 <while_statement+0x10> ----/ jump if true
        }
    }
    9d:   90                      nop
    9e:   90                      nop
    9f:   5d                      pop    rbp
    a0:   c3                      ret
    */
}

void do_while(int a)
{
    int b = 0;
    do
    {
        b++;
    } while (b < a);

    /*
    a1:   55                      push   rbp
    a2:   48 89 e5                mov    rbp,rsp
    a5:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int b = 0;
    a8:   c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0
        do
        {
            b++;
    af:   83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1  <---\
        } while (b < a);                                              |
    b3:   8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]      |
    b6:   3b 45 ec                cmp    eax,DWORD PTR [rbp-0x14]     |
    b9:   7c f4                   jl     af <do_while+0xe>        ----/ jump if true
    }
    bb:   90                      nop
    bc:   90                      nop
    bd:   5d                      pop    rbp
    be:   c3                      ret
    */
}

void for_next(int a)
{
    int c = 0;
    for (int b = 0; b < a; b++)
    {
        c += 1;
    }

    /*
    bf:   55                      push   rbp
    c0:   48 89 e5                mov    rbp,rsp
    c3:   89 7d ec                mov    DWORD PTR [rbp-0x14],edi
        int c = 0;
    c6:   c7 45 f8 00 00 00 00    mov    DWORD PTR [rbp-0x8],0x0    <--- local var 'c'
        for (int b = 0; b < a; b++)
    cd:   c7 45 fc 00 00 00 00    mov    DWORD PTR [rbp-0x4],0x0    <--- local var 'b'
    d4:   eb 08                   jmp    de <for_next+0x1f>         ---\ jump to comparison
        {                                                              |
            c += 1;                                                    |
    d6:   83 45 f8 01             add    DWORD PTR [rbp-0x8],0x1    <--|---\   body start
        for (int b = 0; b < a; b++)                                    |   |
    da:   83 45 fc 01             add    DWORD PTR [rbp-0x4],0x1    <==|===|== increament start
    de:   8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]    <--/   |
    e1:   3b 45 ec                cmp    eax,DWORD PTR [rbp-0x14]          |
    e4:   7c f0                   jl     d6 <for_next+0x17>         -------/ jump to body if true
        }
    }
    e6:   90                      nop
    e7:   90                      nop
    e8:   5d                      pop    rbp
    e9:   c3                      ret
    */
}

int main(void)
{
    if_statement(13);
    if_else(17);
    if_else_if(19);
    while_statement(2);
    do_while(3);
    for_next(4);
    return 0;

    /*
    ea:   55                      push   rbp
    eb:   48 89 e5                mov    rbp,rsp
        if_statement(13);
    ee:   bf 0d 00 00 00          mov    edi,0xd
    f3:   e8 00 00 00 00          call   f8 <main+0xe>
        if_else(17);
    f8:   bf 11 00 00 00          mov    edi,0x11
    fd:   e8 00 00 00 00          call   102 <main+0x18>
        if_else_if(19);
    102:   bf 13 00 00 00          mov    edi,0x13
    107:   e8 00 00 00 00          call   10c <main+0x22>
        while_statement(2);
    10c:   bf 02 00 00 00          mov    edi,0x2
    111:   e8 00 00 00 00          call   116 <main+0x2c>
        do_while(3);
    116:   bf 03 00 00 00          mov    edi,0x3
    11b:   e8 00 00 00 00          call   120 <main+0x36>
        for_next(4);
    120:   bf 04 00 00 00          mov    edi,0x4
    125:   e8 00 00 00 00          call   12a <main+0x40>
        return 0;
    12a:   b8 00 00 00 00          mov    eax,0x0
    12f:   5d                      pop    rbp
    130:   c3                      ret
    */
}