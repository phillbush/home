rulesdir = ${HOME}/rules

.SUFFIXES: .txt .ms .ps .pdf

all:
	@echo no need to build

home.pdf: home.txt
	<"home.txt" incipit ms | troff -ms | dpost | ps2pdf - - >"home.pdf"

install:
	install -D -m 644 rules/* ${rulesdir}/
	install -D -m 644 profile ${HOME}/.profile
	install -D -m 644 session ${HOME}/.session
	install -D -m 644 xsession ${HOME}/.xsession

.PHONY: all install uninstall
