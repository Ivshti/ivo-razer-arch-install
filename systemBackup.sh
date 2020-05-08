#!/usr/bin/env bash

set -e 

#sudo mount /dev/sda1 /home/ivo/storage/sysbackups/

IMAGE_FILE=/home/ivo/storage/sysbackups/system-latest
#IMAGE_FILE=/home/ivo/storage/sysbackups/system-`date +"%d-%m-%Y"`
#IMAGE_FILE=/home/ivo/storage/sysbackups/system-`date +"%m-%Y"`
LOOP_DEV="/dev/loop0"
SIZE="110G"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -e "$IMAGE_FILE" ]; then
	echo "File $IMAGE_FILE exists, updating backup"
	losetup "$LOOP_DEV" "$IMAGE_FILE"
	cryptsetup luksOpen "$LOOP_DEV" systemVol
	mount /dev/mapper/systemVol /mnt
else
	# Prepare filesystem
	echo "Preparing file"
	fallocate -l "$SIZE" "$IMAGE_FILE"
	losetup "$LOOP_DEV" "$IMAGE_FILE"

	echo "Preparing filesystem, cryptsetup"
	cryptsetup -vy luksFormat "$LOOP_DEV"

	cryptsetup luksOpen "$LOOP_DEV" systemVol

	mkfs.ext4 /dev/mapper/systemVol
	mount /dev/mapper/systemVol /mnt
fi

# ensure it's mounted
if grep -qs '/mnt ' /proc/mounts; then
	echo "Preparing backup"
else
	echo "/mnt is not mounted"
	losetup -d /dev/loop0
	exit
fi

# backup
rsync --info=progress2 --human-readable --exclude node_modules --exclude .DS_Store --exclude target --exclude={"/home/ivo/storage","/home/ivo/.stremio-server","/home/ivo/.npm","/.snapshots/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/ivo/repos","*node_modules*","*/target/*","/var/lib/docker","/var/lib/dhcpcd","/var/log","/var/cache"} -aAXl / /mnt

# clean-up
echo "Finalizing backup"
umount /mnt
cryptsetup luksClose systemVol
losetup -d /dev/loop0

# compress
#gzip "$IMAGE_FILE"
