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
