#!/bin/bash

print_help() {
echo \
"Copies only the files from one site to another
Usage: pl copyf [OPTION] ... [SOURCE]
This script will copy one site to another site. It will copy only the files
but will set up the site settings. If no argument is given, it will copy dev
to stg If one argument is given it will copy dev to the site specified If two
arguments are give it will copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:"

}

args=$(getopt -o h -l help --name "$scriptname" -- "$@")
# echo "$args"

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl copyf --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done


# start timer
# Timer to show how long it took to run the script
SECONDS=0
parse_pl_yml

# LOOKBACK and implement getopt!!!
# Unsure what this is for, and how to parse this properly
if [ $1 == "copy" ] && [ -z "$2" ]
  then
 echo "You need to specify the from and to sites."
 exit
elif [ -z "$2" ]
  then
 echo "You need to specify the from and to sites."
 exit
   else
    from=$1
    sitename_var=$2
fi

echo "This will copy the site from $from to $sitename_var and set permissions and site settings"

copy_site_files $from $sitename_var

import_site_config $sitename_var
set_site_permissions
fix_site_settings

# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

