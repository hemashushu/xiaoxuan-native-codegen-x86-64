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
    $ objdump -h extcall-rs.o

    extcall-rs.o:     file format elf64-x86-64

    Sections:
    Idx Name          Size      VMA               LMA               File off  Algn
    0 .text.main    00000017  0000000000000000  0000000000000000  00000040  2**0
                    CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
    1 .rodata       0000000e  0000000000000000  0000000000000000  00000057  2**0
                    CONTENTS, ALLOC, LOAD, READONLY, DATA
     */

    /*
    $ objdump -t extcall-rs.o
    $ readelf -s extcall-rs.o

    Symbol table '.symtab' contains 5 entries:
    Num:    Value          Size Type    Bind   Vis      Ndx Name
        0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
        1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS hello.c
        2: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 .rodata
        3: 0000000000000000    23 FUNC    GLOBAL HIDDEN     1 main
        4: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
     */

    /*
    $ objdump -r extcall-rs.o
    $ readelf -r extcall-rs.o

    Relocation section '.rela.text.main' at offset 0xf8 contains 2 entries:
    Offset          Info           Type           Sym. Value    Sym. Name + Addend
    000000000007  000200000002 R_X86_64_PC32     0000000000000000 .rodata - 4
    00000000000c  000400000004 R_X86_64_PLT32    0000000000000000 puts - 4
    */

    // function `main`
    let mut main_data = Vec::new();

    // sub $0x28, %rsp
    main_data.extend_from_slice(&[0x48, 0x83, 0xec, 0x28]);

    // lea 0x0(%rip), %rdi
    main_data.extend_from_slice(&[0x48, 0x8d, 0x3d, 0x00, 0x00, 0x00, 0x00]);

    // R_X86_64_PC32 .rodata-0x4
    let s_reloc_offset = main_data.len() - 4;   // the address of the placehold

    // because the final address is related to the $rip (the address of the next instruction),
    // therefor, it is need to be subtracted 4 (the length of i32)
    let s_reloc_addend = -4;

    let s_reloc_flags = RelocationFlags::Generic {
        kind: RelocationKind::Relative,
        encoding: RelocationEncoding::Generic,
        size: 32,
    };

    // call 14 <main+0x14>
    main_data.extend_from_slice(&[0xe8, 0x00, 0x00, 0x00, 0x00]);

    // R_X86_64_PLT32 puts-0x4
    let puts_reloc_offset = main_data.len() - 4;
    let puts_reloc_addend = -4;
    let puts_reloc_flags = RelocationFlags::Generic {
        kind: RelocationKind::PltRelative,
        encoding: RelocationEncoding::X86Branch,
        size: 32,
    };

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
    let s_offset = obj.append_section_data(rodata_section, b"Hello, world!\0", 1);

    // Relocation for the string constant.
    obj.add_relocation(
        main_section,
        Relocation {
            offset: s_reloc_offset as u64,
            symbol: rodata_symbol,
            addend: s_offset as i64 + s_reloc_addend,
            flags: s_reloc_flags,
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
    // invoke command `$ gcc -o extcall-rs.elf extcall-rs.o` to link the object file
    // to an ELF file.
}
