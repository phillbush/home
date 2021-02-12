bindir = ${HOME}/usr/local/bin
mandir = ${HOME}/usr/local/man
rulesdir = ${HOME}/rules

all:
	@echo no need to build

install:
	install -D -m 755 bin/* ${bindir}/
	install -D -m 644 man/* ${mandir}/man7/
	install -D -m 644 rules/* ${rulesdir}/
	install -D -m 644 .profile ${HOME}/.profile
	install -D -m 644 .session ${HOME}/.session
	install -D -m 644 .xsession ${HOME}/.xsession

.PHONY: all install uninstall
