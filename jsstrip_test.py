#!/usr/bin/env python
# -*-python-*-

from jsstrip import strip

import unittest

class jsstriptUnitTest(unittest.TestCase):
    def readTwo(self, s):
        f1name = "testfiles/test-%s-in.js" % s
        f2name = "testfiles/test-%s-out.js" % s
        fh = open(f1name);
        testinput = fh.read()
        fh.close()
        fh = open(f2name)
        testoutput = fh.read()
        fh.close()
        return (testinput, testoutput)

    def testIfThenElseBraces(self):
        (input,output) = self.readTwo("IfThenElseBraces")
        self.assertEqual(strip(input), output)

    def testIfThenElseNoBraces(self):
        (input,output) = self.readTwo("IfThenElseNoBraces")
        self.assertEqual(strip(input), output)

    def testCommentInDoubleQuotes1(self):
        (input,output) = self.readTwo("CommentInDoubleQuotes1")
        self.assertEqual(strip(input), output)

    def testCommentInSingleQuotes1(self):
        (input,output) = self.readTwo("CommentInSingleQuotes1")
        self.assertEqual(strip(input), output)

    def testCommentInDoubleQuotes2(self):
        (input,output) = self.readTwo("CommentInDoubleQuotes2")
        self.assertEqual(strip(input), output)

    def testCommentInSingleQuotes2(self):
        (input,output) = self.readTwo("CommentInSingleQuotes2")
        self.assertEqual(strip(input), output)

    def testCommentMultiline(self):
        (input,output) = self.readTwo("CommentMultiline")
        self.assertEqual(strip(input), output)

    def testCommentSingleline(self):
        (input,output) = self.readTwo("CommentSingleline")
        self.assertEqual(strip(input), output)

    def testStringSingleQuotes(self):
        (input,output) = self.readTwo("StringSingleQuotes")
        self.assertEqual(strip(input), output)

    def testRegexpSimple(self):
        (input,output) = self.readTwo("RegexpSimple")
        self.assertEqual(strip(input), output)

    def testRegexpSimpleWhitespace(self):
        (input,output) = self.readTwo("RegexpSimpleWhitespace")
        self.assertEqual(strip(input), output)

    def testRegexpString(self):
        (input,output) = self.readTwo("RegexpString")
        self.assertEqual(strip(input), output)

    def testRegexpBackslash(self):
        (input,output) = self.readTwo("RegexpBackslash")
        self.assertEqual(strip(input), output)

    def testStringDoubleQuotes(self):
        (input,output) = self.readTwo("StringDoubleQuotes")
        self.assertEqual(strip(input), output)

    def testStatementNew(self):
        (input,output) = self.readTwo("StatementNew")
        # Note: strip first comment
        self.assertEqual(strip(input, True), output)

    def testStatementDoWhile(self):
        (input,output) = self.readTwo("StatementDoWhile")
        self.assertEqual(strip(input), output)

    def testStatementForIn(self):
        (input,output) = self.readTwo("StatementForIn")
        self.assertEqual(strip(input), output)

    def testStatementForIn(self):
        (input,output) = self.readTwo("StatementSwitchCase")
        self.assertEqual(strip(input), output)

    # this test javascript ending with all "plain" chars
    # and particular no ending ";"  jsstrip should not die
    def testNoWhitespace(self):
        (input,output) = self.readTwo("NoWhitespace")
        self.assertEqual(strip(input), output)

    # test MSIE conditional comments
    def testConditional(self):
	(input,output) = self.readTwo("Conditional")
        self.assertEqual(strip(input), output)

    def testCommentConditional(self):
	(input,output) = self.readTwo("CommentConditional")
        self.assertEqual(strip(input), output)

    def testCommentSingleLastLine(self):
	(input,output) = self.readTwo("CommentSingleLastLine")
        self.assertEqual(strip(input), output)

if __name__ == '__main__':
    unittest.main()
