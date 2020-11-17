setxkbmap se
xrandr --output VGA-1 --mode 2560x1440
feh --bg-scale cyberpunk.jpg
xrdb -merge $HOME/.Xresources
exec dbus-launch --sh-syntax --exit-with-session $HOME/scripts/startdwm
