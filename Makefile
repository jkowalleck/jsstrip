
#
# remove python compiled files
# remove emacs turds
# remove coverage file
#
clean:
	rm -rf *.pyc
	find . -name '*~' | xargs rm -f
	find . -name '\#*' | xargs rm -f
	rm -f .coverage

