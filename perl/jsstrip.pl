#!/usr/bin/env perl
#
# jsstrip.pl
# removes comments and whitespace from javascript files
#
# 19-Oct-2007
#   (Finally) updated the Perl port with the changes from March
#
# 25-Mar-2007
#   remove a few extra spots of whitespace
#   fix exception handling
#   do not strip MSIE conditional comments
#   remove MS-DOS newlines (\r)
#   when saving single-comments, remove ending whitespace
#
# 01-Mar-2007
#   import into http://code.google.com/p/jsstrip/
#   no changes
#
# 26-Feb-2007
#   Port from the original jsstrip.py to Perl by Theo Niessink
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
# Copyright (c) 2005, 2006, 2007 Nick Galbreath
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

package jsstrip;

use strict;
use warnings;

#
# Handy debug script
#
sub debugOn ($) {
  my ($s) = @_;

  print STDERR "$s\n";
}

sub debugOff ($) {}

sub strip ($;$;$;$;$;$) {
  my ($s, $optSaveFirst, $optWhite, $optSingle, $optMulti, $debug) = @_;
  $optSaveFirst = 1 unless(defined $optSaveFirst);
  $optWhite = 1 unless(defined $optWhite);
  $optSingle = 1 unless(defined $optSingle);
  $optMulti = 1 unless(defined $optMulti);
  $debug = \&debugOff unless(defined $debug);

  my @result = ();       # result array.  gets joined at end.
  my $i = 0;             # char index for input string
  my $j = 0;             # char forward index for input string
  my $slen = length($s); # size of input string
  my $line = 0;          # line number of file (close to it anyways)

  #
  # whitespace characters
  # 
  my $whitespace = " \n\r\t";

  #
  # items that don't need spaces next to them
  #
  my $chars = "^&|!+-*/%=?:;,{}()<>% \t\n\r\'\"[]";

  while($i < $slen) {
    # skip all "boring" characters.  This is either
    # reserved word (e.g. "for", "else", "if") or a
    # variable/object/method (e.g. "foo.color")
    $j = $i;
    while($j < $slen and index($chars, substr($s, $j, 1)) == -1) {
      $j = $j+1;
    }
    if($i != $j) {
      my $token = substr($s, $i, $j -$i);
      push(@result, $token);
      $i = $j;
    }

    if($i >= $slen) {
      # last line was unterminated with ";"
      # might want to either throw an exception
      # print a warning message
      last;
    }

    my $ch = substr($s, $i, 1);
    # multiline comments
    if($ch eq "/" and substr($s, $i+1, 1) eq "*" and substr($s, $i+2, 1) ne '@') {
      my $endC = index($s, "*/", $i+2);
      die "Found invalid /*..*/ comment" if($endC == -1);
      if(($optSaveFirst and $line == 0) or !$optMulti) {
        push(@result, substr($s, $i, $endC+2 -$i)."\n");
      }

      # count how many newlines for debuggin purposes
      $j = $i+1;
      while($j < $endC) {
        $line = $line+1 if(substr($s, $j, 1) eq "\n");
        $j = $j+1;
      }
      # keep going
      $i = $endC+2;
      next;
    }

    # singleline
    if($ch eq "/" and substr($s, $i+1, 1) eq "/") {
      my $endC = index($s, "\n", $i+2);
      my $nextC = $endC;
      if($endC == -1) {
        $endC = $slen-1;
        $nextC = $slen;
      } else {
        # rewind and remove any "\r" or trailing whitespace IN the comment
        # e.g. "//foo   " --> "//foo"
        while(index($whitespace, substr($s, $endC, 1)) != -1) {
          $endC = $endC-1;
        }
      }

      # save only if it's the VERY first thing in the file and optSaveFirst is on
      # or if we are saving all // comments
      # or if it's an MSIE conditional comment
      if(($optSaveFirst and $line == 0 and $i == 0) or !$optSingle or substr($s, $i+2, 1) eq '@') {
        push(@result, substr($s, $i, $endC+1 -$i)."\n");
      }
      $i = $nextC;
      next;
    }

    # tricky.  might be an RE
    if($ch eq "/") {
      # rewind, skip white space
      $j = 1;
      $j = $j+1 while(substr($s, $i-$j, 1) eq " ");
      &$debug("REGEXP: ".$j." backup found '".substr($s, $i-$j, 1)."'");
      if(substr($s, $i-$j, 1) eq "=" or substr($s, $i-$j, 1) eq "(") {
        # yes, this is an re
        # now move forward and find the end of it
        $j = 1;
        while(substr($s, $i+$j, 1) ne "/") {
          $j = $j+1 while(substr($s, $i+$j, 1) ne "\\" and substr($s, $i+$j, 1) ne "/");
          $j = $j+2 if(substr($s, $i+$j, 1) eq "\\");
        }
        push(@result, substr($s, $i, $i+$j+1 -$i));
        &$debug("REGEXP: ".substr($s, $i, $i+$j+1 -$i));
        $i = $i+$j+1;
        &$debug("REGEXP: now at ".$ch);
        next;
      }
    }

    # double quote strings
    if($ch eq '"') {
      $j = 1;
      while(substr($s, $i+$j, 1) ne '"') {
        $j = $j+1 while(substr($s, $i+$j, 1) ne "\\" and substr($s, $i+$j, 1) ne '"');
        $j = $j+2 if(substr($s, $i+$j, 1) eq "\\");
      }
      push(@result, substr($s, $i, $i+$j+1 -$i));
      &$debug("DQUOTE: ".substr($s, $i, $i+$j+1 -$i));
      $i = $i+$j+1;
      next;
    }

    # single quote strings
    if($ch eq "'") {
      $j = 1;
      while(substr($s, $i+$j, 1) ne "'") {
        $j = $j+1 while(substr($s, $i+$j, 1) ne "\\" and substr($s, $i+$j, 1) ne "'");
        $j = $j+2 if(substr($s, $i+$j, 1) eq "\\");
      }
      push(@result, substr($s, $i, $i+$j+1 -$i));
      &$debug("SQUOTE: ".substr($s, $i, $i+$j+1 -$i));
      $i = $i+$j+1;
      next;
    }

    # newlines
    # this is just for error and debugging output
    if($ch eq "\n" or $ch eq "\r") {
      $line = $line+1;
      &$debug("LINE: ".$line);
    }

    if($optWhite and index($whitespace, $ch) != -1) {
      # leading spaces
      if($i+1 < $slen and index($chars, substr($s, $i+1, 1)) != -1) {
        $i = $i+1;
        next;
      }
      # trailing spaces
      # if this ch is space AND the last char processed
      # is special, then skip the space
      if($#result == -1 or index($chars, substr($result[-1], -1)) != -1) {
        $i = $i+1;
        next;
      }
      # else after all of this convert the "whitespace" to
      # a single space.  It will get appended below
      $ch = " ";
    }

    push(@result, $ch);
    $i = $i+1;
  }

  # remove last space, it might have been added by mistake at the end
  if(@result and length($result[-1]) == 1 and index($whitespace, $result[-1]) != -1) {
    pop(@result);
  }

  return join('', @result);
}

