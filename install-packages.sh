#/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APT_FLAGS=-sy --no-insall-recommends
echo apt install $APT_FLAGS $(grep -vE "^\s*#" $DIR/package-list  | tr "\n" " ")

# Heroku repo and key
add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | apt-key add -

# Dropbox’s repository key
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

# Add Dropbox’s repository
add-apt-repository "deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main"

# Update and install dropbox and heroku
apt update
apt install $APT_FLAGS nautilus-dropbox heroku

