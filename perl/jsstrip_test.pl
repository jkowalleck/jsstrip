#!/usr/bin/env perl

use strict;
use warnings;

use Test;
BEGIN { plan tests => 23 }

require "jsstrip.pl";
*strip = \&jsstrip::strip;

use FileHandle;

sub readTwo ($) {
  my ($s) = @_;

  my $f1name = sprintf("../testfiles/test-%s-in.js", $s);
  my $f2name = sprintf("../testfiles/test-%s-out.js", $s);
  my $fh = new FileHandle $f1name;
  my $testinput = join('', $fh->getlines());
  $fh->close;
  $fh = new FileHandle $f2name;
  my $testoutput = join('', $fh->getlines());
  $fh->close;
  return ($testinput, $testoutput);
}

{
  my ($input, $output) = readTwo("IfThenElseBraces");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("IfThenElseNoBraces");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentInDoubleQuotes1");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentInSingleQuotes1");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentInDoubleQuotes2");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentInSingleQuotes2");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentMultiline");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentSingleline");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentSinglelineFirstline");
  ok(strip($input, 0), $output);
}

{
  my ($input, $output) = readTwo("StringSingleQuotes");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("RegexpSimple");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("RegexpSimpleWhitespace");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("RegexpString");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("RegexpBackslash");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("RegexpStringQuotes");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("StringDoubleQuotes");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("StatementNew");
  # Note: strip first comment
  ok(strip($input, 1), $output);
}

{
  my ($input, $output) = readTwo("StatementDoWhile");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("StatementForIn");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("StatementSwitchCase");
  ok(strip($input), $output);
}

# this test javascript ending with all "plain" chars
# and particular no ending ";"  jsstrip should not die
{
  my ($input, $output) = readTwo("NoWhitespace");
  ok(strip($input), $output);
}

# test MSIE conditional comments
{
  my ($input, $output) = readTwo("Conditional");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentConditional");
  ok(strip($input), $output);
}

{
  my ($input, $output) = readTwo("CommentSingleLastLine");
  ok(strip($input), $output);
}
