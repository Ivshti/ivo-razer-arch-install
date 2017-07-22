# arch uefi dm-crypt zfsroot install (archiso)

# partition disk
# start at 1MB (sector 2048)
512Mib EFI
512Mib Boot
Rest ZFS

#setup encrypted partition
cryptsetup luksFormat -l 512 -c aes-xts-plain64 -h sha512 /dev/disk/by-partuuid/<uid>
cryptsetup luksOpen /dev/disk/by-partuuid/<uid> cryptroot

# set architecture to x86_64
# and
# add unofficial archzfs repo
# edit /etc/pacman.conf
#Architecture = x86_64

# setup networking
wifi-menu

# add zfs repo
echo "[archzfs]" >> /etc/pacman.conf
echo 'Server = http://archzfs.com/$repo/x86_64' >> /etc/pacman.conf

pacman-key -r 5E1ABF240EE7A126
pacman-key --lsign-key 5E1ABF240EE7A126

# update package index
pacman -Syy

# install archzfs
# default: all
pacman -S zfs-linux-git

# zfs setup
touch /etc/zfs/zpool.cache

# init zfs
modprobe zfs

#setup ZFS (ashift for modern drives, ssd)
zpool create -f -o ashift=12 -o cachefile=/etc/zfs/zpool.cache -O normalization=formD -m none -R /mnt rpool /dev/mapper/cryptroot

zfs create -o mountpoint=none -o compression=lz4 rpool/ROOT

#rootfs 
# DONT'T CREATE extra /usr on arch, see here:
#  - http://freedesktop.org/wiki/Software/systemd/separate-usr-is-broken/
#  - https://wiki.archlinux.org/index.php/Mkinitcpio
zfs create -o mountpoint=/ rpool/ROOT/rootfs
zfs create -o mountpoint=/opt rpool/ROOT/rootfs/OPT

#homedirs
zfs create -o mountpoint=/home rpool/HOME
zfs create -o mountpoint=/root rpool/HOME/root

##zpool set bootfs=rpool rpool

# export and reimport pool, so you don't need to force next import
zpool export rpool
zpool import -R /mnt rpool

# mount boot partitions
mkdir /mnt/boot
mount /dev/disk/by-partuuid/<uid> /mnt/boot

# install base system
pacstrap -i /mnt base base-devel

# create fstab
genfstab -U -p /mnt | grep boot >> /mnt/etc/fstab

# load efivars for UEFI
#modprobe efivars

# chroot into installation
arch-chroot /mnt /bin/bash

# set locale
# edit /etc/locale.gen
en_US.UTF-8 UTF-8

# generate locale
locale-gen

# set default language
echo LANG=en_US.UTF-8 > /etc/locale.conf

# set timezone
ln -s /usr/share/zoneinfo/Europe/Sofia /etc/localtime

# set hardware clock
hwclock --systohc --utc

# install ntp
pacman -S ntp

# add country pools to conf
# vim /etc/ntp.conf

# sync time
ntpd -q

# save to hardware clock
hwclock -w

# set keymap and font
loadkeys us
setfont Lat2-Terminus16

# save keymap and font
# edit /etc/vconsole.conf
KEYMAP=us
FONT=Lat2-Terminus16

# edit /etc/pacman.d/mirrorlist

# update package database
pacman -Syy
pacman -Su --ignore filesystem,bash
pacman -S bash
pacman -Su

# add zfs repo
echo "[archzfs]" >> /etc/pacman.conf
echo 'Server = http://archzfs.com/$repo/x86_64' >> /etc/pacman.conf

pacman-key -r 5E1ABF240EE7A126
pacman-key --lsign-key 5E1ABF240EE7A126

# install other needed packages
pacman -S vim zfs-linux-git

# enable zfs automount
systemctl enable zfs.target

# add hooks for initramfs
# edit /etc/mkinitcpio.conf
#
# HOOKS=... keyboard before encrypt before zfs before filesystems. No fsck.
# MODULES="dm_mod"

# make initramfs
mkinitcpio -p linux

# set root password
passwd

# set hostname
echo <name> > /etc/hostname

# EFISTUB refind
#

mkdir /boot/efi
# mount /boot/efi


# install refind
pacman -S refind-efi

# create refind directories
mkdir -p /mnt/boot/efi/EFI/refind/{drivers,icons}

# copy default files
# refind-install
# cp /usr/lib/refind/refind_<arch>.efi /boot/efi/EFI/refind/
# cp /usr/lib/refind/refind.conf /boot/efi/EFI/refind/
# cp /usr/lib/refind/drivers/* /boot/efi/EFI/refind/drivers/
# cp /usr/share/refind/icons/* /boot/efi/EFI/refind/icons/
# cp /usr/lib/refind/config/refind_linux.conf /boot/

# edit /boot/refind_linux.conf
"Boot with defaults" "cryptdevice=/dev/disk/by-partuuid/:cryptroot zfs=rpool/ROOT/rootfs rw"

# add refind to efi
modprobe efivars
1 -c -d /dev/disk/by-id/<id> -p <efi_partition_nr> -l /EFI/refind/refind_<arch>.efi -L "rEFInd"

# exit chroot

# copy zpool.cache to chroot
# cp /etc/zfs/zpool.cache /mnt/etc/zfs/

# umount /boot and /boot/efi
umount /mnt/boot/efi
umount /mnt/boot

# export zfs
zpool export rpool

# reboot