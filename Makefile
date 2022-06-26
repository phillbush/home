BINS = \
        bin/fetch

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
        lib/mime \
        lib/rootmenu \
        lib/vimrc \
        lib/wallpaper.png \
        lib/xcompose \
        lib/xkeymap

SRCS = profile ${BINS} ${LIBS} ${LIBEXECS} ${MANS}

all:
	@echo no need to build

install:
	mkdir -p "${HOME}/files" \
	         "${HOME}/proj" \
	         "${HOME}/tmp" \
	         "${HOME}/lib/skel" \
	         "${HOME}/usr/home/bin" \
	         "${HOME}/usr/home/man" \
	         "${HOME}/var/apps" \
	         "${HOME}/var/cache" \
	         "${HOME}/var/history" \
	         "${HOME}/var/mail" \
	         "${HOME}/var/trash"
	install -D -m 755 profile ${HOME}/.profile
	install -D -m 755 ${LIBEXECS} ${HOME}/lib/
	install -D -m 755 ${BINS} ${HOME}/usr/home/bin/
	install -D -m 644 ${MANS} ${HOME}/usr/home/man/
	install -D -m 644 ${LIBS} ${HOME}/lib/

gitadd:
	git add Makefile README.md LICENSE ${SRCS}

gitpush:
	# only do this once:
	# git remote add origin git@github.com:phillbush/control.git
	git push -u origin master

.PHONY: all install
