#!/bin/bash

source /etc/os-release

case ${NAME} in
    "Arch Linux") os="archlinux" ;;
    *) echo "Unknow OS ${NAME}" && exit 1 ;;
esac

bash <(curl -s "https://raw.githubusercontent.com/gabriel376/pc/master/os/${os}/bin/install.sh")
