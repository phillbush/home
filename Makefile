LIBDIR = ${HOME}/lib
SKLDIR = ${HOME}/lib/skel
BINDIR = ${HOME}/usr/home/bin
MANDIR = ${HOME}/usr/home/man

all:
	@echo no need to build

install: dirs envs mans bins libs skels

DIRS = \
       ${HOME}/prj \
       ${HOME}/tmp \
       ${HOME}/var/cache \
       ${HOME}/var/history \
       ${HOME}/var/mail \
       ${HOME}/var/trash \
       ${LIBDIR} \
       ${SKLDIR} \
       ${BINDIR} \
       ${MANDIR}
dirs: ${DIRS}
${DIRS}: $@
	mkdir -p -- $@

envs: ${HOME}/.profile
${HOME}/.profile: profile
	install -D -m 755 profile $@

MANS = ${MANDIR}/man7/home.7
mans: ${MANS}
${MANS}: ./${@:T}
	install -D -m 644 ./${@:T} $@

BINS != for i in execs/* ; do printf "${BINDIR}/%s\n" "`basename "$$i"`" ; done
bins: ${BINS}
${BINS}: execs/${@:T}
	install -D -m 755 execs/${@:T} $@

LIBS != for i in rules/* ; do printf "${LIBDIR}/%s\n" "`basename "$$i"`" ; done
libs: ${LIBS}
${LIBS}: rules/${@:T}
	install -D -m 644 rules/${@:T} $@

SKELS != for i in skels/* ; do printf "${SKLDIR}/%s\n" "`basename "$$i"`" ; done
skels: ${SKELS}
${SKELS}: skels/${@:T}
	install -D -m 644 skels/${@:T} $@

SRCS = profile ${MANS} ${BINS} ${LIBS} ${SKELS} ${ICONS}

gitadd:
	git add Makefile README.md LICENSE ${SRCS}

gitpush:
	# only do this once:
	# git remote add origin git@github.com:phillbush/home.git
	git push -u origin master

.PHONY: all install gitadd gitpush skels libs bins mans envs dirs
