BINS = \
        bin/termdraw \
        bin/mancache \
        bin/samedir \
        bin/cmpdir \
        bin/agenda \
        bin/fetch \
        bin/dir

LIBEXECS = \
        lib/kshrc \
        lib/xinitrc

MANS = \
        man/home.7

LIBS = \
        lib/Xresources \
        lib/control \
        lib/exrc \
        lib/lfrc \
        lib/plumb \
        lib/rootmenu \
        lib/vimrc \
        lib/wallpaper.png \
        lib/xcompose \
        lib/xkeymap

SKEL = \
       lib/skel/Makefile \
       lib/skel/Makefile.incipit \
       lib/skel/Makefile.ino \
       lib/skel/man.1 \
       lib/skel/mdoc.1 \
       lib/skel/ms.ms \
       lib/skel/postscript.ps

SKELBINS = \
       lib/skel/scheme \
       lib/skel/sicp

SRCS = profile ${BINS} ${LIBS} ${LIBEXECS} ${MANS}

all:
	@echo no need to build

install:
	mkdir -p "${HOME}/prj" \
	         "${HOME}/tmp" \
	         "${HOME}/lib/skel" \
	         "${HOME}/usr/home/bin" \
	         "${HOME}/usr/home/man/man7" \
	         "${HOME}/var/cache" \
	         "${HOME}/var/history" \
	         "${HOME}/var/mail" \
	         "${HOME}/var/trash"
	install -D -m 755 profile ${HOME}/.profile
	install -D -m 755 ${BINS} ${HOME}/usr/home/bin/
	install -D -m 644 ${MANS} ${HOME}/usr/home/man/man7/
	install -D -m 644 ${LIBS} ${HOME}/lib/
	install -D -m 755 ${LIBEXECS} ${HOME}/lib/
	install -D -m 644 ${SKEL} ${HOME}/lib/skel
	install -D -m 755 ${SKELBINS} ${HOME}/lib/skel

gitadd:
	git add Makefile README.md LICENSE ${SRCS}

gitpush:
	# only do this once:
	# git remote add origin git@github.com:phillbush/home.git
	git push -u origin master

.PHONY: all install
