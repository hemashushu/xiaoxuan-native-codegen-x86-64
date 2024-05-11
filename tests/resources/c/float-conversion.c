/**
 * Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
 *
 * This Source Code Form is subject to the terms of
 * the Mozilla Public License version 2.0 and additional exceptions,
 * more details in file LICENSE, LICENSE.additional and CONTRIBUTING.
 */

int truncate(void)
{
    float a = 3.4;
    float b = 3.6;
    float c = 3.5;
    float d = 4.5;

    int i = (int)a;
    int j = (int)b;

    int m = (int)c;
    int n = (int)d;

    if (i == 3 && j == 3 && m == 3 && n == 4)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

int main(void)
{
    return truncate();
}