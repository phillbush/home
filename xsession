#!/bin/sh

set -m

MODIFIER=1
NDESKS=10

# commands to run when terminate the script
atexit() {
	rm -rf "$tmpdir"
	kill -TERM -- -$$ $(printf "-%s " $(jobs -p))
}

# print desktop number and format it for xnotify(1)
notifydesk() {
	shodc desks | awk -F '[-*: ]' -v NDESKS="$NDESKS" '
		BEGIN  { printf "%s", "SEC:1\tIMG:'$icon_deskicon'\tTAG:desk\t" }
		NR > 1 { printf " " }
		/^\*/  { printf "●"; next }
		       { printf "○" }
		END    { print "" }
	'
}

# get sensorsd and apmd lines from syslog and format them for xnotify(1)
notifycpu() {
	tail -f /var/log/daemon |\
	awk -v icon_powericon="$icon_powericon" -v icon_hearticon="$icon_hearticon" '
		$5 ~ /^apmd.*:$/ && $0 ~ "external power status: not connected" && $(NF - 2) < 25 {
			printf "SEC:0\tTAG:power\tIMG:%s\tBattery is low: %s\n", icon_powericon, $(NF - 2)
		}
		$5 ~ /^sensorsd.*:$/ && $7 == "exceeds" {
			printf "SEC:5\tTAG:temp\tIMG:%s\tTemperature is at %d°C\n", icon_hearticon, $9
		}
		{
			fflush()
		}
	'
}

# pomodoro timer daemon
pomodoro() {
	pomod |\
	while read -r cycle
	do
		printf 'TAG:pomo\tIMG:%s\t%s\n' "$icon_time" "$cycle"
	done
}

# print current song and format it for xnotify(1)
notifymus() {
	while [ "$#" -gt 0 ] || mpc current --wait >/dev/null
	do
		s="$(mpc current -f 'SEC:2\tTAG:mpd\t%artist%\t%album%\t[[%title%]|[%name%]|[%file%]]')"
		if ffmpeg -y -i "$MUSICDIR/$(mpc current -f '%file%')" -f image2 "$coverfile" 2>/dev/null
		then
			printf 'IMG:%s\t%s\n' "$coverfile" "$s"
		else
			printf '%s\n' "$s"
		fi
		set --
	done
}

# generate prompt cache
genprompt() {
	echo "run	Run application"
	run | sed 's/^/	/'

	echo "mus	Play music"
	mus help | sed 's/^/	/'

	echo "pomo	Pomodoro timer"
	echo "	start	Start new pomodoro"
	echo "	stop	Stop current pomodoro"
	echo "	info	Get information about current pomodoro cycle"

	echo "scrot	Take screenshot"
	scrot help | sed 's/^/	/'

	echo "win	Control windows"
	win help | sed 's/^/	/'

	echo "man	Read manual"
	xman | sed 's/^/	/'

	echo "desk	Change desktop"
	echo "	next	Cycle through desktops in monitor forwards"
	echo "	prev	Cycle through desktops in monitor backwards"
	echo "	last	Go to last desktop in monitor"

	echo "term	Start terminal"

	echo "open	Open file"

	echo "exit	Exit X session"
}

# call xbindecho and feed it some commands
keys() {
	xbindecho $MODIFIER <<-EOF
		t       term
		T       term same
		1       desk 1
		2       desk 2
		3       desk 3
		4       desk 4
		5       desk 5
		6       desk 6
		7       desk 7
		8       desk 8
		9       desk 9
		S:1     desk +1
		S:2     desk +2
		S:3     desk +3
		S:4     desk +4
		S:5     desk +5
		S:6     desk +6
		S:7     desk +7
		S:8     desk +8
		S:9     desk +9
		Tab     tab next
		S:Tab   tab prev
		h       focus -L
		j       focus -B
		k       focus -T
		l       focus -R
		H       focus -l
		J       focus -b
		K       focus -t
		L       focus -r
		Q       win close
		c       win resize 0 0 -25 0
		C       win resize 0 0 +25 0
		v       win resize 0 0 0 -25
		V       win resize 0 0 0 +25
		S       win sticky
		A       win above
		B       win below
		Z       win minimize
		F       win fullscreen
		W       win maximize
		Escape  notify clear
	EOF
}

# call xprompt and feed it some commands
prompt() {
	xkeyecho $MODIFIER space "" |\
	while read -r
	do
		xprompt -afi "exec:" <"$HOME/var/cache/xprompt.cache"
	done
}

# call pmenu and feed it some commands
menu() {
	pmenu -p -m 4 -r 3 <<EOF
IMG:$icon_apps	applications
$(run -i -a "$HOME/var/apps/utilities" | awk 'BEGIN{FS=OFS="\t"} {print "", $1, $2, "run "$3}')
IMG:$icon_win	minimized windows	\$ shodc list -l | awk 'BEGIN {FS = "\t"} /^...m/ && \$4 == \$6 {print substr(\$7, 1, 16) "\twin minimize " \$6}'
IMG:$icon_scrot	take screenshot	scrot select
IMG:$icon_media	music
	IMG:$icon_media_forward	next song	mus next
	IMG:$icon_media_stop	stop song	mus stop
	IMG:$icon_media_backward	previous song	mus prev
	IMG:$icon_media_toggle	play/pause	mus toggle
IMG:$icon_terminal	draw terminal	term draw
IMG:$icon_games	games
$(run -i -a "$HOME/var/apps/games" | awk 'BEGIN{FS=OFS="\t"} {print "", $1, $2, "run "$3}')
EOF
}

