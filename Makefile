.PHONY: setup clean check archive

LOCAL_PERL=${HOME}/perl
PERL5LIB=${LOCAL_PERL}/lib/perl5

setup: module_list.txt
	cpanm -l ${LOCAL_PERL} `cat $^ | tr '\n' ' '`
	if [ ! -d venv ] ; then \
		mkdir venv; \
		virtualenv -p python3 venv; \
		. venv/bin/activate && pip install -r requirements.txt; \
	fi

check: setup
	for f in $(wildcard */*.p[lm] t/*); do perl -I${PERL5LIB} -c $$f; done
	prove -I${PERL5LIB} -vl 
	. venv/bin/activate && for f in $(wildcard src/*.py); do python3 -m py_compile $$f ; done

clean:
	find . -name __pycache__ | xargs ${RM} -r
	$(RM) -r *.log *.pyc

distclean: clean
	${RM} -r venv

BASEDIR=`basename ${PWD}`
archive: clean
	cd .. && gtar acvf ${BASEDIR}.tgz ${BASEDIR} --exclude-vcs

# N.B.: perl scripts don't send email on Mac
test: check
	. venv/bin/activate && \
		src/registrations.py -cfg etc/config-test.ini -reset && \
		src/registrations.py -cfg etc/config-test.ini -populate && \
		src/registrations.py -cfg etc/config-test.ini
	src/announce-casual-racing-for-the-week.pl -cfg etc/config-test.ini
	src/confirm-casual-racing-for-the-week.pl -cfg etc/config-test.ini
	. venv/bin/activate && \
		src/registrations.py -cfg etc/config-test.ini -reset
	src/confirm-casual-racing-for-the-week.pl -cfg etc/config-test.ini

module_list.txt:
	find . -type f -name "*.p[lm]" -o -name "*.t" | \
                xargs egrep '^[ \t]*use ' | \
                grep -v 'constant\|strict\|warnings' | \
                grep -v utils | \
                sed 's/:[ \t]*/:/g' | \
                awk '{ if (/use base/) { print $$3} else { print $$2} }' | \
                sed "s/'//g;s/;//g;/^$$/d" | sort -u > $@

