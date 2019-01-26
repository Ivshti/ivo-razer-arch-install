#!/usr/bin/env bash

set -e 

IMAGE_FILE=/home/ivo/storage/system-`date +"%d-%m-%Y"`
LOOP_DEV="/dev/loop0"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -e "$IMAGE_FILE" ]; then
	echo "File $IMAGE_FILE exists, updating backup"
	exit 
else
	# Prepare filesystem
	echo "Preparing file"
	fallocate -l 80G "$IMAGE_FILE"
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
rsync --info=progress2 --human-readable --exclude node_modules --exclude .DS_Store --exclude target --exclude={"/home/ivo/storage","/.snapshots/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/ivo/repos","*node_modules*","*/target/*","/var/lib/docker"} -aAXl / /mnt

# clean-up
echo "Finalizing backup"
umount /mnt
cryptsetup luksClose systemVol
losetup -d /dev/loop0

# compress
gzip "$IMAGE_FILE"
