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

archive = ar
compiler = clang
strip = strip
ldid = ldid

template = pwny.bin
library = libpwny.a

src = src
includes = include

stdapi_src = $(src)/stdapi
stdapi_includes = $(includes)/stdapi

cflags = -std=c99
objc_flags = -x objective-c -fobjc-arc

template_sources = src/pwny/main.c

pwny_sources = $(src)/base64.c $(src)/channel.c $(src)/console.c $(src)/json.c $(src)/utils.c
pwny_objects = base64.o channel.o console.o json.o utils.o

pwny_cc_flags = $(cflags)
pwny_cc_flags += -I$(includes) -I$(stdapi_includes)

pwny_ld_flags = -lpwny

ifeq ($(platform), apple_ios)
	ios_frameworks = -framework Foundation -framework Security -framework AudioToolbox
	ios_frameworks += -framework CoreFoundation -framework MediaPlayer -framework UIKit
	ios_frameworks += -framework AVFoundation -framework CoreLocation
	ios_frameworks += -framework SpringBoardServices IOSurface

	ios_cc_flags = -arch arm64 -arch arm64e -isysroot $(sdk)

	ios_ld_flags = -F $(sdk)/System/Library/Frameworks
	ios_ld_flags += -F $(sdk)/System/Library/PrivateFrameworks $(ios_frameworks)

	ios_certificate = external/sign.plist
else ifeq ($(platform), macos)
	macos_frameworks = -framework Foundation

	macos_ld_flags = $(macos_frameworks)
endif

ifeq ($(platform), apple_ios)
	pwny_sources += $(stdapi_src)/ios_handler.m
	pwny_sources += $(stdapi_src)/ios_commands.m

	pwny_cc_flags += $(objc_flags) $(ios_cc_flags)
	pwny_ld_flags += $(objc_flags) $(ios_cc_flags) $(ios_ld_flags)

	pwny_objects += ios_hanler.o ios_commands.o
else ifeq ($(platform), macos)
	pwny_sources += $(stdapi_src)/macos_handler.m
	pwny_sources += $(stdapi_src)/macos_commands.m

	pwny_cc_flags += $(objc_flags)
	pwny_ld_flags += $(objc_flags) $(macos_ld_flags)

	pwny_objects += macos_handler.o macos_commands.o
else ifeq ($(platform), linux)
	pwny_sources += $(stdapi_src)/linux_handler.c
	pwny_sources += $(stdapi_src)/linux_commands.c

	pwny_objects += linux_handler.o linux_commands.o
endif

.PHONY: all library template clean

all: library template

clean:
	rm -rf $(pwny_objects) $(pwny) $(libpwny)

library:
	$(compiler) $(pwny_cc_flags) $(pwny_sources) -c
	$(archive) rcs $(library) $(pwny_objects)

template: $(LIBRARY)
	$(compiler) $(pwny_ld_flags) $(template_sources) -o $(template)

	ifeq ($(platform), apple_ios)
		$(ldid) -S $(ios_certificate) $(template)
	else ifeq ($(platform), macos)
		$(ldid) -S $(template)
	endif

	$(strip) $(template)
