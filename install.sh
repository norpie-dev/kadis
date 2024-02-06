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
    # TODO: Change user_credentials.json to your own credentials
}

make_user && sudo archinstall --config user_configuration.json --creds user_credentials.json
