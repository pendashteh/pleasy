#!/bin/bash
################################################################################
#                          testsite For Pleasy Library
#
#  This script will locally test a site with Docker
#
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################
# scriptname is set in pl.

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Overwrite production with site specified
Usage: pl testsite [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl testsite stg
END HELP
HEREDOC

}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hs:dy -l help,step:,debug,yes --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
  echo "No site specified."
    echo "please do 'pl $scriptname --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 0; ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
  verbose="debug"
  shift
  ;;
  -y | --yes)
    yes=1
    shift; ;;
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done

Pcolor=$Cyan


if [ $1 = "$scriptname" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 0
fi

sitename_var=$1

echo "Testing site $sitename_var on docker"

parse_pl_yml

import_site_config $sitename_var

if [ $step -gt 1 ] ; then
  echo -e "Starting from step $step"
fi

# todo create docker image. plain ubuntu 20 server


sudo apt install git

# 1) set up ssh keys
  #2) pl updateserver [site] # this pushes the scripts up.
  #3) change example.secrets.sh to secrets.sh and edit it.
  #4) run initserver.sh
  #5) run prodow (which calls createsites.sh)




prod_root=$(dirname $prod_docroot)
#First backup the current dev site if it exists
#if [ $step -lt 2 ] ; then
##echo -e "$Pcolor step 1: backup current sitename_var $sitename_var $Color_off"
##pl backup $sitename_var "presync"
#
#fi
#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
#echo "pre rsync"
#drush -y rsync @prod @$sitename_var -- --omit-dir-times --delete

#if [ $step -lt 3 ] ; then
#echo -e "$Pcolor step 2: backup production $Color_off"
### Make sure ssh identity is added
##eval `ssh-agent -s`
##ssh-add ~/.ssh/$prod_alias
#
#to=$sitename_var
#backup_prod
## sql file: $Namesql
## all files: $folderpath/sitebackups/prod/$Name.tar.gz
#sitename_var=$to
#import_site_config $sitename_var
#fi

if [ $step -lt 4 ] ; then
echo -e "$Pcolor step 3: replace production files with $sitename_var $Color_Off"

cd
cd "$folderpath/sitebackups/$sitename_var"
options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
Name=${options[0]:2}
ocmsg "Name of sql backup: $Name "
 # Move sql backup to proddb and push
 echo "Using scp method to push db and files to production"
Name2=${Name::-4}".tar.gz"
echo "scp: $folderpath/sitebackups/$sitename_var/$Name $prod_alias:$prod_uri/prod.sql"
ssh $prod_alias "if [ ! -d $prod_uri ]; then mkdir $prod_uri; fi"
ssh $prod_alias "if [ ! -d test.$prod_uri ]; then mkdir test.$prod_uri; fi"
 scp $folderpath/sitebackups/$sitename_var/$Name $prod_alias:$prod_uri/prod.sql
 scp $folderpath/sitebackups/$sitename_var/$Name2 $prod_alias:$prod_uri/prod.tar.gz
echo "Files and db transfered."

fi

if [ $step -lt 5 ] ; then
echo -e "$Pcolor step 4: install production files $Color_off"
prod_root=$(dirname $prod_docroot)
#ssh $prod_alias "cp -rf $prod_root $prod_root.old"
#ssh $prod_alias "rm -rf $prod_root"
#ssh $prod_alias "mkdir $prod_root"
#ssh $prod_alias "if [ -d $prod_root.new ]; then sudo rm -rf $prod_root.new ; fi"

    ssh $prod_alias "./createsites.sh $prod_docroot $prod_user"
fi

if [ $step -lt 6 ] ; then
echo -e "$Pcolor step 5: creating sites $prod_docroot $prod_user  $prod_profile$Color_off"
    # For now the script should work, but needs various improvments such as, being able to restore on error.
ocmsg "Prod alias $prod_alias uri $prod_uri" debug
exists="$(ssh  $prod_alias "if [ -d /var/www/$prod_uri ]; then echo \"exists\"; fi")"
    if [ "$exists" = "exists" ]; then
      echo "Site $prod_docroot exists so just updating it."
      ssh $prod_alias "./updatesite.sh $prod_docroot $prod_user"
      ssh $prod_alias "./updatesite.sh $test_docroot $prod_user"
    else
        echo "Creating site $prod_docroot."
    ssh $prod_alias "./createsite.sh $prod_docroot $prod_user"
    ssh $prod_alias "./createsite.sh $test_docroot $prod_user"
    fi

fi

if [ $step -lt 7 ] ; then
echo -e "$Pcolor step 6: open production site $Color_off"
drush @prod_${sitename_var} uli &
fi

# If it works, the production site needs to be swapped to prod branch from dev branch and hard rest to dev, is use 'ours'.

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
