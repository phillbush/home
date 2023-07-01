LIBDIR = ${HOME}/lib
SKLDIR = ${HOME}/lib/skel
WALDIR = ${HOME}/lib/papes
TEDDIR = ${HOME}/lib/teddy
BINDIR = ${HOME}/usr/home/bin
MANDIR = ${HOME}/usr/home/man

DIRS = \
       ${HOME}/prj \
       ${HOME}/tmp \
       ${HOME}/var/cache \
       ${HOME}/var/history \
       ${HOME}/var/mail \
       ${HOME}/var/trash \
       ${LIBDIR} \
       ${SKLDIR} \
       ${WALDIR} \
       ${BINDIR} \
       ${MANDIR}

ENVS = ${HOME}/.profile

MANS = \
       ${MANDIR}/man7/painframe.7 \
       ${MANDIR}/man7/text.7

BINS = \
       ${BINDIR}/agenda \
       ${BINDIR}/cmpdir \
       ${BINDIR}/dir \
       ${BINDIR}/edit \
       ${BINDIR}/fetch \
       ${BINDIR}/fetchnews \
       ${BINDIR}/mancache \
       ${BINDIR}/meme \
       ${BINDIR}/open \
       ${BINDIR}/preview \
       ${BINDIR}/readme \
       ${BINDIR}/samedir \
       ${BINDIR}/startmenu \
       ${BINDIR}/termdraw \
       ${BINDIR}/todo \
       ${BINDIR}/www \
       ${BINDIR}/xdg-open \
       ${BINDIR}/xfilesctl \
       ${BINDIR}/xman

LIBS = \
       ${LIBDIR}/Xresources \
       ${LIBDIR}/control \
       ${LIBDIR}/exrc \
       ${LIBDIR}/favs \
       ${LIBDIR}/kshrc \
       ${LIBDIR}/lfrc \
       ${LIBDIR}/menu \
       ${LIBDIR}/news \
       ${LIBDIR}/plumb \
       ${LIBDIR}/read \
       ${LIBDIR}/rootmenu \
       ${LIBDIR}/vimrc \
       ${LIBDIR}/xcompose \
       ${LIBDIR}/xinitrc \
       ${LIBDIR}/xkeymap

SKLS = \
       ${SKLDIR}/Makefile \
       ${SKLDIR}/man.1 \
       ${SKLDIR}/mdoc.1 \
       ${SKLDIR}/ms.ms \
       ${SKLDIR}/postscript.ps \
       ${SKLDIR}/scheme \
       ${SKLDIR}/sicp

WALS = \
       ${WALDIR}/blac.png \
       ${WALDIR}/blue.png \
       ${WALDIR}/doom.png

TEDS = \
       ${TEDDIR}/puffy.png

all:
	@echo no need to build

install: dir env man bin lib wal ted skl

dir: ${DIRS}
${DIRS}: $@
	mkdir -p -- $@

env: ${ENVS}
${ENVS}: profile
	install -D -m 755 profile $@

man: ${MANS}
${MANS}: man/${@:T}
	install -D -m 644 man/${@:T} $@

bin: ${BINS}
${BINS}: bin/${@:T}
	install -D -m 755 bin/${@:T} $@

lib: ${LIBS}
${LIBS}: lib/${@:T}
	install -D -m 644 lib/${@:T} $@

skl: ${SKLS}
${SKLS}: lib/skel/${@:T}
	install -D -m 644 lib/skel/${@:T} $@

wal: ${WALS}
${WALS}: lib/papes/${@:T}
	install -D -m 644 lib/papes/${@:T} $@

ted: ${TEDS}
${TEDS}: lib/teddy/${@:T}
	install -D -m 644 lib/teddy/${@:T} $@
