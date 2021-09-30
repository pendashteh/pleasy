#!/bin/bash
################################################################################
#                      Move dev to stage For Pleasy Library
#
#  This script will use git to update the files from dev repo (ocdev) on the stage
#  site dev to stg. If one argument is given it will copy dev to the site
#  specified. If two arguments are give it will copy the first to the second.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  15/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
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
#                             Commenting with model
#
# NAME OF COMMENT (USE FOR RATHER SIGNIFICANT COMMENTS)
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################

# scriptname is set in pl.

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Uses git to update a stage site with the dev files.
Usage: pl dev2stg [OPTION] ... [SOURCE]
This script will use git to update the files from dev repo (ocdev) on the stage
site dev to stg. If one argument is given it will copy dev to the site
specified. If two arguments are give it will copy the first to the second.
Presumes the dev git has already been pushed. Git is used for this rather than
simple file transfer so it follows the requirements in .gitignore.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:"

}
step=${step:-1}
# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hs:d -l help,step:,debug --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl copyf --help' for more options"
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
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
  verbose="debug"
  shift; ;;
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

if [ $1 == "dev2stg" ] && [ -z "$2" ]
  then
  sitename_var="$sites_stg"
  from="$sites_dev"
elif [ -z "$2" ]
  then
    sitename_var=$1
    from="$sites_dev"
   else
    from=$1
    sitename_var=$2
fi
# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml

# Step Display
################################################################################
# Display to user which step is chosen if step option is defined
################################################################################
if [ $step -gt 1 ]; then
  echo "Starting from step $step"
fi

################################################################################
# Unsure what this is for, and how to parse this properly
################################################################################

if [ $step -lt 2 ]; then
  echo -e "$Cyan step 1: This will update the stage site $sitename_var with the latest from $from $Color_Off"

to_site=$sitename_var
import_site_config $from
from_site_path=$site_path

# Make sure cmi is exported
drush @"$from" cex

#    if [ ! -d "$from_site_path/$from/.git" ]; then
#      echo "There is no git in the dev site $from. Aborting."
#      exit 0
#    fi
sitename_var=$to_site
import_site_config $sitename_var



#copy_site_files $from $sitename_var
# use rsync.
ocmsg "From $from_site_path/$from  To $site_path/$sitename_var" debug
ocmsg $(pwd) debug


# -rlptgocEPuv    -rzcEPu      -rultz
#  -rzcEPul
# -rvlzic --copy-unsafe-links --ipv4 --progress --delete
# rsync -rvtlzi --copy-unsafe-links --ignore-times --ipv4

## todo could add code so it deals with whatever the webroot is.
rsync -rav --delete --exclude 'docroot/sites/default/settings.*' \
            --exclude 'docroot/sites/default/services.yml' \
            --exclude 'docroot/sites/default/files/' \
            --exclude 'web/sites/default/settings.*' \
            --exclude 'web/sites/default/services.yml' \
            --exclude 'web/sites/default/files/' \
            --exclude 'html/sites/default/settings.*' \
            --exclude 'html/sites/default/services.yml' \
            --exclude 'html/sites/default/files/' \
            --exclude '.git/' \
            --exclude '.gitignore' \
            --exclude 'private/' \
            --exclude '*/node_modules/' \
            --exclude 'node_modules/' \
            --exclude 'dev/' \
            "$from_site_path/$from/"  "$site_path/$sitename_var/" # > rsyncerrlog.txt
# &> rsyncerrlog.txt
if [ "$verbose" == "debug"  ] ; then
  if grep -q 'rsync' rsyncerrlog.txt; then
    echo "Error Message from rsync"
cat rsyncerrlog.txt | grep "rsync"
fi
  fi
#rm rsyncerrlog.txt
ocmsg "Rsync Finished." debug

  # >&!

# ,"$from_site_path/$from/docroot/sites/default/services.yml", "$from_site_path/$from/docroot/sites/default/files/","$from_site_path/$from/private/"
set_site_permissions

#Now run the updates on the stage site

  ocmsg "Path: $site_path/$sitename_var" debug
  cd $site_path/$sitename_var
  # composer install
echo -e "\e[34mcomposer install\e[39m"
# Looks like it is best to remove composer.lock so getting the latest according to composer.json
  if [[ -f $site_path/$sitename_var/composer.lock ]]; then
rm $site_path/$sitename_var/composer.lock
fi
#rm $site_path/$sitename_var/vendor -rf
  composer install --no-dev  # composer install needs phing. so remove phing!
  set_site_permissions
  fix_site_settings

cd
echo -e "\e[34m update database for $sitename_var\e[39m"
drush @$sitename_var updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sitename_var fra -y
echo -e "\e[34m import config\e[39m"
if [[ "$reinstall_modules" != "" ]] ; then
  drush @$sitename_var pm-uninstall $reinstall_modules -y
#  drush @$sitename_var en $reinstall_modules -y
fi

fi
if [ $step -lt 3 ]; then
  echo -e "$Cyan step 2: Import cim $Color_Off"



if [[ "$force" == "true" ]] ; then
  # Collect the error from the import.
  import_result="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
  # Process the result
  echo "cim result $import_result result"

  import_result1="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
  import_result2="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
  #if error then delete the erroneous config files.
  #Still needs to be written #####

  else
    # see for the reason for this structure: https://www.bounteous.com/insights/2020/03/11/automate-drupal-deployments/
    drush @$sitename_var cim -y || drush @$sitename_var cim -y #--source=../cmi
    drush @$sitename_var cim -y
  fi

if [[ "$reinstall_modules" != "" ]] ; then
#  drush @$sitename_var pm-uninstall $reinstall_modules -y
  drush @$sitename_var en $reinstall_modules -y
fi
# deal with bad config.

    set_site_permissions
    echo -e "\e[34m make sure out of maintenance and readonly mode\e[39m"
drush @$sitename_var sset system.maintenance_mode FALSE
drush @$sitename_var cset readonlymode.settings enabled 0 -y

drush @$sitename_var cr
fi

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

