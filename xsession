#!/bin/sh

MODIFIER=1

# commands to run when terminate the script
atexit() {
	rm -rf "$tmpdir"
	kill -TERM 0
}

# run window manager and format its output for xnotify(1)
wm() {
	# shod output the geometry of windows when they're resized/moved with mouse
	shod | \
	sed -u 's/^\([0-9]*\)x\([0-9]*\)\([+-][0-9]*\)\([+-][0-9]*\)$/SEC:1	TAG:shod	\3 \4	\1 × \2/'
}

# get desktop in given direction while cycling (prev, next, last)
getdesk() {
	case "$1" in
	*[!0-9]*)
		lsd | awk -F '[-*: ]+' -v DIR="$1" '
			/^\*/ { curr = NR }
		      	      { wins[NR] = $2 }
			END   {
				for (i = curr - 1; wins[i] && i > 0; i--)
					;
				first = i
				for (i = curr; wins[i] && i <= NR; i++)
					;
				last = i - 1

				if (DIR == "prev") {
					if (wins[curr - 1])
						print curr - 2
					else
						print last
				} else if (DIR == "next") {
					if (wins[curr])
						print curr
					else
						print first
				} else {
					print last
				}
			}
		'
		;;
	*)
		echo $1
		;;
	esac
}

# get frame/window in given direction (prev, next)
getframe() {
	lsc -ls -g _SHOD_TAB_GROUP | awk -v DIR="$1" '
		function cmp(framea, frameb,    a, b) {
			split(geom[framea], a, /[-x+]/)
			split(geom[frameb], b, /[-x+]/)
			if (geom[framea] ~ /^[0-9]+x[0-9]+-/)
				a[X] = - a[X]
			if (geom[framea] ~ /-[0-9]+$/)
				a[Y] = - a[Y]
			if (geom[frameb] ~ /^[0-9]+x[0-9]+-/)
				b[X] = - b[X]
			if (geom[frameb] ~ /-[0-9]+$/)
				b[Y] = - b[Y]
			if (DIR == "right") {
				if (b[Y] == s[Y] && b[X] > s[X])
					return 1
				if (a[X] < b[X])
					return 1
			} else if (DIR == "left") {
				if (b[Y] == s[Y] && b[X] < s[X])
					return 1
				if (a[X] > b[X])
					return 1
			} else if (DIR == "down") {
				if (b[X] == s[X] && b[Y] > s[Y])
					return 1
				if (a[Y] < b[Y])
					return 1
			} else if (DIR == "up") {
				if (b[X] == s[X] && b[Y] < s[Y])
					return 1
				if (a[Y] > b[Y])
					return 1
			}
			return 0
		}
		{
			if (!geom[$4]) {
				geom[$4] = $3
				nframes[$2]++
			}
			frames[$2, nframes[$2]] = $4
		}
		substr($1, 11, 1) == "A" {
			sel = $4
			desk = $2
			split(geom[sel], s, /[-x+]/)
			if (geom[sel] ~ /^[0-9]+x[0-9]+-/)
				s[X] = - s[X]
			if (geom[sel] ~ /-[0-9]+$/)
				s[Y] = - s[Y]
		}
		BEGIN {
			W = 1
			H = 2
			X = 3
			Y = 4
		}
		END {
			if (DIR == "prev") {
				print frames[desk, (nframes[desk] + sel - 1) % nframes[desk]]
			} else if (DIR == "next") {
				print frames[desk, (sel + 1) % nframes[desk]]
			} else {
				curr = sel
				for (i = 1; i <= nframes[desk]; i++) {
					if (sel != frames[desk, i] && cmp(curr, frames[desk, i])) {
						curr = frames[desk, i]
					}
				}
				print curr
			}
		}
	'
}

# get tab in given direction while cycling (prev, next)
gettab() {
	lsc -ls -g _SHOD_TAB_GROUP | awk -v DIR="$1" '
		substr($1, 11, 1) == "f" {
			tabs[n++] = $6
			next
		}
		substr($1, 11, 1) == "A" {
			sel = n
			tabs[n++] = $6
			next
		}
		END {
			if (DIR == "prev") {
				print tabs[(n + sel - 1) % n]
			} else {
				print tabs[(sel + 1) % n]
			}
		}
	'
}

