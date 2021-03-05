#!/bin/sh

DOTS_GIT_REPO="https://github.com/norpie-dev/dots"
SUCKLESS_GIT_REPO="https://github.com/norpie-dev"
KADIS_DIR=$(pwd)

install_pacman_package() {
    sudo pacman -S --noconfirm --needed $1 > /dev/null 2>&1
}

install_aur_package() {
    yay -S --noconfirm --needed $1 > /dev/null 2>&1
}

install_suckless_package() {
    git clone "$SUCKLESS_GIT_REPO/$1" $HOME/.config/$1
    cd $HOME/.config/$1
    make clean install > /dev/null 2>&1
}

complete_install() {
    echo "Enter your username: "
    read
    username=${REPLY}
    export HOME=/home/$username
    install_pacman_packages
    install_dots 
    change_shell 
    install_yay
    install_aur_packages
    install_suckless_packages
    activate_runit
    change_perms
}

change_shell() {
    sudo chsh -s /usr/bin/zsh
    sudo chsh -s /usr/bin/zsh $username
}

install_pacman_packages() {
    for package in $(cat regular.pacman); 
    do
        echo "installing \"$package\"..."
        install_pacman_package $package
        if [ $? -eq 0 ]; then
            echo "installed \"$package\""
        else
            echo "failed to install \"$package\""
        fi
    done
}

install_dots() {
    cd $HOME
    git clone --bare "$DOTS_GIT_REPO" "$HOME/.dots"
    git --git-dir=$HOME/.dots --work-tree=$HOME checkout 
    cd $KADIS_DIR
}

install_yay() {
    YAY_REPO="https://aur.archlinux.org/yay.git"
    git clone $YAY_REPO 
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm yay -rf
    cd $KADIS_DIR
}

install_aur_packages() {
    for package in $(cat regular.aur); 
    do
        echo "installing \"$package\"..."
        install_aur_package $package
        if [ $? -eq 0 ]; then
            echo "installed \"$package\""
        else
            echo "failed to install \"$package\""
        fi
    done
}

install_suckless_packages() {
    # This excpects the packages to be located in $HOME/.config
    for package in $(cat suckless.github);
    do 
        echo "installing \"$package\"..."
        if [ -d $HOME/.config/$package ]; then
            install_suckless_package $package
            echo "installed \"$package\""
        else
            echo "failed to install \"$package\""
        fi
    done
    cd $KADIS_DIR
}

activate_runit() {
    sudo ln -s /etc/runit/sv/ntpd/ /run/runit/service/
    sudo ln -s /etc/runit/sv/sshd/ /run/runit/service/
}

change_perms() {
    chown $username /home/$username -R
}

complete_install
