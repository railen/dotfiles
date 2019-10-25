#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo Current dir is $DIR
APT_FLAGS="-y --no-install-recommends"

sudo add-apt-repository ppa:nextcloud-devs/client

# Update and install dropbox and heroku
apt update
apt install $APT_FLAGS $(grep -vE "^\s*#" $DIR/package-list  | tr "\n" " ")

