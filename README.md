# collection of system configs/scripts

## install boot loader

```bash
mkdir /mnt/boot
mount /dev/nvme0n1p6 /mnt/boot
refind-install --root=/mnt
```

## perform a system backup

```bash
sudo mount /dev/sda1 /home/ivo/storage/sysbackups/
sudo ./systemBackup.sh
sudo cp /home/ivo/storage/sysbackups/system-latest /home/ivo/storage/sysbackups/system-`date +"%d-%m-%Y"`
```


## prepare wine for LFS
```bash
pacman -S wine winetricks
winetricks d3dcompiler_43 d3dx9_43
```

You may need to prefix wine commands with:

```
WINEARCH=win32 WINEPREFIX=~/win32
```

Then see the guide at https://en.lfsmanual.net/wiki/Running_LFS_on_Linux
