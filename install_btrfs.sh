# arch uefi dm-crypt zfsroot install (archiso)

# partition disk
# start at 1MB (sector 2048)
512Mib EFI
512Mib Boot
Rest BTRFS

#mkfs.fat -F32 /dev/nvme0n1p6


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

# update package index
pacman -Syy

#  setup btrfs
mkfs.btrfs /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt

btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

umount /mnt
mount -o noatime,compress=lzo,space_cache,subvol=@root /dev/mapper/cryptroot /mnt
mkdir /mnt/{boot,var,home,.snapshots}
mount -o noatime,compress=lzo,space_cache,subvol=@var /dev/mapper/cryptroot /mnt/var
mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=lzo,space_cache,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# mount boot partitions
mount /dev/disk/by-partuuid/<uid> /mnt/boot


# speed up pacman
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist 

# install base system
pacstrap -i /mnt base base-devel git lxqt lxdm

# create fstab
genfstab -U -p /mnt > /mnt/etc/fstab

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
#hwclock --systohc --utc

# install ntp
pacman -S ntp

# add country pools to conf
# vim /etc/ntp.conf

# sync time
ntpd -qg

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

# 14 - fix the mkinitcpio.conf to contain what we actually need.
vi /etc/mkinitcpio.conf
# on the MODULES section, add "vfat aes_x86_64 crc32c-intel" (and whatever else you know your hardware needs. Mine needs i915 too)
# on the BINARIES section, add "/usr/bin/btrfsck", since it's useful to have in case your filesystem has troubles
# on the HOOKS section: 
#  - add "resume" after "udev" (IF and ONLY IF you want to enable resume support)
#  - add "encrypt" before "filesystems"
#  - remove "fsck" and 
#  - add "btrfs" at the end

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
refind-install

# add refind to efi
modprobe efivars
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

1 -c -d /dev/disk/by-id/<id> -p <efi_partition_nr> -l /EFI/refind/refind_<arch>.efi -L "rEFInd"

btrfs subvolume snapshot -r / /.snapshots/@root-`date +%F-%R`

# exit chroot
exit


# umount /boot and /boot/efi
umount /mnt/boot/efi
umount /mnt/boot


# reboot
