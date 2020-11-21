#!/bin/bash
# Gentoo installation script, optimized for AMD Ryzen 9 3900X with Zen 2 architecture (24 threads) 
# Based on https://wiki.gentoo.org/wiki/Handbook:AMD64
# Boot: install-amd64-minimal-*.iso
# wget https://github.com/johan-jansson/gentoo/archive/main.zip
#
# gentoo.sh        # main script
# chroot.sh        # chroot operations
# make.conf        # portage config: /etc/portage/make.conf
# config           # kernel config: /usr/src/linux/.config
# fstab            # file system table: /etc/fstab
# post.sh          # post-installation script

# new version (minimal xorg
doas emerge x11-libs/libX11 x11-base/xorg-server x11-libs/libXrandr x11-libs/libXinerama x11-libs/libXft x11-apps/xinit x11-apps/xrdb x11-apps/mesa-progs x11-apps/xrandr x11-misc/unclutter x11-misc/xclip x11-misc/pcmanfm
#doas emerge x11-drivers/xf86-video-vboxvideo # for virtualbox

# old version
#doas emerge sys-apps/dbus elogind
#doas rc-update add dbus default
#doas rc-update add elogind boot
#doas rc-update add elogind default
#doas rc-service elogind start
#doas emerge xorg-server xorg-drivers xrandr setxkbmap
#doas emerge dwm st dmenu
#mkdir ~/scripts/
#!!cp startdwm ~/scripts/
#chmod +x ~/scripts/startdwm
#!!cp xinitrc ~/.xinitrc
#
#startx
