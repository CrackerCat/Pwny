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

SRC = src

MSG = echo
Q = @

.PHONY: all linux iphoneos

all: linux iphoneos macos

linux:
	$(Q) $(MSG) [Building Pwny for Linux...]
	$(Q) cd $(SRC)/linux
	$(Q) make all
	$(Q) $(MSG) [Done]

iphoneos:
	$(Q) $(MSG) [Building Pwny for iPhoneOS...]
	$(Q) cd $(SRC)/iphoneos
	$(Q) make all
	$(Q) $(MSG) [Done]

macos:
	$(Q) $(MSG) [Building Pwny for macOS...]
	$(Q) cd $(SRC)/macos
	$(Q) make all
	$(Q) $(MSG) [Done]
