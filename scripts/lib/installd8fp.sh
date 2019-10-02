#!/bin/bash
# This will install d8fp.sh so the password is not required.
# pass the file location as absolute path then the username,

# Make sure sudo
if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi
cp $1 /usr/local/bin
sudo chown root:root /usr/local/bin/d8fp.sh
sudo echo "$2 ALL = (root) NOPASSWD: /usr/local/bin/d8fp.sh" > /etc/sudoers.d/d8fp
sudo chmod 0440 /etc/sudoers.d/d8fp
