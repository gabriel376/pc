#!/bin/bash

function usage {
    echo "Usage: burn.sh [os] [device]"
    echo
    echo "Burn media to device."
    echo
    echo "Options:"
    echo "  os        operating system path, e.g. os/archlinux"
    echo "  device    device path, e.g. /dev/sda"
    exit 1
}

function main {
    os=${1}
    dev=${2}

    [[ -d "./${os}/bin" && -b ${dev} ]] || usage

    url=$(bash "./${os}/bin/media.sh")
    media="./${os}/media/$(basename $url)"

    [[ ! -f $media ]] && curl -o $media $url

    sudo dd status=progress bs=4M if=${media} of=${dev}
}

main "$@"
