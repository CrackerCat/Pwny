#
# MIT License
#
# Copyright (c) 2020-2021 EntySec
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

AR = ar
CC = clang
STRIP = strip

PWNY = pwny
LIBPWNY = libpwny.a

IOS_SYSROOT = /Users/enty8080/theos/sdks/iPhoneOS13.0.sdk

SRC = src
INCLUDE = include

STDAPI = $(SRC)/stdapi

STDAPI_SRC = $(STDAPI)/src
STDAPI_INCLUDE = $(STDAPI)/include

CFLAGS = -std=c99
OBJC_FLAGS = -x objective-c -fobjc-arc

IOS_FRAMEWORKS = -framework Foundation -framework Security -framework AudioToolbox
IOS_FRAMEWORKS += -framework CoreFoundation -framework MediaPlayer -framework UIKit
IOS_FRAMEWORKS += -framework AVFoundation -framework CoreLocation

IOS_FRAMEWORKS += -framework SpringBoardServices IOSurface

IOS_FLAGS = -arch arm64 -arch arm64e -isysroot $(IOS_SYSROOT)
IOS_FLAGS += -F $(IOS_SYSROOT)/System/Library/PrivateFrameworks $(IOS_FRAMEWORKS)

pwny_template = src/pwny/main.c

pwny_sources = src/base64.c
pwny_sources += src/channel.c
pwny_sources += src/console.c
pwny_sources += src/json.c
pwny_sources += src/utils.c

pwny_flags = $(CFLAGS)
pwny_flags += -I$(INCLUDE) -I$(STDAPI_INCLUDE)

ifeq ($(IOS_TEMPLATE), 1)
	pwny_sources += $(STDAPI_SRC)/ios_handler.m
	pwny_sources += $(STDAPI_SRC)/ios_commands.m

	pwny_flags += $(OBJC_FLAGS) $(IOS_FLAGS)
else ifeq ($(LINUX_TEMPLATE), 1)
	pwny_sources += $(STDAPI_SRC)/linux_handler.c
	pwny_sources += $(STDAPI_SRC)/linux_commands.c
endif

.PHONY: all libpwny pwny clean

clean:
	rm -rf $(PWNY) $(LIBPWNY)

libpwny:
	$(CC) $(pwny_flags) $(pwny_sources)
