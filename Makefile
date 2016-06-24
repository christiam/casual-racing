.PHONY: setup clean check archive

PERL5LIB=~/perl5/lib/perl5

setup:
	cpanm -l ~/perl5 --install-deps .
	[ -d venv ] || mkdir venv
	virtualenv -p python3 venv
	pip3 install -r requirements.txt

check:
	for f in $(wildcard src/*.p[lm]); do perl -c $$f; done
	for f in $(wildcard src/*.py); do python3 -m py_compile $$f ; done

clean:
	find . -name __pycache__ | xargs ${RM} -r
	$(RM) -r *.log *.pyc

distclean: clean
	${RM} -r venv

archive: clean
	cd .. && gtar acvf `basename $$OLDPWD`.tgz `basename $$OLDPWD` --exclude-vcs

test: check
	src/announce-casual-racing-for-the-week.pl -cfg etc/config-test.ini
	src/announce-casual-racing-cancellation.pl -cfg etc/config-test.ini
	. venv/bin/activate && \
		src/registrations.py -cfg etc/config-test.ini -reset && \
		src/registrations.py -cfg etc/config-test.ini -populate && \
		src/registrations.py -cfg etc/config-test.ini

# N.B.: annouce scripts don't work on Mac
test_home: check
	src/registrations.py -cfg etc/config-test.ini -reset
	src/registrations.py -cfg etc/config-test.ini -populate
	src/registrations.py -cfg etc/config-test.ini 
