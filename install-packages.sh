#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo Current dir is $DIR
APT_FLAGS="-y --no-install-recommends"

# Heroku repo and key
add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | apt-key add -

# Dropbox’s repository key
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

# Add Dropbox’s repository
add-apt-repository "deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main"

# Fresh mutt etc.
add-apt-repository ppa:jonathonf/backports

# Firefox ESR
add-apt-repository ppa:jonathonf/firefox-esr

# Update and install dropbox and heroku
apt update
apt install $APT_FLAGS $(grep -vE "^\s*#" $DIR/package-list  | tr "\n" " ")

