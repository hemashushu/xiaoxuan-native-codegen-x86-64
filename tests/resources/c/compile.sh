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

# compile
gcc -Wall -g -c -o control-flow.o control-flow.c
gcc -Wall -g -c -o variable-args.o variable-args.c
gcc -Wall -g -c -o struct.o struct.c
gcc -Wall -g -c -o call.o call.c
gcc -Wall -g -c -o syscall.o syscall.c
gcc -Wall -g -c -o extcall.o extcall.c
gcc -Wall -g -c -o float-conversion.o float-conversion.c
gcc -Wall -g -c -o float-branch.o float-branch.c

# link
gcc -o control-flow.elf control-flow.o
gcc -o variable-args.elf variable-args.o
gcc -o struct.elf struct.o
gcc -o call.elf call.o
gcc -o syscall.elf syscall.o
gcc -o extcall.elf extcall.o
gcc -o float-conversion.elf float-conversion.o
gcc -o float-branch.elf float-branch.o

# alternative linking
#
# ld \
#     -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
#     -pie \
#     -o syscall.elf \
#     /usr/lib/Scrt1.o \
#     /usr/lib/crti.o \
#     -L/lib/ \
#     -L/usr/lib \
#     syscall.o \
#     -lc \
#     /usr/lib/crtn.o

# generate the LLVM IR for control flow
clang -S -emit-llvm control-flow.c