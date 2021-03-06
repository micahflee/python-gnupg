SHELL=/bin/sh
TESTDIR=./gnupg/test
TESTHANDLE=$(TESTDIR)/test_gnupg.py
FILES=$(SHELL find ./gnupg/ -name "*.py" -printf "%p,")

.PHONY=all
all: uninstall install test

ctags:
	ctags -R *.py

etags:
	find . -name "*.py" -print | xargs etags

# Sanitation targets -- clean leaves libraries, executables and tags
# files, which clobber removes as well
pycremoval:
	find . -name '*.py[co]' -exec rm -f {} ';'

cleanup-src: pycremoval
	cd gnupg && rm -f \#*\#

cleanup-tests: cleanup-src
	cd $(TESTDIR) && rm -f \#*\#
	mkdir -p gnupg/test/tmp
	mkdir -p gnupg/test/logs

cleanup-tests-all: cleanup-tests
	rm -rf tests/tmp

cleanup-build:
	mkdir buildnot
	rm -rf build*

test-before: cleanup-src cleanup-tests
	which gpg && gpg --version
	which gpg2 && gpg2 --version
	which gpg-agent
	which pinentry
	which python && python --version
	which pip && pip --version && pip list

test: test-before
	python $(TESTHANDLE) basic encodings parsers keyrings listkeys genkey \
		sign crypt
	touch gnupg/test/placeholder.log
	mv gnupg/test/*.log gnupg/test/logs/
	rm gnupg/test/logs/placeholder.log
	touch gnupg/test/random_seed_is_sekritly_pi
	rm gnupg/test/random_seed*

install: 
	python setup.py install --record installed-files.txt

uninstall:
	touch installed-files.txt
	cat installed-files.txt | sudo xargs rm -rf

reinstall: uninstall install

cleandocs:
	sphinx-apidoc -F -A "Isis Agora Lovecruft" -H "python-gnupg" \
		-o docs gnupg/ tests/

docs:
	cd docs && \
		make clean && \
		make html
