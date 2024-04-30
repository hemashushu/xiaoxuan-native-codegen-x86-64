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
yasm -g dwarf2 -f elf64 -o ins-mov.o ins-mov.S
yasm -g dwarf2 -f elf64 -o ins-arithmetic.o ins-arithmetic.S
yasm -g dwarf2 -f elf64 -o ins-comparison.o ins-comparison.S
yasm -g dwarf2 -f elf64 -o ins-branch.o ins-branch.S

# link
ld -g -o ins-mov.elf ins-mov.o
ld -g -o ins-arithmetic.elf ins-arithmetic.o
ld -g -o ins-comparison.elf ins-comparison.o
ld -g -o ins-branch.elf ins-branch.o
