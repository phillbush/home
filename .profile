#!/bin/sh
# ~/.profile

# set hierarchies where paths are searched
HIER="$(echo $HOME/usr/* | /usr/bin/tr ' ' ':')"
HIER="$HIER:/usr"
HIER="$HIER:/usr/X11R6:/usr/games:/usr/local"
HIER="$HIER:/usr/local/heirloom-doctools"
HIER="$HIER:/usr/local/plan9"
HIER="$HIER:/usr/local/jdk-11"
PATH="/bin:/sbin"

# set paths
for dir in $(echo $HIER | /usr/bin/tr ':' ' ')
do
	/bin/test -d "$dir/bin"       && PATH="$PATH${PATH:+:}$dir/bin"
	/bin/test -d "$dir/sbin"      && PATH="$PATH${PATH:+:}$dir/sbin"
	/bin/test -d "$dir/man"       && MANPATH="$MANPATH${MANPATH:+:}$dir/man"
	/bin/test -d "$dir/share/man" && MANPATH="$MANPATH${MANPATH:+:}$dir/share/man"
	/bin/test -d "$dir/jar"       && JARPATH="$JARPATH${JARPATH:+:}$dir/jar"
done
unset dir
export PATH HOME TERM MANPATH JARPATH

# local installation directories
export PREFIX="$HOME/usr/local"
export MANPREFIX="$PREFIX/man"

# ksh
export ENV="$HOME/.session"

# Locale
export LANG=pt_BR.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_COLLATE=C

# Directories
#export MAIL=~/mail
#export TMPDIR="$HOME/tmp"
export SKEL="$HOME/skel"
export TRASH="$HOME/trash"
export APPPATH="$HOME/apps"
export RULESDIR="$HOME/rules"
export MUSICDIR="$HOME/files/mus/"
export CACHEDIR="$HOME/var/cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.data"

# Rule files
export MIMEFILE="$HOME/rules/mime"
export XCOMPOSEFILE="$HOME/rules/xcompose"
export EXINIT=":so $HOME/rules/exrc"
export VIMINIT=":source $HOME/rules/vimrc"
#export FONTCONFIG_FILE="$HOME/rules/fontconfig"

# IRC
export IRCNAME="phillbush"
export IRCNICK="phillbush"
export IRCRC="$HOME/rules/ircrc"

# Default programs
export PAGER="less"
export EDITOR="vim"
export VISUAL="vim"

# GIT
export GIT_PAGER=cat
export GIT_COMMITTER_NAME="phillbush"
export GIT_COMMITTER_EMAIL="phillbush@cock.li"
export GIT_AUTHOR_NAME="phillbush"
export GIT_AUTHOR_EMAIL="phillbush@cock.li"

# Theme
#export XENVIRONMENT="$HOME/theme/xresources"
export XCURSOR_PATH="$HOME/theme/cursor"
export XCURSOR_THEME="retrosmart"
export ICONPATH="$HOME/theme/icons"
export TROFFONTS="$HOME/theme/fonts"

# XPrompt
export XPROMPTHISTFILE="$HOME/var/history/xprompt.hist"
export XPROMPTHISTSIZE=100

# default programs
export OPENER="xopen"
export TERMCMD="xterm"

# Firefox
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1

# Language package managers
export GOPATH="$HOME/usr/go"
export PYTHONUSERBASE="$HOME/usr/python"

# no dbus
export DBUS_SESSION_BUS_ADDRESS=no

# ls
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:or=01;05;37;41:mi=01;05;37;41:do=01;46:bd=01;44:cd=01;44:ex=01;32:*Makefile=04;01:*README=04;01:*README.md=04;01:*TODO=04;01:*.7Z=00;31:*.7z=00;31:*.BZ=00;31:*.bz=00;31:*.GZ=00;31:*.gz=00;31:*.BZ2=00;31:*.bz2=00;31:*.ISO=00;31:*.iso=00;31:*.RAR=00;31:*.rar=00;31:*.TAR=00;31:*.tar=00;31:*.ZIP=00;31:*.zip=00;31:*.BMP=00;33:*.bmp=00;33:*.GIF=00;33:*.gif=00;33:*.ICO=00;33:*.ico=00;33:*.JPE=00;33:*.jpe=00;33:*.JPEG=00;33:*.jpeg=00;33:*.JPG=00;33:*.jpg=00;33:*.MNG=00;33:*.mng=00;33:*.PBM=00;33:*.pbm=00;33:*.PCX=00;33:*.pcx=00;33:*.PGM=00;33:*.pgm=00;33:*.PNG=00;33:*.png=00;33:*.PPM=00;33:*.ppm=00;33:*.PSD=00;33:*.psd=00;33:*.SVG=00;33:*.svg=00;33:*.TGA=00;33:*.tga=00;33:*.TIF=00;33:*.tif=00;33:*.TIFF=00;33:*.tiff=00;33:*.XBM=00;33:*.xbm=00;33:*.XPM=00;33:*.xpm=00;33:*.AAC=00;35:*.aac=00;35:*.AU=00;35:*.au=00;35:*.FLAC=00;35:*.flac=00;35:*.MID=00;35:*.mid=00;35:*.MIDI=00;35:*.midi=00;35:*.MKA=00;35:*.mka=00;35:*.MP3=00;35:*.mp3=00;35:*.MPC=00;35:*.mpc=00;35:*.OGG=00;35:*.ogg=00;35:*.RA=00;35:*.ra=00;35:*.WAV=00;35:*.wav=00;35:*.ASF=00;35:*.asf=00;35:*.AVI=00;35:*.avi=00;35:*.DL=00;35:*.dl=00;35:*.FLC=00;35:*.flc=00;35:*.FLI=00;35:*.fli=00;35:*.GL=00;35:*.gl=00;35:*.M2V=00;35:*.m2v=00;35:*.M4V=00;35:*.m4v=00;35:*.MKV=00;35:*.mkv=00;35:*.MOV=00;35:*.mov=00;35:*.MP4=00;35:*.webm=00;35:*.mp4=00;35:*.MP4V=00;35:*.mp4v=00;35:*.MPEG=00;35:*.mpeg=00;35:*.MPG=00;35:*.mpg=00;35:*.NUV=00;35:*.nuv=00;35:*.OGM=00;35:*.ogm=00;35:*.QT=00;35:*.qt=00;35:*.RM=00;35:*.rm=00;35:*.RMVB=00;35:*.rmvb=00;35:*.VOB=00;35:*.vob=00;35:*.WMV=00;35:*.wmv=00;35:*.XCF=00;35:*.xcf=00;35:*.XWD=00;35:*.xwd=00;35:*.YUV=00;35:*.yuv=00;35:'

umask 022