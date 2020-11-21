#!/bin/bash
# Gentoo installation script, optimized for AMD Ryzen 9 3900X with Zen 2 architecture (24 threads) 
# Based on https://wiki.gentoo.org/wiki/Handbook:AMD64
# Boot: install-amd64-minimal-*.iso
# wget https://github.com/johan-jansson/gentoo/archive/main.zip
#
# gentoo.sh        # main script
# chroot.sh        # chroot operations
# make.conf        # portage config: /etc/portage/make.conf
# .config          # kernel config: /usr/src/linux/.config
# fstab            # file system table: /etc/fstab
# grub             # grub main config: /etc/default/grub

source /etc/profile
emerge --sync
emerge -uqvDN @world
echo "Europe/Stockholm" > /etc/timezone
emerge --config sys-libs/timezone-data
nano -w /etc/conf.d/hwclock # clock="local"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set 4
. /etc/profile
env-update
export PS1="chroot $PS1"
nano -w /etc/conf.d/keymaps

# BUILD LINUX KERNEL
emerge sys-kernel/gentoo-sources
emerge sys-kernel/linux-firmware
emerge app-arch/lz4
!!cp config /usr/src/linux/.config
cd /usr/src/linux
make oldconfig
make && make install

# NETWORK CONFIG
echo "hostname=\"mercury\"" > /etc/conf.d/hostname
echo "dns_domain_lo=\"lind\"" > /etc/conf.d/net
echo "config_enp0s3=\"dhcp\"" >> /etc/conf.d/net
emerge --noreplace net-misc/netifrc
cd /etc/init.d
ln -s net.lo net.enp0s3 
rc-update add net.enp0s3 default
echo "127.0.0.1 mercury.lind mercury localhost" > /etc/hosts
emerge net-misc/dhcpcd

# SYSTEM TOOLS
emerge app-admin/sysklogd
rc-update add sysklogd default
emerge sys-process/cronie
rc-update add cronie default

# PARTITION TABLE
!!cp fstab /etc/fstab
swapon -a
# <device>          <dir>   <fs>    <options>           <dump>  <fsck>
# /dev/nvme0n1p1    /boot   vfat    defaults,noatime    0       2
# /dev/nvme0n1p2    /       ext4    noatime,discard     0       1
# /swap             none    swap    sw,loop             0       0

# GRUB
emerge sys-boot/grub:2
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
!! cp grub /etc/default/grub

# POST-INSTALL
emerge --depclean
rm -f /stage3*
emerge doas 
nano /etc/doas.conf
permit :wheel
useradd -m -G users,wheel,audio,video,input johan
passwd johan
doas su johan
doas whoami
passwd -d root
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

# POST-POST-INSTALL
emerge -uDN @world                    # necessary here?
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

