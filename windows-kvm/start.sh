#export QEMU_ALSA_DAC_BUFFER_SIZE=512 QEMU_ALSA_DAC_PERIOD_SIZE=170 QEMU_AUDIO_DRV=alsa
sudo qemu-system-x86_64 \
-enable-kvm \
-machine type=q35,accel=kvm \
-m 2G \
-cpu host,kvm=off,migratable=off,+invtsc,enforce \
-smp 2,sockets=1,cores=2,threads=1 \
-monitor unix:/tmp/win2,server,nowait \
-drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/home/ivo/ivo-razer-arch-install/my_vars.fd \
-boot order=dc \
-drive file=/dev/disk/by-id/nvme-eui.002538b271b0a8b9,if=virtio,format=raw \
-cdrom virtio-win-0.1.141.iso
#-net nic,model=virtio
#-net tap,vlan=0
#-device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
#-device vfio-pci,host=06:00.0,bus=root.1,addr=00.0,multifunction=on,x-vga=on \
#-device vfio-pci,host=06:00.1,bus=root.1,addr=00.1 \
#-soundhw all \
#-drive if=none,file=/media/VM/windows1.img,id=disk,format=raw -device ide-hd,bus=ide.0,drive=disk \
#-drive file=/dev/mapper/storage-profiles,if=none,id=drive-virtio-disk4,format=raw,serial=KVM-profiles,cache=writeback
#-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0xc,drive=drive-virtio-disk4,id=virtio-disk4,bootindex=6
#-bios /usr/share/seabios/bios.bin
#-bios /home/ivo/Downloads/OVMF-X64-r15214/OVMF.fd \
#-rtc clock=host,base=localtime \
