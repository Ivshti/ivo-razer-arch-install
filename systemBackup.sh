#!/usr/bin/env bash

set -e 

IMAGE_FILE=/home/ivo/storage/system-`date +"%d-%m-%Y"`
LOOP_DEV="/dev/loop0"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -e "$IMAGE_FILE" ]; then
	echo "File $IMAGE_FILE exists"
	exit 1
fi

# @TODO: mount existing

# Prepare filesystem
dd if=/dev/zero of="$IMAGE_FILE" bs=1M count=70000
losetup "$LOOP_DEV" "$IMAGE_FILE"

cryptsetup -vy luksFormat "$LOOP_DEV"
cryptsetup luksOpen "$LOOP_DEV" systemVol

mkfs.ext4 /dev/mapper/systemVol
mount /dev/mapper/systemVol /mnt

# backup
rsync -aAX / --exclude={"/home/ivo/storage","/.snapshots/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} /mnt

# clean-up
umount /mnt
cryptsetup luksClose systemVol

# compress
gzip "$IMAGE_FILE"
