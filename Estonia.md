# How to use Estonian digital e-residency

https://wiki.archlinux.org/index.php/Electronic_identification#Estonia


```
yaourt -S ccid chrome-token-signing qdigidoc qesteidutil libdigidoc libdigidocp esteidfirefoxplugin
sudo systemctl enable pcscd.socket
sudo systemctl start pcscd.socket
```
