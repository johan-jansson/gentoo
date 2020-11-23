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

source /etc/profile
emerge --sync
emerge -uDN @world
echo "Europe/Stockholm" > /etc/timezone
emerge --config sys-libs/timezone-data
sed -i 's/clock="UTC"/clock="local"/' /etc/conf.d/hwclock
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set 4
source /etc/profile
env-update
sed -i 's/keymap="us"/keymap="sv-latin1"/' /etc/conf.d/keymaps
emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware app-arch/lz4
mv /root/config /usr/src/linux/.config
cd /usr/src/linux
make && make install
echo "hostname=\"mercury\"" > /etc/conf.d/hostname
echo "dns_domain_lo=\"lind\"" > /etc/conf.d/net
echo "config_enp0s3=\"dhcp\"" >> /etc/conf.d/net
emerge --noreplace net-misc/netifrc
ln -s /etc/init.d/net.lo /etc/init.d/net.enp0s3 
rc-update add net.enp0s3 default
echo "127.0.0.1 mercury.lind mercury localhost" > /etc/hosts
emerge net-misc/dhcpcd      # dhcp client
emerge app-admin/sysklogd   # syslogger
emerge sys-process/cronie   # cron daemon
rc-update add sysklogd default
rc-update add cronie default
mv /root/fstab /etc/fstab
emerge sys-boot/grub:2      # boot loader
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/' /etc/default/grub
sed -i 's/#GRUB_GFXPAYLOAD_LINUX=/GRUB_GFXPAYLOAD_LINUX=keep/' /etc/default/grub

#minimal xorg
emerge x11-base/xorg-server             # xorg server
emerge x11-libs/libX11                  # xlib library, for application interactions with x-server
emerge x11-libs/libXft                  # proper font rendering
emerge x11-apps/xrandr                  # convenient resolution/bit depth changes (not just via xorg.conf)
emerge x11-libs/libXrandr               # associated xrandr libraries
emerge x11-libs/libXinerama             # multi-monitor support
emerge x11-apps/xinit                   # startx script (maybe not necessary if using login manager)
emerge x11-apps/xrdb                    # allows reading from xresources file, ex for terminal coloring
emerge x11-apps/mesa-progs              # open source implementation of opengl
emerge x11-misc/xclip                   # clipboard communication between terminals and x
emerge x11-apps/setxkbmap               # allows changing of keyboard layout in x
emerge x11-drivers/xf86-video-nouveau   # video card drivers
emerge sys-apps/dbus                    # dependency for elogind to work
emerge sys-auth/elogind                 # required to run xorg as a non-root user
rc-update add dbus default              # start dbus at boot
rc-update add elogind default           # start elogind at boot

# clean up
emerge --depclean
rm /stage3*
emerge doas
echo "permit :wheel" > /etc/doas.conf
useradd -m -G users,wheel,audio,video,input johan
passwd johan
passwd -d root

exit