# interpret desktop commands
xinterp() {
	while read -r cmd args
	do
		case "$cmd" in
		'#'*)
			;;
		'!'*)
			"${cmd#"!"}" $args >/dev/null
			;;
		db)
			genprompt > "$HOME/var/cache/xprompt.cache"
			;;
		run)
			run $args >/dev/null
			;;
		notify)
			case "$args" in
			clear)
				pkill -SIGUSR1 xnotify
				;;
			esac
			;;
		mus)
			if [ -n "$args" ]
			then
				mus $args
			else
				notifymus 1
			fi
			;;
		scrot)
			scrot $args && printf 'IMG:%s\tScreenshot Taken\n' "$icon_scrot"
			;;
		man)
			xman $args
			;;
		term)
			case "$args" in
			draw) drawterm   ;;
			same) samedir    ;;
			*)    ${TERMCMD} ;;
			esac >/dev/null
			;;
		open)
			xopen "$args"
			;;
		desk)
			case "$args" in
			+*)
				shodc sendto "${args#"+"}"
				notifydesk
				;;
			*)
				shodc goto "${args}"
				notifydesk
				;;
			esac
			;;
		focus)
			shodc focus $args
			;;
		tab)
			case "$args" in
			next)
				shodc focus -cN
				;;
			prev)
				shodc focus -cP
				;;
			esac
			;;
		win)
			set -- $args
			oper="$1"
			shift
			case "$oper" in
			resize*)
				shodc geom -r -x "$1" -y "$2" -w "$3" -h "$4"
				;;
			redraw)
				shodc geom $(slop -f "-x %x -y %y -w %w -h %h") $1
				;;
			close)
				shodc close $1
				;;
			stick|sticky)
				shodc state -s $1
				;;
			above)
				shodc state -a $1
				;;
			below)
				shodc state -b $1
				;;
			minimize)
				shodc state -m $1
				;;
			fullscreen)
				shodc state -f $1
				;;
			maximize)
				shodc state -M $1
				;;
			esac
			;;
		pomo)
			case "$args" in
			info)
				printf 'TAG:pomo\tIMG:%s\t%s\n' "$icon_time" "$(pomo info)"
				;;
			*)
				pomo "$args"
				;;
			esac
			;;
		exit)
			pkill shod
			;;
		esac &
	done
}

# create temporary directory and named pipes
tmpdir=$(mktemp -d "${TMPDIR:-"/tmp"}/xsession.XXXXXXXXXX")
xinterpfifo="$tmpdir/xinterp.fifo"
xnotifyfifo="$tmpdir/xnotify.fifo"
coverfile="$tmpdir/cover.png"
chmod 700 "$tmpdir"
mkfifo "$xinterpfifo" "$xnotifyfifo"

# kill background jobs on exit
trap 'atexit' EXIT

# Load environment variables and xresources
. $HOME/.profile
expenv $HOME/rules/xresources | xrdb -merge -load -

# set icon variables
{
	read icon_powericon
	read icon_hearticon
	read icon_deskicon
	read icon_apps
	read icon_games
	read icon_win
	read icon_scrot
	read icon_media
	read icon_media_forward
	read icon_media_stop
	read icon_media_backward
	read icon_media_toggle
	read icon_terminal
	read icon_time
} <<-EOF
	$(
	icon -s 128 \
		battery-caution \
		dialog-warning \
		user-desktop \
		applications-other \
		applications-games \
		preferences-system-windows \
		screenshooter \
		media-optical \
		media-seek-forward \
		media-playback-stop \
		media-seek-backward \
		media-playback-toggle \
		terminal \
		appointment-soon
	)
EOF

# Load keymap
xkbcomp $RULESDIR/xkeymap $DISPLAY 2>/dev/null

# Set cursor
xsetroot -cursor_name left_ptr

# fonts
#export FONTCONFIG_PATH="$HOME/theme/fonts:/etc/fonts"
xset +fp $HOME/theme/fonts
xset fp rehash

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
feh --no-fehbg --bg-tile "$HOME/theme/wallpaper.png"

# compositor
picom -c -l -15 -t -15 \
      --shadow-radius 15 \
      --shadow-green 1.0 \
      --shadow-blue 1.0 \
      --no-dock-shadow \
      --no-dnd-shadow \
      --shadow-exclude '!focused' &

# music daemon
mpd

# desktop notifications
xnotify -ws 10 <"$xnotifyfifo" &
notifycpu >"$xnotifyfifo" &
notifymus >"$xnotifyfifo" &
pomodoro >"$xnotifyfifo" &

# desktop interpreter
xinterp <"$xinterpfifo" >"$xnotifyfifo" &

# command system (menu, prompt, keybindings)
keys   >"$xinterpfifo" &
prompt >"$xinterpfifo" &
menu   >"$xinterpfifo" &

# dockapps
wmwlmon &
bubblemon &
wmapm &
wmclock &

# window manager
shod
