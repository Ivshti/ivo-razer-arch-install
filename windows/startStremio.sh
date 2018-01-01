PWD=$(gpg --decrypt ./pwd.txt.gpg)
sudo VBoxManage guestcontrol --username ivo --password "$PWD" Win run 'C:\Users\ivo\AppData\Local\Programs\LNV\Stremio-4\Stremio.exe'
