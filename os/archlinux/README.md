# Arch Linux

- [Links](#links)
- [Netboot](#netboot)
  * [BIOS](#bios)
  * [UEFI](#uefi)

# Links
* Home page: https://www.archlinux.org/
* Download: https://www.archlinux.org/download/
* Docs: https://wiki.archlinux.org/
* Forum: https://bbs.archlinux.org/
* Bugs: https://bugs.archlinux.org/

# Netboot

## BIOS
1. Download [ipxe.lkrn](https://www.archlinux.org/releng/netboot/)
2. Install [Syslinux](https://wiki.syslinux.org/)
3. Run:
``` shell
$ ./bin/netboot-bios.sh \    # create BIOS netboot device
    <device>            \    # device path
    <ipxe.lkrn>         \    # ipxe.lkrn file
    <mbr.bin>                # mbr.bin file from Syslinux
```

## UEFI
1. Download [ipxe.efi](https://www.archlinux.org/releng/netboot/)
2. Run:
``` shell
$ ./bin/netboot-uefi.sh \    # create UEFI netboot device
    <device>            \    # device path
    <ipxe.efi>               # ipxe.efi file
```
