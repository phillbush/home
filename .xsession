#!/bin/sh

trap 'kill $(jobs -p)' EXIT

# Load environment variables
. $HOME/.profile

# Load resources
expenv $HOME/rules/xresources | xrdb -

# set fifo for shell to read commands from (shell run at the end of this file)
export XINTERP_FIFO="$CACHEDIR/xinterp"
rm -f $XINTERP_FIFO
mkfifo $XINTERP_FIFO

# menu system
xclickroot feed "$CACHEDIR/pmenu.cache" pmenu -t >"$XINTERP_FIFO" &

# notification system
export XNOTIFY_FIFO="$CACHEDIR/xnotify"
rm -f $XNOTIFY_FIFO
mkfifo $XNOTIFY_FIFO
xnotify -s 10 0<>$XNOTIFY_FIFO &
export XNOTIFY_PID=$!

# Load keymap
xkbcomp $RULESDIR/xkeymap $DISPLAY 2>/dev/null

# Set cursor
xsetroot -cursor_name left_ptr

# Key bindings
sxhkd -c "$RULESDIR/keybindings" &

# fonts
#export FONTCONFIG_PATH="$HOME/theme/fonts:/etc/fonts"
#xset +fp $HOME/theme/fonts
#xset fp rehash

# make mouse invisible after a brief period
unclutter &

# thinkpad trackpoint
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Axes" 6 7 4 5
synclient TapButton1=1
synclient TapButton2=2
synclient TapButton3=3
synclient AccelFactor=0
synclient HorizTwoFingerScroll=1

# Set background
feh --bg-fill --no-fehbg $HOME/theme/wp/pepe.jpg

# music daemon
mpd >/dev/null 2>&1 && mpdnotify &

# interpreter to run commands from its stdin
xinterp 0<>"$XINTERP_FIFO" &

# check battery and temperature
notify &

# start compositing manager
xcompmgr &

# run window manager
shod | sed -u 's/^\([0-9]*\)x\([0-9]*\)\([+-][0-9]*\)\([+-][0-9]*\)$/SEC:1	TAG:shod	\3 \4	\1 × \2/' >"$XNOTIFY_FIFO"
