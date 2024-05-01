/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

#include <stdio.h>

struct result
{
    int i;
    long j;
    int k;
};

void caller(struct result *r)
{
    int i = 11;
    long j = 13;
    int k = 17;

    r->i = i;
    r->j = j;
    r->k = k;
}

int main(void)
{
    struct result r = {};
    caller(&r);
    printf("%d, %ld, %d\n", r.i, r.j, r.k);

    return 0;
}