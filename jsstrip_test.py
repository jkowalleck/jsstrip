#!/usr/bin/env python
# -*-python-*-

from jsstrip import strip

import unittest

class jsstriptUnitTest(unittest.TestCase):
    def readTwo(self, n):
        f1name = "testfiles/test%03d-in.js" % n
        f2name = "testfiles/test%03d-out.js" % n
	fh = open(f1name);
	testinput = fh.read()
	fh.close()
        fh = open(f2name)
        testoutput = fh.read()
        fh.close()
        return (testinput, testoutput)

    def testIfThenElseBraces(self):
        (input,output) = self.readTwo(1)
	self.assertEqual(strip(input), output)

    def testIfThenElseNoBraces(self):
        (input,output) = self.readTwo(2)
	self.assertEqual(strip(input), output)

    def testCommentInQuotes(self):
        (input,output) = self.readTwo(3)
	self.assertEqual(strip(input), output)

    def testCommentInQuotes2(self):
        (input,output) = self.readTwo(4)
	self.assertEqual(strip(input), output)

    def testCommentMultiline(self):
        (input,output) = self.readTwo(5)
	self.assertEqual(strip(input), output)

    def testCommentSingleline(self):
        (input,output) = self.readTwo(6)
	self.assertEqual(strip(input), output)

    def testStringSingleQuotes(self):
        (input,output) = self.readTwo(7)
	self.assertEqual(strip(input), output)

    def testRegexpSimple(self):
        (input,output) = self.readTwo(8)
	self.assertEqual(strip(input), output)

    def testRegexpSimpleWhitespace(self):
        (input,output) = self.readTwo(9)
	self.assertEqual(strip(input), output)

    def testRegexpString(self):
        (input,output) = self.readTwo(10)
	self.assertEqual(strip(input), output)

    def testRegexpBackslash(self):
        (input,output) = self.readTwo(11)
	self.assertEqual(strip(input), output)

    def testStringDoubleQuotes(self):
        (input,output) = self.readTwo(12)
	self.assertEqual(strip(input), output)


if __name__ == '__main__':
    unittest.main()

