#!/bin/sh

get_input() {
    echo "$1: "
    read
    returnvalue=${REPLY}
}

prepare() {
    sed 's/#ParallelDownloads\ =\ 5/ParallelDownloads\ =\ 15/g' /etc/pacman.conf -i
}

prepare && sudo archinstall --config user_configuration.json --creds user_credentials.json
