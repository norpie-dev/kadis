#!/bin/sh

region=
city=
locale=

package_update() {
    pacman -Syu --noconfirm
}

time_zone() {
    ln -sf /usr/share/zoneinfo/"$region"/"$city" /etc/localtime
    hwclock --systohc
}

localization() {
    echo "$locale.UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$locale.UTF-8" >> /etc/locale.conf
}

network_configuration() {
    echo "$hostname" >> /etc/hostname

    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

    pacman -S networkmanager --noconfirm
    systemctl enable NetworkManager
}

user_setup() {

}
