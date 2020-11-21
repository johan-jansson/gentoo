
# POST-POST-INSTALL
sudo emerge sys-apps/dbus elogind
sudo rc-update add dbus default
sudo rc-update add elogind boot
sudo rc-update add elogind default
sudo rc-service elogind start
sudo emerge xorg-server xorg-drivers xrandr setxkbmap
sudo emerge dwm st dmenu
mkdir ~/scripts/
!!cp startdwm ~/scripts/
chmod +x ~/scripts/startdwm
!!cp xinitrc ~/.xinitrc
startx
