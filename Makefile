BINDIR = /usr/home/bin
MANDIR = /usr/home/man
ICODIR = ${HOME}/.icons

DIRS = \
	${HOME}/prj \
	${HOME}/tmp \
	${HOME}/var/cache \
	${HOME}/var/history \
	${HOME}/var/mail \
	${HOME}/var/trash \
	${BINDIR} \
	${ICODIR} \
	${MANDIR}

LIBS = \
	${HOME}/.XCompose \
	${HOME}/.Xresources \
	${HOME}/.kshrc \
	${HOME}/.mailcap \
	${HOME}/.muttrc \
	${HOME}/.news \
	${HOME}/.plumb \
	${HOME}/.profile \
	${HOME}/.vimrc \
	${HOME}/.wallpaper.png \
	${HOME}/.xkeybinds \
	${HOME}/.xkeymap \
	${HOME}/.xsession

ICOS = \
	${ICODIR}/start-active.xpm \
	${ICODIR}/start-hovered.xpm \
	${ICODIR}/start-inactive.xpm \

MANS = \
	${MANDIR}/man8/home.8 \
	${MANDIR}/man8/rember.8

BINS = \
	${BINDIR}/fetchnews \
	${BINDIR}/focus \
	${BINDIR}/img \
	${BINDIR}/meme \
	${BINDIR}/open \
	${BINDIR}/record \
	${BINDIR}/samedir \
	${BINDIR}/save \
	${BINDIR}/searchcode \
	${BINDIR}/shodmenu \
	${BINDIR}/startmenu \
	${BINDIR}/termdraw \
	${BINDIR}/termbin \
	${BINDIR}/vidtogif \
	${BINDIR}/walk \
	${BINDIR}/xdg-open \
	${BINDIR}/xfilesctl \
	${BINDIR}/xman

all:
	@echo no need to build

install: dir man bin lib ico cron
.PHONY:  dir man bin lib ico cron all install

cron: lib/crontab
	@crontab -l | cmp - lib/crontab >/dev/null || ( set -x ; crontab lib/crontab )

dir: ${DIRS}
${DIRS}: $@
	mkdir -p -- $@

lib: ${LIBS}
${LIBS}: lib/${@:T:.%=%}
	install -m 644 lib/${@:T:.%=%} $@

ico: ${ICOS}
${ICOS}: ico/${@:T}
	install -m 644 ico/${@:T} $@

man: ${MANS}
${MANS}: doc/${@:T}
	install -m 644 doc/${@:T} $@

bin: ${BINS}
${BINS}: bin/${@:T}
	install -m 755 bin/${@:T} $@
