#!/bin/sh
# ~/.profile

# installation prefixes
PATH="$PATH:/usr/local/jdk-11/bin:/usr/local/heirloom-doctools/bin:/usr/local/plan9/bin"
MANPATH="$MANPATH:/usr/local/jdk-11/man:/usr/local/heirloom-doctools/man:/usr/local/plan9/man"
for dir in $HOME/usr/*
do
	test -d "$dir/bin"       && PATH="$dir/bin${PATH:+":"}$PATH"
	test -d "$dir/man"       && MANPATH="$dir/man${MANPATH:+":"}$MANPATH"
done
unset dir
export PATH HOME TERM MANPATH

# hostname of my local machine, used in some scripts
export LOCALHOST="thinkbsd"     # thinkpad + bsd

# local installation directories
export GOPATH="$HOME/usr/go"
export PYTHONUSERBASE="$HOME/usr/python"
export CHIBI_MODULE_PATH="$HOME/usr/scheme/lib"
export PREFIX="$HOME/usr/local"
export MANPREFIX="$PREFIX/man"

# ksh terminal session
export ENV="$HOME/.session"

# Locale and timezone
export LANG=pt_BR.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_COLLATE=C
export TZ="America/Sao_Paulo"

# Directories
#export TMPDIR="/tmp"
#export MAIL=$HOME/var/mail
export SKEL="$HOME/skel"
export RULESDIR="$HOME/rules"
export MUSICDIR="$HOME/files/mus/"
export APPPATH="$HOME/var/apps/utilities:$HOME/var/apps/games"
export CACHEDIR="$HOME/var/cache"
export RLWRAP_HOME="$HOME/var/history"
export TRASH="$HOME/var/trash"
export CALENDAR_DIR="$HOME/proj"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.data"

# Rule files
export MIMEFILE="$HOME/rules/mime"
export XCOMPOSEFILE="$HOME/rules/xcompose"
export IRCSERVERSFILE="$HOME/rules/irc.servers"
export IRCRC="$HOME/rules/ircrc"
export EXINIT=":so $HOME/rules/exrc"
export VIMINIT=":source $HOME/rules/vimrc"
#export FONTCONFIG_FILE="$HOME/rules/fontconfig"

# phillbush
export IRCNAME="phillbush"
export IRCNICK="phillbush"
export GIT_PAGER=cat
export GIT_COMMITTER_NAME="phillbush"
export GIT_COMMITTER_EMAIL="phillbush@cock.li"
export GIT_AUTHOR_NAME="phillbush"
export GIT_AUTHOR_EMAIL="phillbush@cock.li"

# Default programs
export PAGER="less"
export EDITOR="vim"
export VISUAL="vim"
export OPENER="open"
export TERMCMD="xterm"
export THUMBNAILER="thumbnail"

# Theme
#export XENVIRONMENT="$HOME/theme/xresources"
export XCURSOR_PATH="$HOME/theme/cursor"
export XCURSOR_THEME="retrosmart"
export ICONPATH="$HOME/theme/icons"
export ICONSIZE=64
export TROFFONTS="$HOME/theme/fonts/LinuxLibertine"

# Less
export LESS='-Sr~ -z-5 '
export LESSOPEN='|preview %s'

# XPrompt
export XPROMPTHISTFILE="$HOME/var/history/xprompt.hist"
export XPROMPTHISTSIZE=100

# Firefox
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1

# GTK
export GTK_IM_MODULE="xim"

# Nethack
export NETHACKOPTIONS="windowtype:X11,name:matador,!autopickup,color,lit_corridor,hilite_pet,hilite_pile,herecmd_menu,hitpointbar,menucolors,clicklook,extmenu,mouse_support,showexp"

# no dbus
export DBUS_SESSION_BUS_ADDRESS=no

# dircolors; used by colortree(1)
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:or=01;05;37;41:mi=01;05;37;41:do=01;46:bd=01;44:cd=01;44:ex=01;32:*Makefile=04;01:*README=04;01:*README.md=04;01:*TODO=04;01:*.7Z=00;31:*.7z=00;31:*.BZ=00;31:*.bz=00;31:*.GZ=00;31:*.gz=00;31:*.BZ2=00;31:*.bz2=00;31:*.ISO=00;31:*.iso=00;31:*.RAR=00;31:*.rar=00;31:*.TAR=00;31:*.tar=00;31:*.ZIP=00;31:*.zip=00;31:*.BMP=00;33:*.bmp=00;33:*.GIF=00;33:*.gif=00;33:*.ICO=00;33:*.ico=00;33:*.JPE=00;33:*.jpe=00;33:*.JPEG=00;33:*.jpeg=00;33:*.JPG=00;33:*.jpg=00;33:*.MNG=00;33:*.mng=00;33:*.PBM=00;33:*.pbm=00;33:*.PCX=00;33:*.pcx=00;33:*.PGM=00;33:*.pgm=00;33:*.PNG=00;33:*.png=00;33:*.PPM=00;33:*.ppm=00;33:*.PSD=00;33:*.psd=00;33:*.SVG=00;33:*.svg=00;33:*.TGA=00;33:*.tga=00;33:*.TIF=00;33:*.tif=00;33:*.TIFF=00;33:*.tiff=00;33:*.XBM=00;33:*.xbm=00;33:*.XPM=00;33:*.xpm=00;33:*.AAC=00;35:*.aac=00;35:*.AU=00;35:*.au=00;35:*.FLAC=00;35:*.flac=00;35:*.MID=00;35:*.mid=00;35:*.MIDI=00;35:*.midi=00;35:*.MKA=00;35:*.mka=00;35:*.MP3=00;35:*.mp3=00;35:*.MPC=00;35:*.mpc=00;35:*.OGG=00;35:*.ogg=00;35:*.RA=00;35:*.ra=00;35:*.WAV=00;35:*.wav=00;35:*.ASF=00;35:*.asf=00;35:*.AVI=00;35:*.avi=00;35:*.DL=00;35:*.dl=00;35:*.FLC=00;35:*.flc=00;35:*.FLI=00;35:*.fli=00;35:*.GL=00;35:*.gl=00;35:*.M2V=00;35:*.m2v=00;35:*.M4V=00;35:*.m4v=00;35:*.MKV=00;35:*.mkv=00;35:*.MOV=00;35:*.mov=00;35:*.MP4=00;35:*.webm=00;35:*.mp4=00;35:*.MP4V=00;35:*.mp4v=00;35:*.MPEG=00;35:*.mpeg=00;35:*.MPG=00;35:*.mpg=00;35:*.NUV=00;35:*.nuv=00;35:*.OGM=00;35:*.ogm=00;35:*.QT=00;35:*.qt=00;35:*.RM=00;35:*.rm=00;35:*.RMVB=00;35:*.rmvb=00;35:*.VOB=00;35:*.vob=00;35:*.WMV=00;35:*.wmv=00;35:*.XCF=00;35:*.xcf=00;35:*.XWD=00;35:*.xwd=00;35:*.YUV=00;35:*.yuv=00;35:'

umask 022
