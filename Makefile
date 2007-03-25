
.PHONY: clean test test-python test-perl

test-python:
	(cd python; python jsstrip_test.py)

test-perl:
	(cd perl; perl jsstrip_test.pl ../testfiles)

test: test-python test-perl

#
# remove python compiled files
# remove emacs turds
# remove coverage file
#
clean:
	find . -name '*.pyc' | xargs rm -f
	find . -name '*~' | xargs rm -f
	find . -name '\#*' | xargs rm -f
	rm -f .coverage

