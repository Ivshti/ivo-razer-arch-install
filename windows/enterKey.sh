sudo VBoxManage controlvm Win keyboardputscancode $(gpg --decrypt ./bitlocker.gpg | ./type2vb.py)

