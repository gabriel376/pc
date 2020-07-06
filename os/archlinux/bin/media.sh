#!/bin/bash

mirror="http://linorg.usp.br/archlinux/iso/latest"
media=$(curl -s "$mirror/md5sums.txt" | head -n 1 | cut -d ' ' -f 3)
echo "$mirror/$media"
