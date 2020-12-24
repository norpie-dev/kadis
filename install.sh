#!/bin/sh

DOTS_GIT_REPO="https://github.com/norpie-dev/dots"
DOTS_FILE_REPO="$HOME/repos/dots"

[ -z "$HOME" ] && echo '$HOME variable is not set, fix this then run the script again.'

git clone "$DOTS_GIT_REPO" "$DOTS_FILE_REPO"
git pull --git-dir="$DOTS_FILE_REPO" --work-tree=$HOME 
