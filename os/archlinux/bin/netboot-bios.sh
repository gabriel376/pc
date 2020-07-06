#!/bin/bash

function usage {
    echo "Usage: netboot-bios.sh [device] [ipxe.lkrn] [mbr.bin]"
    echo
    echo "Creates a bootable device with Arch Linux netboot image in BIOS mode."
    echo "See https://wiki.archlinux.org/index.php/Netboot#BIOS for more information."
    echo
    echo "Options:"
    echo "  device       device path, e.g. /dev/sda"
    echo "  ipxe.lkrn    ipxe.lkrn file from https://www.archlinux.org/releng/netboot/"
    echo "  mbr.bin      mbr.bin file, e.g. /usr/lib/syslinux/mbr/mbr.bin"
    exit 1
}

function main {
    local dev="$1"
    local ipxe="$2"
    local mbr="$3"
    local mnt=$(mktemp -d)

    [[ -b ${dev} && -f ${ipxe} && -f ${mbr} ]] || usage

    sudo parted -s -a optimal ${dev} \
         mklabel msdos               \
         mkpart primary fat32 0% 100% set 1 boot on
    sudo mkfs.vfat ${dev}1
    sudo mount ${dev}1 ${mnt}
    sudo mkdir -p ${mnt}/boot/syslinux
    sudo cp ${ipxe} ${mnt}/boot/ipxe.lkrn
    sudo tee ${mnt}/boot/syslinux/syslinux.cfg <<EOF
DEFAULT arch_netboot
   SAY Booting Arch over the network.
LABEL arch_netboot
   KERNEL /boot/ipxe.lkrn
EOF
    sudo umount ${dev}1
    rm -rf ${mnt}
    sudo dd bs=440 count=1 conv=notrunc if=${mbr} of=${dev}
    sudo syslinux --directory /boot/syslinux/ --install ${dev}1
}

main "$@"
