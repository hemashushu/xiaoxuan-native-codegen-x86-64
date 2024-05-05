# Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
#
# This Source Code Form is subject to the terms of
# the Mozilla Public License version 2.0 and additional exceptions,
# more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

#!/bin/bash
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "Please run on the x86_64"
    exit 1
fi

# The -g dwarf226 option is used to inform the assembler to include debugging
# information in the final object file.
# https://en.wikipedia.org/wiki/DWARF
#
# The list file shows the line number, the relative address,
# the machine language version of the instruction
# (including variable references), and the original source line.
# The list file can be useful when debugging.
#
# yasm -g dwarf2 -f elf64 -l base.lst -o base.o base.S

# assemble
yasm -g dwarf2 -f elf64 -o mov.o mov.S
yasm -g dwarf2 -f elf64 -o memory.o memory.S
yasm -g dwarf2 -f elf64 -o conversion.o conversion.S
yasm -g dwarf2 -f elf64 -o arithmetic.o arithmetic.S
yasm -g dwarf2 -f elf64 -o comparison.o comparison.S
yasm -g dwarf2 -f elf64 -o branch.o branch.S
yasm -g dwarf2 -f elf64 -o stack.o stack.S
yasm -g dwarf2 -f elf64 -o call.o call.S
yasm -g dwarf2 -f elf64 -o syscall.o syscall.S

# link
ld -g -o mov.elf mov.o
ld -g -o memory.elf memory.o
ld -g -o conversion.elf conversion.o
ld -g -o arithmetic.elf arithmetic.o
ld -g -o comparison.elf comparison.o
ld -g -o branch.elf branch.o
ld -g -o stack.elf stack.o
ld -g -o call.elf call.o
ld -g -o syscall.elf syscall.o

