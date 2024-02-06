#!/bin/sh

get_input() {
    echo "$1: "
    read
    returnvalue=${REPLY}
}

make_user() {
    get_input "Enter your username"
    username=$returnvalue
    get_input "Enter your password"
    password=$returnvalue
    sed -i 's/PASSWORD/$password/g' user_credentials.json
    sed -i 's/USERNAME/$username/g' user_credentials.json
}

prepare() {
    sed 's/#ParallelDownloads\ =\ 5/ParallelDownloads\ =\ 15/g' /etc/pacman.conf -i
}

make_user && prepare && sudo archinstall --config user_configuration.json --creds user_credentials.json
