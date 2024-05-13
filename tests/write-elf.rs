// Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
//
// This Source Code Form is subject to the terms of
// the Mozilla Public License version 2.0 and additional exceptions,
// more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

use object::{
    write::{Object, Relocation, StandardSection, Symbol, SymbolSection},
    Architecture, BinaryFormat, Endianness, RelocationEncoding, RelocationFlags, RelocationKind,
    SymbolFlags, SymbolKind, SymbolScope,
};

#[test]
fn test_write_extcall() {
    // equivalent C code:
    // int main() {
    //     puts("Hello, World!");
    //     return 0;
    // }

    // refer to:
    // https://github.com/gimli-rs/object/blob/master/crates/examples/src/bin/simple_write.rs

    let mut obj = Object::new(
        BinaryFormat::native_object(),
        Architecture::X86_64,
        Endianness::Little,
    );

    // add a file symbol (STT_FILE or equivalent)
    obj.add_file_symbol(b"hello.c".into());

    /*
    $ objdump -h extcall.o

    extcall.o:     file format elf64-x86-64

    Sections:
    Idx Name          Size      VMA               LMA               File off  Algn
    0 .text.main    00000017  0000000000000000  0000000000000000  00000040  2**0
                    CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
    1 .rodata       0000000e  0000000000000000  0000000000000000  00000057  2**0
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
     */

    /*
    $ objdump -t extcall.o
    $ readelf -s extcall.o

    Symbol table '.symtab' contains 5 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name
        0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
        1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS hello.c
        2: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 .rodata
        3: 0000000000000000    23 FUNC    GLOBAL HIDDEN     1 main
        4: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
     */

    /*
    $ objdump -r extcall.o
    $ readelf -r extcall.o

    Relocation section '.rela.text.main' at offset 0xf8 contains 2 entries:
    Offset          Info           Type           Sym. Value    Sym. Name + Addend
    000000000007  000200000002 R_X86_64_PC32     0000000000000000 .rodata - 4
    00000000000c  000400000004 R_X86_64_PLT32    0000000000000000 puts - 4
    ^
    |
    \ the offset of the placehold (relative to the current section, e.g. '.text')
    $ objdump -M intel -d extcall.o
    0000000000000000 <main>:
     0:   48 83 ec 28             sub    rsp,0x28
     4:   48 8d 3d 00 00 00 00    lea    rdi,[rip+0x0]        # b <main+0xb>
                   ^__ OFFSET = 0x7
     b:   e8 00 00 00 00          call   10 <main+0x10>
             ^__ OFFSET = 0xc
    10:   31 c0                   xor    eax,eax
    12:   48 83 c4 28             add    rsp,0x28
    16:   c3

    */

    /*
    $ objdump -h extcall.elf

    extcall.elf:     file format elf64-x86-64

    Sections:
    Idx Name          Size      VMA               LMA               File off  Algn
    0 .interp       0000001c  0000000000000318  0000000000000318  00000318  2**0
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    1 .note.gnu.property 00000020  0000000000000338  0000000000000338  00000338  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    2 .note.gnu.build-id 00000024  0000000000000358  0000000000000358  00000358  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    3 .note.ABI-tag 00000020  000000000000037c  000000000000037c  0000037c  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    4 .gnu.hash     0000001c  00000000000003a0  00000000000003a0  000003a0  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    5 .dynsym       000000a8  00000000000003c0  00000000000003c0  000003c0  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    6 .dynstr       0000008d  0000000000000468  0000000000000468  00000468  2**0
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    7 .gnu.version  0000000e  00000000000004f6  00000000000004f6  000004f6  2**1
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    8 .gnu.version_r 00000030  0000000000000508  0000000000000508  00000508  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    9 .rela.dyn     000000c0  0000000000000538  0000000000000538  00000538  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    10 .rela.plt     00000018  00000000000005f8  00000000000005f8  000005f8  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    11 .init         0000001b  0000000000001000  0000000000001000  00001000  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
    12 .plt          00000020  0000000000001020  0000000000001020  00001020  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
    13 .text         00000110  0000000000001040  0000000000001040  00001040  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
    14 .fini         0000000d  0000000000001150  0000000000001150  00001150  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
    15 .rodata       00000012  0000000000002000  0000000000002000  00002000  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    16 .eh_frame_hdr 0000001c  0000000000002014  0000000000002014  00002014  2**2
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    17 .eh_frame     00000058  0000000000002030  0000000000002030  00002030  2**3
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
    18 .init_array   00000008  0000000000003dd0  0000000000003dd0  00002dd0  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    19 .fini_array   00000008  0000000000003dd8  0000000000003dd8  00002dd8  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    20 .dynamic      000001e0  0000000000003de0  0000000000003de0  00002de0  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    21 .got          00000028  0000000000003fc0  0000000000003fc0  00002fc0  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    22 .got.plt      00000020  0000000000003fe8  0000000000003fe8  00002fe8  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    23 .data         00000010  0000000000004008  0000000000004008  00003008  2**3
                    CONTENTS, ALLOC, LOAD, DATA
    24 .bss          00000008  0000000000004018  0000000000004018  00003018  2**0
                    ALLOC
    25 .comment      0000001b  0000000000000000  0000000000000000  00003018  2**0
                    CONTENTS, READONLY
     */

    /*
    $ objdump -M intel -d extcall.elf

    0000000000001139 <main>:
    1139:       48 83 ec 28             sub    rsp,0x28
    113d:       48 8d 3d c0 0e 00 00    lea    rdi,[rip+0xec0]        # 2004 <_IO_stdin_used+0x4>
    1144:       e8 e7 fe ff ff          call   1030 <puts@plt>
    1149:       31 c0                   xor    eax,eax
    114b:       48 83 c4 28             add    rsp,0x28
    114f:       c3
     */

    /*
    lea    rdi,[rip+0xec0]
                      ^
                      |--- 0x0ec0 = .rodata (0x2000) - ($rip(0x1144) - addend (0x4)) = 0xebc + 4 => 0x0ec0

    call   1030 <puts@plt> <-- trampoline function
           ^
           |            /--- note that the addresses are continuous
           |            v
           |        0000000000001020 <puts@plt-0x10>:
           |            1020:       ff 35 ca 2f 00 00       push   QWORD PTR [rip+0x2fca] <-\    # 3ff0 <_GLOBAL_OFFSET_TABLE_+0x8>
           |            1026:       ff 25 cc 2f 00 00       jmp    QWORD PTR [rip+0x2fcc]   |    # 3ff8 <_GLOBAL_OFFSET_TABLE_+0x10> -> jump to glibc to load the address of "puts"
           |            102c:       0f 1f 40 00             nop    DWORD PTR [rax+0x0]      |
           \--->    0000000000001030 <puts@plt>:                                            |
                        1030:       ff 25 ca 2f 00 00       jmp    QWORD PTR [rip+0x2fca]   |    # 4000 puts@got.plt
                        1036:       68 00 00 00 00          push   0x0                      |         |
                        103b:       e9 e0 ff ff ff          jmp    1020 <_init+0x20> -------/         |
                                                                                                      |
                    22 .got.plt      00000020  0000000000003fe8  0000000000003fe8  00002fe8  2**3     |
                                     CONTENTS, ALLOC, LOAD, DATA                                      |
                    $ objdump -s -j .got.plt extcall.elf                                              |
                                                                                                      |
                    extcall.elf:     file format elf64-x86-64                                         |
                                                                                                      |
                    Contents of section .got.plt:                                                     |
                    3fe8 e03d0000 00000000 00000000 00000000  .=..............                        |
                    3ff8 00000000 00000000 36100000 00000000  ........6.......                        | 0x1036
                                           ^__________________________________________________________/

                                           ^___ after first call, the address of "puts@GLIBC_2.2.5" (e.g. 0x00007ffff7dfca60) is written. // $ objdump -R extcall.elf


     */

    /*
    1144:       e8 e7 fe ff ff          call   1030 <puts@plt>
                   -----
                   ^___  = $rip(0x1149) - 4 - 0x1030(puts@plt) = 0x01_15
     */

    /*
    ---- memory begin ----
    - .text
    - .rodata
    - .data
    - .bss
    ---- memory high ----
     */

    /*
    - .plt: the trampoline functions
    - .got.plt: the address of the dynamic linking functions
    - .got: the address of global/external data
     */

    // function `main`
    let mut main_data = Vec::new();

    // sub $0x28, %rsp
    main_data.extend_from_slice(&[0x48, 0x83, 0xec, 0x28]);

    // lea 0x0(%rip), %rdi
    main_data.extend_from_slice(&[0x48, 0x8d, 0x3d, 0x00, 0x00, 0x00, 0x00]);

    // R_X86_64_PC32 .rodata-0x4
    let msg_reloc_offset = main_data.len() - 4;   // the address of the placehold
    // because the final address is related to the $rip (the address of the next instruction),
    // therefor, it is need to be subtracted 4 (the length of i32)
    let msg_reloc_addend = -4;

    // call 14 <main+0x14>
    main_data.extend_from_slice(&[0xe8, 0x00, 0x00, 0x00, 0x00]);

    // R_X86_64_PLT32 puts-0x4
    let puts_reloc_offset = main_data.len() - 4;
    let puts_reloc_addend = -4;

    // xor %eax, %eax
    main_data.extend_from_slice(&[0x31, 0xc0]);

    // add $0x28, %rsp
    main_data.extend_from_slice(&[0x48, 0x83, 0xc4, 0x28]);

    // ret
    main_data.extend_from_slice(&[0xc3]);

    // Add the main function in its own subsection (equivalent to -ffunction-sections).
    let (main_section, main_offset) =
        obj.add_subsection(StandardSection::Text, b"main", &main_data, 1);

    // Add a globally visible symbol for the main function.
    obj.add_symbol(Symbol {
        name: b"main".into(),
        value: main_offset,
        size: main_data.len() as u64,
        kind: SymbolKind::Text,
        scope: SymbolScope::Linkage,
        weak: false,
        section: SymbolSection::Section(main_section),
        flags: SymbolFlags::None,
    });

    // Add a read only string constant for the puts argument.
    // We don't create a symbol for the constant, but instead refer to it by
    // the section symbol and section offset.
    let rodata_section = obj.section_id(StandardSection::ReadOnlyData);
    let rodata_symbol = obj.section_symbol(rodata_section);
    let msg_offset = obj.append_section_data(rodata_section, b"Hello, world!\0", 1);

    let msg_reloc_flags = RelocationFlags::Generic {
        kind: RelocationKind::Relative,
        encoding: RelocationEncoding::Generic,
        size: 32,
    };

    // Relocation for the string constant.
    obj.add_relocation(
        main_section,
        Relocation {
            offset: msg_reloc_offset as u64,
            symbol: rodata_symbol,
            addend: msg_offset as i64 + msg_reloc_addend,
            flags: msg_reloc_flags,
        },
    )
    .unwrap();

    // External symbol for puts.
    let puts_symbol = obj.add_symbol(Symbol {
        name: b"puts".into(),
        value: 0,
        size: 0,
        kind: SymbolKind::Text,
        scope: SymbolScope::Dynamic,
        weak: false,
        section: SymbolSection::Undefined,
        flags: SymbolFlags::None,
    });

    let puts_reloc_flags = RelocationFlags::Generic {
        kind: RelocationKind::PltRelative,
        encoding: RelocationEncoding::X86Branch,
        size: 32,
    };

    // Relocation for the call to puts.
    obj.add_relocation(
        main_section,
        Relocation {
            offset: puts_reloc_offset as u64,
            symbol: puts_symbol,
            addend: puts_reloc_addend,
            flags: puts_reloc_flags,
        },
    )
    .unwrap();

    // Finally, write the object file.
    let file = std::fs::File::create("tests/resources/codegen/extcall.o").unwrap();
    obj.write_stream(file).unwrap();

    // to run the target,
    // invoke command:
    // `$ gcc -o extcall.elf extcall.o`
    // to link the object file to an ELF executable file.
}