# print desktop number and format it for xnotify(1)
notifydesk() {
	lsd | awk -F '[-*: ]' '
		BEGIN        { printf "%s", "SEC:1\tIMG:'$icon_deskicon'\tTAG:desk\t" }
		NR > 1 && !n { printf " " }
		/^\*/        { printf "●";  n = 0 }
		/^ /         { printf "○";  n = 0 }
		$2 == 0      { printf "\t"; n = 1 }
		END          { print "" }
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

	echo "scrot	Take screenshot"
	scrot help | sed 's/^/	/'

	echo "wm	Control windows"
	wm help | sed 's/^/	/'

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
		D       desk
		1       desk 0
		2       desk 1
		3       desk 2
		4       desk 3
		5       desk 4
		6       desk 5
		7       desk 6
		8       desk 7
		9       desk 8
		S:1     desk +0
		S:2     desk +1
		S:3     desk +2
		S:4     desk +3
		S:5     desk +4
		S:6     desk +5
		S:7     desk +6
		S:8     desk +7
		S:9     desk +8
		Tab     tab next
		S:Tab   tab prev
		h       focus left
		j       focus down
		k       focus up
		l       focus right
		Q       win close
		H       win resize -10 0 0 0
		J       win resize 0 10 0 0
		K       win resize 0 -10 0 0
		L       win resize 10 0 0 0
		c       win resize 0 0 -25 0
		C       win resize 0 0 0 -25
		v       win resize 0 0 +25 0
		V       win resize 0 0 0 +25
		S       win sticky
		A       win above
		B       win below
		Z       win minimize
		F       win fullscreen
		N       win shade
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
	pmenu -tp -m 4 -r 3 <<EOF
IMG:$icon_apps
$(run -i | sed 's/	/&run /; s/^/	/')
IMG:$icon_win
	IMG:$icon_winclose	wm close
	IMG:$icon_winfullscreen	wm maximize
	IMG:$icon_winrestore	wm minimize
	IMG:$icon_winresize	wm resize
IMG:$icon_scrot	scrot select
IMG:$icon_media
	IMG:$icon_media_forward	mus next
	IMG:$icon_media_stop	mus stop
	IMG:$icon_media_backward	mus prev
	IMG:$icon_media_pause	mus toggle
IMG:$icon_terminal	term draw
IMG:$icon_deskicon
	IMG:$icon_golast	desk last
	IMG:$icon_goprev	desk prev
	IMG:$icon_gonext	desk next
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
			scrot $args && printf 'IMG:%s Screenshot Taken\n' "$icon_scrot"
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
			"")
				showdesk=$(wmctrl -m | awk 'NR == 4 { print $NF }')
				case "$showdesk" in
				OFF) wmctrl -k on ;;
				*) wmctrl -k off ;;
				esac
				;;
			+*)
				operation="-r :ACTIVE: -t"
				wmctrl $operation $(getdesk ${args#"+"})
				notifydesk
				;;
			*)
				operation="-s"
				wmctrl $operation $(getdesk ${args})
				notifydesk
				;;
			esac
			;;
		focus)
			wmctrl -ia $(getframe $args)
			;;
		tab)
			wmctrl -ia $(gettab $args)
			;;
		win)
			case "$args" in
			resize*)
				set -- $args
				eval $(xdotool getactivewindow getwindowgeometry --shell)
				xadd=$2
				yadd=$3
				wadd=$4
				hadd=$5
				X=$(( X + xadd ))
				Y=$(( Y + yadd ))
				WIDTH=$(( WIDTH + wadd ))
				HEIGHT=$(( HEIGHT + hadd ))
				wmctrl -r :ACTIVE: -e 0,$X,$Y,$WIDTH,$HEIGHT
				;;
			redraw)
				wmctrl -r :ACTIVE: -e "$(slop -f "0,%x,%y,%w,%h")"
				;;
			close)
				wmctrl -c :ACTIVE:
				;;
			stick|sticky)
				wmctrl -r :ACTIVE: -b toggle,sticky
				;;
			above)
				wmctrl -r :ACTIVE: -b toggle,above
				;;
			below)
				wmctrl -r :ACTIVE: -b toggle,below
				;;
			fullscreen)
				wmctrl -r :ACTIVE: -b toggle,fullscreen
				;;
			shade|shaded)
				wmctrl -r :ACTIVE: -b toggle,shaded
				;;
			maximize)
				wmctrl -r :ACTIVE: -b toggle,maximized_horz,maximized_vert
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
expenv $HOME/rules/xresources | xrdb -

# set icon variables
{
	read icon_powericon;
	read icon_hearticon;
	read icon_deskicon;
	read icon_apps;
	read icon_win;
	read icon_winclose
	read icon_winfullscreen
	read icon_winrestore
	read icon_winresize
	read icon_scrot
	read icon_media
	read icon_media_forward
	read icon_media_stop
	read icon_media_backward
	read icon_media_pause
	read icon_terminal
	read icon_golast
	read icon_goprev
	read icon_gonext
} <<-EOF
	$(
	icon 128 s <<-_EOF | iconcache 128
		poweroff-cpu
		heart
		user-desktop
		applications-other
		preferences-system-windows
		window-close
		view-fullscreen
		view-restore
		window-resize
		applets-screenshooter
		cd-audio
		media-seek-forward
		media-playback-stop
		media-seek-backward
		media-playback-pause
		terminal
		go-last
		go-previous
		go-next
	_EOF
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
xnotify -s 10 <"$xnotifyfifo" &
notifycpu >"$xnotifyfifo" &
notifymus >"$xnotifyfifo" &

# desktop interpreter
xinterp <"$xinterpfifo" >"$xnotifyfifo" &

# command system (menu, prompt, keybindings)
keys   >"$xinterpfifo" &
prompt >"$xinterpfifo" &
menu   >"$xinterpfifo" &

# window manager
wm >"$xnotifyfifo"
