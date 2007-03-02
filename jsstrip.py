#!/usr/bin/env python
# -*-python-*-
#
# jsstrip.py
# removes comments and whitespace from javascript files
#
# 01-Mar-2007
#   import into http://code.google.com/p/jsstrip/
#   no changes
#
# version 1.03
# 10-Aug-2006 Fix command-line args bug with -q and -quiet
#  No change to javascript output
# Thanks to Mark Johnson
#
# version 1.02
# 25-May-2006 the ? operator doesn't need spaces either
#     x ? 1 : 0  ==> x?1:0
#
# version 1.0.1
# 24-Apr-2006 (removed some debug)
#
# version 1.0
# 25-Mar-2006 (initial)
#
# http://modp.com/release/jsstrip/
#
# send bugs, features, comments to
#
# nickg
#      @
#       modp.com
#
#

#
# The BSD License 
# http://www.opensource.org/licenses/bsd-license.php
#
# Copyright (c) 2005, 2006 Nick Galbreath
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, 
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of the modp.com nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

#
# TBD: should I add module stuff around debugOn/Off and strip?
# --nickg

#
# Handy debug script
#
def debugOn(s):
    sys.stderr.write(s + '\n')

def debugOff(s):
    pass

def strip(s, optSaveFirst=True, optWhite=True, optSingle=True, optMulti=True, debug=debugOff):
    result = []  # result array.  gets joined at end.
    i = 0        # char index for input string
    line = 0     # line number of file (close to it anyways)
    
    #
    # items that don't need spaces next to them
    #
    chars = '^&|!+-*/%=?:;,{}()<>% \t\n\r'

    while (i < len(s)):
	ch = s[i]
	
	# multiline comments
	if ch == '/' and s[i+1] == '*':
	    endC = s.find('*/',i+2)
	    if endC == -1: raise exception('Found invalid /*..*/ comment')
	    if optSaveFirst and line == 0: result.append(s[i:endC+2]+"\n")
            elif not optMulti: result.append("\n" + s[i:endC+2] + "\n")
	    # count how many newlines for debuggin purposes
	    j = i+1
	    while j < endC:
		if s[j] == '\n': line = line +1
		j = j+1
	    # keep going
	    i = endC +2
	    continue

	# singleline
	if ch == '/' and s[i+1] == '/':
	    endC = s.find('\n',i+2)
	    if endC == -1: raise exception('Found invalid // comment')
	    if optSaveFirst and line == 0: result.append(s[i:endC+1]+"\n")
            elif not optSingle: result.append(" " + s[i:endC+1] + "\n")
	    i = endC
	    continue

	# tricky.  might be an RE
	if ch == '/':
	    # rewind, skip white space
	    j= 1;
	    while s[i-j] == ' ': j = j +1
	    debug("REGEXP: " +str(j)+" backup found '" + s[i-j] + "'")
	    if s[i-j] == '=' or s[i-j] == '(':
		# yes, this is an re
		# now move forward and find the end of it
		j = 1
		while (s[i+j] != '/'):
		    while s[i+j] != '\\' and s[i+j] != '/': j = j+1
		    if s[i+j] == '\\': j=j+2
		result.append(s[i:i+j+1])
		debug("REGEXP: " + s[i:i+j+1])
		i = i +j + 1
		debug("REGEXP: now at " + ch)
		continue

	#double quote strings
	if ch == '"':
	    j = 1
	    while (s[i+j] != '"'):
		while s[i+j] != '\\' and s[i+j] != '"': j = j+1
		if s[i+j] == '\\': j=j+2
	    result.append(s[i:i+j+1])
	    debug("DQUOTE: " + s[i:i+j+1])
	    i = i +j + 1
	    continue

	#double quote strings
	if ch == "'":
	    j = 1
	    while (s[i+j] != "'"):
		while s[i+j] != '\\' and s[i+j] != "'": j = j+1
		if s[i+j] == '\\': j=j+2
	    result.append(s[i:i+j+1])
	    debug("SQUOTE: " + s[i:i+j+1])
	    i = i +j + 1
	    continue

	# newlines
	if ch == '\n' or ch == '\r':
	    line = line +1
	    debug("LINE: " + str(line))
	    if not optWhite:
		result.append(ch)
	    i = i+1
	    continue

	#leading spaces
	if optWhite and (ch == ' ' or ch == '\n' or ch == '\t') and chars.find(s[i+1]) != -1:
	    i = i+1
	    continue

        #trailing spaces
	if optWhite and (ch == ' ' or ch == '\n' or ch == '\t') and chars.find(s[i-1]) != -1:
	    i = i+1
	    continue

	result.append(ch)
	i=i+1

    return ''.join(result)

#----------------
# everything below here is just for command line arg processing
#----------------

import sys
import getopt

def usage():
    foo= """
Usage: jsstrip [flags] [infile]

This program strips out white space and comments from javascript files.

With no 'infile' jsstrip reads from stdin.

By default, the first comment block is saved since it normally contains
author, copyright or licensing information.  Using "-f" overrides this.

-h -? --help   This page
-f --first     Do not save first comment
-w --white     Do not strip white space
-s --single    Do not strip single line comments //
-m --multi     Do not strip multi line comments /* ... */
-q --quiet     Do not print statistics at end of run
-d --debug     Print debugging messages
-n --nop       Do not print/save result


"""
    sys.stderr.write(foo)

def main(argv):
    OPT_DEBUG = False
    OPT_QUIET = False
    OPT_WHITE = True
    OPT_SINGLE = True
    OPT_MULTI = True
    OPT_FIRST = True
    OPT_DEBUG = debugOff
    OPT_NOP = False

    argsShort="d?imwfsnq"
    argsLong=['debug', 'nop', 'help', 'single', 'multi', 'white', 'first', 'quiet']
    try:
	opts, args = getopt.getopt(argv, argsShort, argsLong)
    except getopt.GetoptError:
	usage()
	sys.exit(2)
    for opt,arg in opts:
	if opt in ("-?", "-h", "--help"):
	    usage()
	    sys.exit()
	elif opt in ("-d", "--debug"):
	    OPT_DEBUG=debugOn
	elif opt in ("-s", "--single"):
	    OPT_SINGLE = False
	elif opt in ("-m", "--multi"):
	    OPT_MULTI = False
	elif opt in ("-w", "--white"):
	    OPT_WHITE = False
	elif opt in ("-f", "--first"):
	    OPT_FIRST = False
	elif opt in ("-q", "--quiet"):
	    OPT_QUIET = True
	elif opt in ("-n", "--nop"):
	    OPT_NOP = True

    f = sys.stdin
    if len(args) == 1:
	# todo add exception check so error is prettier
	f = open(args[0], "r")

    # read all of it
    s = f.read()

    snew = strip(s, OPT_FIRST, OPT_WHITE, OPT_SINGLE, OPT_MULTI, OPT_DEBUG)

    if not OPT_NOP:
	print snew

    if not OPT_QUIET:
	sys.stderr.write("In: " + str(len(s)) + ", Out: " + str(len(snew)) + ", Savings: " + str(100.0 *(1.0 - float(len(snew))/len(s))) + '\n')
    
if __name__ == "__main__":
    main(sys.argv[1:])
