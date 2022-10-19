#!/bin/bash
#go sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
clear
declare r="n";
read -p "Ready? [y/n]: " r
if [ $r == 'y' ]||[ $r == 'Y' ]; then
sed -i 's/#deb c/deb c/;s/deb c/#deb c/;s/bullseye/bookworm/' /etc/apt/sources.list
apt-get update -y && apt-get upgrade -y
apt-get install --reinstall libwacom-common -y
apt-get dist-upgrade -y
declare curr_kernel=$(apt list | grep '^linux-image-5.*amd64\/.*installed' | grep -v 'cloud\|rt' | sed 's/amd64\/.*/amd64/');
declare new_kernel=$(apt list | grep '^linux-image-5.*amd64\/.*testing' | grep -v 'cloud\|rt' | sed 's/amd64\/.*/amd64/');
declare headers=$(apt list | grep '^linux-headers-5.*amd64\/' | grep -v 'cloud\|rt' | sed 's/amd64\/.*/amd64/');
if [ $curr_kernel ] && [ $new_kernel ] && [ $curr_kernel != $new_kernel ]; then
apt-get install -y $new_kernel
apt-get remove --purge -y $curr_kernel
fi
if [ $headers ]; then
apt-get install -y $headers
fi
apt-get autoremove -y
update-grub
systemctl reboot
else
clear
echo "Ok."
exit
fi
exit
