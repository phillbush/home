ICODIR = ${HOME}/lib/icons

all:
	@echo no need to build

install: icons

ICO16 != for i in 16x16/* ; do printf "${ICODIR}/16x16/%s\n" "`basename "$$i"`" ; done
${ICO16}: 16x16/${@:T}
	install -D -m 644 16x16/${@:T} $@

install: ${HOME}/lib/icons/start-active.xpm
${HOME}/lib/icons/start-active.xpm: start-active.xpm
	install -D -m 644 start-active.xpm $@

install: ${HOME}/lib/icons/start-hovered.xpm
${HOME}/lib/icons/start-hovered.xpm: start-hovered.xpm
	install -D -m 644 start-hovered.xpm $@

install: ${HOME}/lib/icons/start-inactive.xpm
${HOME}/lib/icons/start-inactive.xpm: start-inactive.xpm
	install -D -m 644 start-inactive.xpm $@

icons: ${ICO16}

.PHONY: all install icons