#----------------
# everything below here is just for command line arg processing
#----------------

use FileHandle;
use Getopt::Long;

sub usage () {
  my $foo = <<EOF;
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


EOF
  print STDERR $foo;
}

sub main () {
#  my $OPT_DEBUG = '';
  my $OPT_QUIET = '';
  my $OPT_WHITE = 1;
  my $OPT_SINGLE = 1;
  my $OPT_MULTI = 1;
  my $OPT_FIRST = 1;
  my $OPT_DEBUG = \&debugOff;
  my $OPT_NOP = '';

  if(!GetOptions(
    "help|?" => sub { usage; exit 2; },
    debug    => sub { $OPT_DEBUG  = \&debugOn },
    single   => sub { $OPT_SINGLE = '' },
    multi    => sub { $OPT_MULTI  = '' },
    white    => sub { $OPT_WHITE  = '' },
    first    => sub { $OPT_FIRST  = '' },
    quiet    => \$OPT_QUIET,
    nop      => \$OPT_NOP,
  )) { usage; exit 2; }

  my $f = *STDIN;
  if($#ARGV == 0) {
    # todo add exception check so error is prettier
    $f = new FileHandle $ARGV[0], "r";
  }

  # read all of it
  my $s = join('', $f->getlines());

  my $snew = strip($s, $OPT_FIRST, $OPT_WHITE, $OPT_SINGLE, $OPT_MULTI, $OPT_DEBUG);

  if(!$OPT_NOP) {
    print $snew;
  }

  if(!$OPT_QUIET) {
    print STDERR "In: ".length($s).", Out: ".length($snew).", Savings: ".(100.0*(1.0-length($snew)/length($s)))."\n";
  }
}

if(!caller) {
  main;
}
1;
