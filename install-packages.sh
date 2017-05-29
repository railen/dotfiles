#/bin/sh
apt install -y --no-install-recommends $(grep -vE "^\s*#" package-list  | tr "\n" " ")
