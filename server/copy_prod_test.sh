#!/bin/bash

SECONDS=0

# Copy the production site to the test site
# $1 is the prod site. docroot location
# $2 is the user
# $3 modules to be reinstalled. Put the modules in quotation marks.
# Put production into readonly mode

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi


prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Copying Production to test"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test uri: $test_uri"
echo "User: $user"


#remove test site if it exists
sudo rm $test -rf

#copy live site to test site
sudo cp $prod $test -rf

# Set some permissions right
sudo chown $user:www-data $test -R

#copy in the test settings from backup
sudo cp ~/$test_uri/settings.php $test_docroot/sites/default/settings.php

sudo chown $user:www-data $test_docroot/sites/default/settings.php
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot

#dump the database
cd $prod_docroot

# If not in maintenance mode, then put it in maintenance mode
mainm=$(drush sget maintenance_mode)
# Check to see if production has the readonly module enabled.
echo "Check to see if production has the readonly module enabled." 
readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; } )

roc="0"
if [ ! "$readonly_en" == "" ]; then
	roc=$(drush cget readonlymode.settings enabled)
	rom=${roc: -1}
fi


if [[ "$mainm" == "false" ]] && [[ "$rom" == "0" ]] ; then
echo "Readonly: >$readonly_en<"
if [ ! "$readonly_en" == "" ]; then
drush cset readonlymode.settings enabled 1 -y    
else
      # otherwise put into maintenance mode
    drush sset maintenance_mode 1
fi
drush cr
else
alreadyon="y"
echo "Already in maintenance or readonly mode"
fi
drush sql-dump > ~/proddb/prod.sql
# if it was already in maintenance mode, then leave it in maintenance mode
if [[ ! "$alreadyon" == "y" ]]; then
if [ ! "$readonly_en" == "" ]; then
drush cset readonlymode.settings enabled 0   -y 
else
      # otherwise put into maintenance mode
    drush sset maintenance_mode 0
fi
drush cr
fi
#restore the prod db to testdb
# Get the database details from settings.php
dbname=$(sudo grep "'database' =>" $1/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)
cd ~/proddb/
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql