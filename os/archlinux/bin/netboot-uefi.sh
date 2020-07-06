#!/bin/bash

function usage {
    echo "Usage: netboot-uefi.sh [device] [ipxe.efi]"
    echo
    echo "Creates a bootable device with Arch Linux netboot image in UEFI mode."
    echo "See https://wiki.archlinux.org/index.php/Netboot#UEFI for more information."
    echo
    echo "Options:"
    echo "  device      device path, e.g. /dev/sda"
    echo "  ipxe.efi    ipxe.efi file from https://www.archlinux.org/releng/netboot/"
    exit 1
}

function main {
    local dev="$1"
    local ipxe="$2"
    local mnt=$(mktemp -d)

    [[ -b ${dev} && -f ${ipxe} ]] || usage

    sudo parted -s -a optimal ${dev} \
         mklabel msdos               \
         mkpart primary fat32 0% 100% set 1 esp on
    sudo mkfs.fat -F32 ${dev}1
    sudo mount ${dev}1 ${mnt}
    sudo mkdir -p ${mnt}/EFI/BOOT
    sudo cp ${ipxe} ${mnt}/EFI/BOOT/BOOTX64.EFI
    sudo umount ${dev}1
}

main "$@"
