#!/bin/sh

set -m

MODIFIER=1
NDESKS=10

# commands to run when terminate the script
atexit() {
	rm -rf "$tmpdir"
	kill -TERM -- -$$ $(printf "-%s " $(jobs -p))
}

# get desktop in given direction while cycling (prev, next, last)
getdesk() {
	case "$1" in
	*[!0-9]*)
		lsd | awk -v DIR="$1" -v NDESKS="$NDESKS" '
			/^\*/ { curr = NR }
			END   {
				if (DIR == "prev") {
					if (curr > 1)
						print curr - 2
					else
						print NR - 1
				} else if (DIR == "next") {
					if (curr + 1 < NDESKS)
						print curr
					else
						print 0
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
			found = 1
			sel = n
			tabs[n++] = $6
			next
		}
		END {
			if (!found)
				exit
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
	lsd | awk -F '[-*: ]' -v NDESKS="$NDESKS" '
		BEGIN        { printf "%s", "SEC:1\tIMG:'$icon_deskicon'\tTAG:desk\t" }
		NR > 1 && !n { printf " " }
		/^\*/        { printf "●";  n = 0 }
		/^ /         { printf "○";  n = 0 }
		NR == NDESKS { printf "\t"; n = 1 }
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
		C       win resize 0 0 +25 0
		v       win resize 0 0 0 -25
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
	pmenu -p -m 4 -r 3 <<EOF
IMG:$icon_apps	applications
$(run -i -a "$HOME/var/apps/utilities" | awk 'BEGIN{OFS="\t"} {print "", $1, $2, "run "$2}')
IMG:$icon_win	minimized windows	\$ lsc -l | awk 'BEGIN {FS = "\t"} /^......h/ {print substr(\$7, 1, 16) "\twin minimize", \$6}'
IMG:$icon_scrot	take screenshot	scrot select
IMG:$icon_media	music
	IMG:$icon_media_forward	next song	mus next
	IMG:$icon_media_stop	stop song	mus stop
	IMG:$icon_media_backward	previous song	mus prev
	IMG:$icon_media_toggle	play/pause	mus toggle
IMG:$icon_terminal	draw terminal	term draw
IMG:$icon_games	games
$(run -i -a "$HOME/var/apps/games" | awk 'BEGIN{OFS="\t"} {print "", $1, $2, "run "$2}')
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
			set -- $args
			case "$1" in
			resize*)
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
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -e "$(slop -f "0,%x,%y,%w,%h")"
				else
					wmctrl -r :ACTIVE: -e "$(slop -f "0,%x,%y,%w,%h")"
				fi
				;;
			close)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ic "$2"
				else
					wmctrl -c :ACTIVE:
				fi
				;;
			stick|sticky)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,sticky
				else
					wmctrl -r :ACTIVE: -b toggle,sticky
				fi
				;;
			above)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,above
				else
					wmctrl -r :ACTIVE: -b toggle,above
				fi
				;;
			below)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,below
				else
					wmctrl -r :ACTIVE: -b toggle,below
				fi
				;;
			minimize)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,hidden
				else
					wmctrl -r :ACTIVE: -b toggle,hidden
				fi
				;;
			fullscreen)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,fullscreen
				else
					wmctrl -r :ACTIVE: -b toggle,fullscreen
				fi
				;;
			shade|shaded)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,shaded
				else
					wmctrl -r :ACTIVE: -b toggle,shaded
				fi
				;;
			maximize)
				if [ "$#" -gt 1 ]
				then
					wmctrl -ir "$2" -b toggle,maximized_horz,maximized_vert
				else
					wmctrl -r :ACTIVE: -b toggle,maximized_horz,maximized_vert
				fi
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
expenv $HOME/rules/xresources | xrdb -

# set icon variables
{
	read icon_powericon
	read icon_hearticon
	read icon_deskicon
	read icon_apps
	read icon_games
	read icon_win
	read icon_winclose
	read icon_winfullscreen
	read icon_winrestore
	read icon_winresize
	read icon_scrot
	read icon_media
	read icon_media_forward
	read icon_media_stop
	read icon_media_backward
	read icon_media_toggle
	read icon_terminal
	read icon_golast
	read icon_goprev
	read icon_gonext
	read icon_time
} <<-EOF
	$(
	icon 128 s <<-_EOF | iconcache 128
		poweroff-cpu
		heart
		user-desktop
		applications-other
		applications-games
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
		media-playback-toggle
		terminal
		go-last
		go-previous
		go-next
		time
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

# window manager
shod
