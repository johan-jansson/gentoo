#!/bin/bash
# Gentoo automatic installation script, optimized for AMD Ryzen 9 3900X with Zen 2 architecture (24 threads) 
# Based on https://wiki.gentoo.org/wiki/Handbook:AMD64
# Boot: install-amd64-minimal-*.iso
# wget https://github.com/johan-jansson/gentoo/archive/main.zip
#
# gentoo.sh        # main script
# chroot.sh        # chroot operations
# make.conf        # portage config: /etc/portage/make.conf
# .config          # kernel config: /usr/src/linux/.config
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
emerge net-misc/dhcpcd
emerge app-admin/sysklogd
rc-update add sysklogd default
emerge sys-process/cronie
rc-update add cronie default
mv /root/fstab /etc/fstab
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

