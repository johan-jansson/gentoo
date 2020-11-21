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

doas emerge sys-apps/dbus elogind
doas rc-update add dbus default
doas rc-update add elogind boot
doas rc-update add elogind default
doas rc-service elogind start
doas emerge xorg-server xorg-drivers xrandr setxkbmap
doas emerge dwm st dmenu
mkdir ~/scripts/
!!cp startdwm ~/scripts/
chmod +x ~/scripts/startdwm
!!cp xinitrc ~/.xinitrc

startx
