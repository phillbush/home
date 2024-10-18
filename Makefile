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
	${HOME}/.mpdconf \
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
	${BINDIR}/cmpdir \
	${BINDIR}/fetchmail \
	${BINDIR}/fetchnews \
	${BINDIR}/focus \
	${BINDIR}/img \
	${BINDIR}/meme \
	${BINDIR}/open \
	${BINDIR}/record \
	${BINDIR}/samedir \
	${BINDIR}/save \
	${BINDIR}/searchcode \
	${BINDIR}/sendmail \
	${BINDIR}/shodmenu \
	${BINDIR}/startmenu \
	${BINDIR}/termdraw \
	${BINDIR}/termbin \
	${BINDIR}/vidtogif \
	${BINDIR}/walk \
	${BINDIR}/xdg-open \
	${BINDIR}/xfilesctl \
	${BINDIR}/xman

INCS = \
	/usr/include/crypto/*.h \
	/usr/include/net/*.h \
	/usr/include/dev/*.h \
	/usr/include/dev/*/*.h \
	/usr/include/sys/*.h \
	/usr/include/amd64/* \
	/usr/X11R6/include/*.h \
	/usr/X11R6/include/*/*.h \
	/usr/X11R6/include/X11/*/*.h \
	/usr/X11R6/include/freetype2/*/*.h \
	/usr/include/*.h

all:
	@echo no need to build

install: dir man bin lib ico cron tags
.PHONY:  dir man bin lib ico cron tags all install

cron: lib/crontab
	@crontab -l | cmp - lib/crontab >/dev/null || ( set -x ; crontab lib/crontab )

tags: ${HOME}/.tags
${HOME}/.tags: ${INCS}
	@echo generate ctags: $@
	@ctags -d -f $@ ${INCS} 1>/dev/null 2>/dev/null

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
