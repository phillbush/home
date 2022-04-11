rulesdir = ${HOME}/rules
themedir = ${HOME}/theme

all:
	@echo no need to build

install:
	mkdir -p "$$HOME/files" \
	         "$$HOME/proj" \
	         "$$HOME/rules" \
	         "$$HOME/skel" \
	         "$$HOME/theme" \
	         "$$HOME/tmp" \
	         "$$HOME/var/apps" \
	         "$$HOME/var/cache" \
	         "$$HOME/var/history" \
	         "$$HOME/var/mail" \
	         "$$HOME/var/trash"
	install -D -m 644 rules/* ${rulesdir}/
	install -D -m 644 bg.png ${themedir}/bg.png
	install -D -m 644 profile ${HOME}/.profile
	install -D -m 644 session ${HOME}/.session
	install -D -m 644 xsession ${HOME}/.xsession

.PHONY: all install
