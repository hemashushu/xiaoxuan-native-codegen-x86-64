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
gcc -Wall -g -c -o base.o base.c
gcc -Wall -g -c -o extcall.o extcall.c

# link
gcc -o base.elf base.o
gcc -o extcall.elf extcall.o

# alternative linking
#
# ld \
#     -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
#     -pie \
#     -o base.elf \
#     /usr/lib/Scrt1.o \
#     /usr/lib/crti.o \
#     -L/lib/ \
#     -L/usr/lib \
#     base.o \
#     -lc \
#     /usr/lib/crtn.o
