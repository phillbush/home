rulesdir = ${HOME}/rules
themedir = ${HOME}/theme

.SUFFIXES: .txt .ms .ps .pdf

all:
	@echo no need to build

home.pdf: home.txt
	<"home.txt" incipit ms | troff -ms | dpost | ps2pdf - - >"home.pdf"

install:
	mkdir -p "$$HOME/files" \
	         "$$HOME/proj" \
	         "$$HOME/rules" \
	         "$$HOME/skel" \
	         "$$HOME/theme" \
	         "$$HOME/tmp" \
	         "$$HOME/usr" \
	         "$$HOME/var/apps" \
	         "$$HOME/var/cache" \
	         "$$HOME/var/history" \
	         "$$HOME/var/mail" \
	         "$$HOME/var/trash"
	install -D -m 644 rules/* ${rulesdir}/
	install -D -m 644 wallpaper.png ${themedir}/wallpaper.png
	install -D -m 644 profile ${HOME}/.profile
	install -D -m 644 session ${HOME}/.session
	install -D -m 644 xsession ${HOME}/.xsession

.PHONY: all install uninstall
