#!/bin/bash
# Gentoo installation script, optimized for AMD Ryzen 9 3900X with Zen 2 architecture (24 threads) 
# Based on https://wiki.gentoo.org/wiki/Handbook:AMD64
# Boot: install-amd64-minimal-*.iso
#
# wget https://github.com/johan-jansson/gentoo/install.sh       # this script
# wget https://github.com/johan-jansson/gentoo/make.conf        # portage config: /etc/portage/make.conf
# wget https://github.com/johan-jansson/gentoo/.config          # kernel config: /usr/src/linux/.config
# wget https://github.com/johan-jansson/gentoo/fstab            # file system table: /etc/fstab
# wget https://github.com/johan-jansson/gentoo/grub             # grub main config: /etc/default/grub


# PARTITIONING & FILESYSTEMS
parted -a optimal /dev/nvme0n1
 mklabel gpt
 unit mib
 mkpart primary 1 256
 name 1 EFI
 set 1 boot on
 mkpart primary 257 -1
 name 2 rootfs
quit
mkfs.ext4 /dev/nvme0n1p2
mkfs.vfat /dev/nvme0n1p1
mount /dev/nvme0n1p2 /mnt/gentoo

# GET STAGE 3
cd /mnt/gentoo
wget ftp://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-2020*tar.xz
tar xpf stage3-amd64-*.tar.xz --xattrs-include='*.*' --numeric-owner

# PORTAGE CONFIGURATION
!!cp make.conf /mnt/gentoo/etc/portage/make.conf

# INIT BASE SYSTEM
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="chroot $PS1"
mount /dev/nvme0n1p1 /boot
emerge --sync
emerge -uDN @world
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
# <device>          <dir>   <fs>    <options>           <dump>  <fsck>
# /dev/nvme0n1p1    /boot   vfat    defaults,noatime    0       2
# /dev/nvme0n1p2    /       ext4    noatime,discard     0       1

# GRUB
emerge sys-boot/grub:2
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
!! cp grub /etc/default/grub

# POST-INSTALL
emerge --depclean
rm -f /stage3*
emerge sudo 
nano /etc/sudoers
useradd -m -G users,wheel,audio,video,input johan
passwd johan
sudo su johan
sudo whoami
passwd -d root
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

# POST-POST-INSTALL
sudo emerge mlocate
updatedb
sudo emerge openssh
rc-update add sshd default
rc-service sshd start
emerge -auqvDN @world
sudo emerge sys-apps/dbus elogind
sudo rc-update add dbus default
sudo rc-update add elogind boot
sudo rc-service elogind start
sudo emerge xorg-server xorg-drivers xrandr
sudo emerge dwm st dmenu
mkdir ~/scripts/
!!cp startdwm ~/scripts/
chmod +x ~/scripts/startdwm
!!cp xinitrc ~/.xinitrc
startx
