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
    # TODO: Change user_configuration.json
}

make_user && archinstall --creds user_configuration.json --config
