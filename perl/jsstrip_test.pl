#!/usr/bin/perl

use strict;
use warnings;

use Test;
BEGIN { plan tests => 21 }

require "jsstrip.pl";
*strip = \&jsstrip::strip;

use FileHandle;

sub readTwo ($;$) {
  my ($s, $dir) = @_;
  $dir = "../testfiles" unless(defined $dir);

  my $f1name = sprintf("%s/test-%s-in.js", $dir, $s);
  my $f2name = sprintf("%s/test-%s-out.js", $dir, $s);
  my $fh = new FileHandle $f1name or die $f1name;
  my $testinput = join('', $fh->getlines());
  $fh->close;
  $fh = new FileHandle $f2name  or die $f2name;
  my $testoutput = join('', $fh->getlines());
  $fh->close;
  return ($testinput, $testoutput);
}

# Test files in the default testfiles folder
foreach(qw(
  IfThenElseBraces
  IfThenElseNoBraces
  CommentInDoubleQuotes1
  CommentInSingleQuotes1
  CommentInDoubleQuotes2
  CommentInSingleQuotes2
  CommentMultiline
  CommentSingleline
  StringSingleQuotes
  RegexpSimple
  RegexpSimpleWhitespace
  RegexpString
  RegexpBackslash
  StringDoubleQuotes
  StatementNew
  StatementDoWhile
  StatementForIn
  StatementSwitchCase
)) {
  my ($input, $output) = readTwo($_);
  ok(strip($input), $output);
};

# Local test files
foreach(qw(
  CommentSingleLastLine
  Conditional
  CommentConditional
)) {
  my ($input, $output) = readTwo($_, ".");
  ok(strip($input), $output);
};
