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

parted /dev/nvme1n1 mklabel gpt
parted /dev/nvme1n1 unit mib
parted /dev/nvme1n1 mkpart primary 1 512 # 512 Mb /boot
parted /dev/nvme1n1 name 1 EFI
parted /dev/nvme1n1 set 1 boot on
parted /dev/nvme1n1 mkpart primary 513 100% # Remaining /
parted /dev/nvme1n1 name 2 rootfs
mkfs.vfat /dev/nvme1n1p1
mkfs.ext4 /dev/nvme1n1p2
mount /dev/nvme1n1p2 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/nvme1n1p1 /mnt/gentoo/boot
dd if=/dev/zero of=/mnt/gentoo/swap bs=1024 count=33554432 # 32 Gb /swap
chmod 0600 /mnt/gentoo/swap
mkswap /mnt/gentoo/swap
cd /mnt/gentoo
wget ftp://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-2020*tar.xz
tar xpf *.tar.xz --xattrs-include='*.*' --numeric-owner
/bin/cp /root/gentoo-main/make.conf /mnt/gentoo/etc/portage/make.conf
mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp /root/gentoo-main/chroot.sh /mnt/gentoo/root/
cp /root/gentoo-main/config /mnt/gentoo/root/
cp /root/gentoo-main/fstab /mnt/gentoo/root/
chmod +x /mnt/gentoo/root/chroot.sh
chroot /mnt/gentoo /root/chroot.sh

reboot
