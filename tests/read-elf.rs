// Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
//
// This Source Code Form is subject to the terms of
// the Mozilla Public License version 2.0 and additional exceptions,
// more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

use std::fs;

use object::{Object, ObjectSection};

#[test]
fn test_print_sections() {
    let binary = fs::read("tests/resources/c/base.elf").unwrap();
    let elf_file = object::File::parse(&*binary).unwrap();
    for section in elf_file.sections() {
        println!("section: {}", section.name().unwrap());
    }
}
