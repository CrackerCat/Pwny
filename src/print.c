/*
* MIT License
*
* Copyright (c) 2020-2021 EntySec
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>

#include "print.h"

void print(const char *prefix, const char *fmt, va_list va)
{
    char *msg = NULL;
    int formatted = 0;

    formatted = vasprintf(&msg, fmt, va);

    if (formatted >= 0 && msg) {
        printf("%s%s\n", prefix, msg);
        fflush(stdout);
        free(msg);
    }
}

void print_empty(const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    print("", fmt, va);
    va_end(va);
}

void print_process(const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    print(COLOR_BOLD COLOR_BLUE "[*] " COLOR_RESET, fmt, va);
    va_end(va);
}

void print_success(const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    print(COLOR_BOLD COLOR_GREEN "[+] " COLOR_RESET, fmt, va);
    va_end(va);
}

void print_error(const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    print(COLOR_BOLD COLOR_RED "[-] " COLOR_RESET, fmt, va);
    va_end(va);
}

void print_warning(const char *fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    print(COLOR_BOLD COLOR_YELLOW "[!] " COLOR_RESET, fmt, va);
    va_end(va);
}
