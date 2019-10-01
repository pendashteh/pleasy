#!/bin/bash

# oc includes
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

import_site_config () {
# setup basic defaults
sn=$1
private="/home/$user/$folder/$sn/private"

# First load the defaults
rp="recipes_default_project" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; else project=""; fi
rp="recipes_default_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; else dev=""; fi
rp="recipes_default_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; else webroot=""; fi
rp="recipes_default_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; else sitename=""; fi
rp="recipes_default_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ; else auto=""; fi
rp="recipes_default_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; else apache=""; fi
rp="recipes_default_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; else dbuser=""; fi
rp="recipes_default_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; else profile=""; fi
rp="recipes_default_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ; else db=""; fi
rp="recipes_default_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; else dbpass=""; fi
rp="recipes_default_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; else uri="$folder.$sn"; fi
rp="recipes_default_install_method" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_method=${!rp} ; else install_method=""; fi
rp="recipes_default_git_upstream" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then git_upstream=${!rp} ; else git_upstream=""; fi
rp="recipes_default_theme" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme=${!rp} ; else theme=""; fi
rp="recipes_default_theme_admin" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme_admin=${!rp} ; else theme_admin=""; fi
rp="recipes_default_install_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_modules=${!rp} ; else install_modules=""; fi

# Collect the details from oc.yml if they exist otherwise make blank
rp="recipes_${sn}_project" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; fi
rp="recipes_${sn}_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; fi
rp="recipes_${sn}_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; fi
rp="recipes_${sn}_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; fi
rp="recipes_${sn}_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ;  fi
rp="recipes_${sn}_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; fi
rp="recipes_${sn}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; fi
rp="recipes_${sn}_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; fi
rp="recipes_${sn}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ;  fi
rp="recipes_${sn}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; fi
rp="recipes_${sn}_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; fi
rp="recipes_${sn}_install_method" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; fi
rp="recipes_${sn}_git_upstream" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then git_upstream=${!rp} ; fi
rp="recipes_${sn}_theme" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme=${!rp} ; fi
rp="recipes_${sn}_theme_admin" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme_admin=${!rp} ; fi
rp="recipes_${sn}_install_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_modules=${!rp} ; fi

if [ "$db" == "" ] ; then db="$sn$folder" ; fi
if [ "$dbuser" == "" ] ; then dbuser=$db ; fi
if [ "$dbpass" == "" ] ; then dbpass=$dbuser ;fi

}

parse_oc_yml () {
# Import yaml
# presumes $script_root is set
# $userhome
update_config="n"

. $script_root/scripts/parse_yaml.sh "oc.yml" $script_root

if [ $update_config == "y" ]
then
update_all_configs
fi

}

update_all_configs () {

# Update all database credentials in case the user changed any.
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

# Store the site name to restore it later
storesn=$sn

# Setup drupal console if it is installed.
drupalconsole="y"

# Create drupal console file
if [ ! -d "$user_home/.console" ]
then
ocmsg "Drupal console is not installed."
drupalconsole="n"
else
if [ ! -d $user_home/.console/sites ]
then
mkdir $user_home/.console/sites
fi
fi
# Clear current file
ocmsg "$user_home/.console/sites/$folder.yml"
echo "" > "$user_home/.console/sites/$folder.yml"

#Collect the drush location: messy but it works!
# This command might list some warnings. It is a bug with drush: https://github.com/drush-ops/drush/issues/3226
ocmsg $folderpath/drush.tmp
if [[ $folderpath/drush.tmp =~ (@dev) ]] ;
then
drush @dev status > "$folderpath/drush.tmp"
else
drush status > "$folderpath/drush.tmp"
fi

dline=$(awk 'match($0,v){print NR; exit}' v="Drush script" "$folderpath/drush.tmp")
dlinec=$(sed "${dline}q;d" "$folderpath/drush.tmp")
dlined="/$(echo "${dlinec#*/}")"
drushloc=${dlined::-11}
rm "$folderpath/drush.tmp"

if [ -f $user_home/.drush/$folder.aliases.drushrc.php ]
then
rm  $user_home/.drush/$folder.aliases.drushrc.php
fi

cat > $user_home/.drush/$folder.aliases.drushrc.php <<EOL
<?php
/**
 * This file has been created by $site_folder/scripts/_inc.sh
 *
 */
 \$aliases['prod'] = array (
  'uri' => '$prod_uri',
  'root' => '$prod_docroot',
  'remote-user' => '$prod_user',
  'remote-host' => '$prod_uri',
);
EOL

# Delete old credentials folder if it exists
if [ -d $folderpath/credentials ] ; then rm $folderpath/credentials -rf ; fi
mkdir $folderpath/credentials

# Now go through each site and create settings for each site.
Field_Separator=$IFS
# set comma as internal field separator for the string list
IFS=,
for site in $recipes;
do
  # Database defaults
  rp="recipes_${site}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdb=${!rp}; else sdb="$site$folder"; fi
  rp="recipes_${site}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbuser=${!rp}; else sdbuser=$sdb; fi
  rp="recipes_${site}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbpass=${!rp}; else sdbpass=$sdbuser; fi

  cat > $(dirname $script_root)/credentials/$site.mysql <<EOL
[client]
user = $sdbuser
password = $sdbpass
host = localhost
EOL

  #Now go through and create a Drush Alias for each site
  import_site_config $site

  cat >> $user_home/.drush/$folder.aliases.drushrc.php <<EOL
\$aliases['$site'] = array (
  'root' => '$folderpath/$site/$webroot',
  'uri' => 'http://$folder.$site',
  'path-aliases' =>
  array (
    '%drush' => '$drushloc',
    '%site' => 'sites/default/',
  ),
);
EOL

  #Now add drupal console aliases.
  cat >> $user_home/.console/sites/$folder.yml <<EOL
$sn:
  root: $folderpath/$sn
  type: local
EOL

done
IFS=$Field_Separator

#Finish the Drush alias file with
echo "?>" >> "$user_home/.drush/$folder.aliases.drushrc.php"

# Now convert it to drush 9 yml
drush sac "$user_home/.drush/sites/" -q

sn=$storesn
}

fix_site_settings () {
# This will fix the site settings
# Presumes the following information is set
# $user
# $folder
# $sn
# $webroot
# $folderpath

# Check that settings.php has reference to local.settings.php
if [ ! -f "$folderpath/$sn/$webroot/sites/default/settings.php" ]
then
cp "$folderpath/$sn/$webroot/sites/default/default.settings.php" "$folderpath/$sn/$webroot/sites/default/settings.php"
fi

sfile=$(<"$folderpath/$sn/$webroot/sites/default/settings.php")
if [[ $sfile =~ (\{[[:space:]]*include) ]]
then
echo "settings.php is correct"
else
echo "settings.php: added reference to settings.local.php"
cat >> $folderpath/$sn/$webroot/sites/default/settings.php <<EOL
 if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }

EOL
fi


cat > $folderpath/$sn/$webroot/sites/default/settings.local.php <<EOL
<?php

\$settings['install_profile'] = '$profile';
\$settings['file_private_path'] =  '../private';
\$databases['default']['default'] = array (
  'database' => '$db',
  'username' => '$dbuser',
  'password' => '$dbpass',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\Core\Database\Driver\mysql',
  'driver' => 'mysql',
);
\$config_directories[CONFIG_SYNC_DIRECTORY] = '../cmi';
EOL
if [ "$dev" == "y" ]
then
cat >> $folderpath/$sn/$webroot/sites/default/settings.local.php <<EOL
\$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
\$settings['cache']['bins']['render'] = 'cache.backend.null';
\$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
\$config['config_split.config_split.config_dev']['status'] = TRUE;
EOL
fi
echo "Added local.settings.php to $sn"

# Make sure the hash is present so drush sql will work.
sfile=$(<"$folderpath/$sn/$webroot/sites/default/settings.php")
slfile=$(<"$folderpath/$sn/$webroot/sites/default/settings.local.php")
if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]
then
if [[ ! $slfile =~ (\'hash_salt\'\] = \') ]]
then
  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
echo "\$settings['hash_salt'] = '$hash';" >> "$folderpath/$sn/$webroot/sites/default/settings.local.php"
fi
fi

}
ocmsg () {
# This is to provide extra messaging if the verbose variable in oc.yml is set to y.
if [ "$verbose" == "y" ]
then
echo $1
fi
}

set_site_permissions () {
# This will set the correct permissions
# Presumes the following information is set
# $user
# $folder
# $sn
# $webroot

#$folder works in this context because of the cd

cd
echo -e "\e[34msetting correct permissions on $sn - may require sudo password\e[39m"
result=$(chown $user:www-data $folder/$sn -R 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Changed ownership of $sn to $user:www-data"
else echo "Had errors changing ownership of $sn to $user:www-data so will need to use sudo"
sudo chown $user:www-data $folder/$sn -R
fi

./$folder/scripts/lib/d8fp.sh --drupal_path="$folder/$sn/$webroot" --drupal_user=$user
chmod g+w $folder/$sn/private -R
chmod g+w $folder/$sn/cmi -R

if [ ! -d $folder/$sn/$webroot/modules/custom ] ; then mkdir $folder/$sn/$webroot/modules/custom ; fi
chmod g+w $folder/$sn/$webroot/modules/custom -R
if [ ! -d $folder/$sn/$webroot/themes/custom ] ; then mkdir $folder/$sn/$webroot/themes/custom ; fi
chmod g+w $folder/$sn/$webroot/themes/custom -R
}



rebuild_site () {
#This will delete current site database and rebuild it
# Persumes the following information is set
# $user
# $folder
# $sn
# $webroot
#etc


echo "Build the drupal site $sn, ie builds the database for the site."
# drush status
site_info
# drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
drush @$sn -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sn" --sites-subdir=default
#don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.

#sudo bash ./d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user #shouldn't need this, since files don't need to be changed.
#chmod g+w -R $folder/$webroot/modules/custom

# Install any themes
if [ $theme != "" ]
then
echo "Install theme for $sn using uri $uri and theme $theme"
cd
cd $folderpath/$sn/$webroot
drupal --target=$uri theme:install  $theme
drush @$sn config-set system.theme default $theme -y
fi

if [ $theme_admin != "" ]
then
echo "Install theme for $sn"
drupal --target=$uri theme:install  $theme_admin
drush @$sn config-set system.theme admin $theme_admin -y
fi
#drush cr #is this needed here?
drush @$sn cr

###

#  if [ "$dev" = "y" ]
#  then
#  drush en -y oc_dev
#  #uninstall the wrapper. Will leave all dependencies installed.
#  drush pm-uninstall -y oc_dev
#  else
#  drush en -y oc_prod
#  fi

if [ $install_modules != "" ]
then
echo "Install modules for $sn"
drush @$sn en -y $install_modules
fi

#drush pm-uninstall -y oc_prod

if [ $dev = "y" ]
then
echo "Setting to dev mode"
drupal --target=$uri site:mode dev
drush php-eval 'node_access_rebuild();'
else
drupal --target=$uri site:mode prod
fi
}

backup_site () {
#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
cd
# Check if site backup folder exists
if [ ! -d "$folder/sitebackups/$sn" ]; then
  mkdir "$folder/sitebackups/$sn"
fi
cd "$folder/$sn"
#this will not affect a current git present
git init
cd "$webroot"
Name=$(date +%Y%m%d\T%H%M%S-)`git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g'`-`git rev-parse HEAD | cut -c 1-8`$msg.sql

echo -e "\e[34mbackup db $Name\e[39m"
drush sql-dump --structure-tables-key=common --result-file="../../sitebackups/$sn/$Name"

#backupfiles
Name2=${Name::-4}".tar.gz"

echo -e "\e[34mbackup files $Name2\e[39m"
cd ../../
tar -czf sitebackups/$sn/$Name2 $sn
}

backup_db () {

#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
# Check if site backup folder exists
if [ ! -d "$folderpath/sitebackups/$sn" ]; then
  mkdir "$folderpath/sitebackups/$sn"
fi
cd
cd "$folderpath/$sn"
#this will not affect a current git present
git init
cd "$webroot"
Name=$(date +%Y%m%d\T%H%M%S-)`git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g'`-`git rev-parse HEAD | cut -c 1-8`.sql
echo -e "\e[34mbackup db $Name\e[39m"
drush sql-dump --structure-tables-key=common --result-file="../../sitebackups/$sn/$Name"

}
restore_db () {
#presumes that the correct information is already set
# $Name backup sql file
# $db
# $dbuser
# $dbpass
echo "restore db start"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "use $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" != ": 0" ]
 then
  echo "The database $db does not exist. I will try to create it."
  if ! mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; then
    # This script actually just tries to create the user since the database will be created later anyway.
    echo "Unable to create the database $db. Check the mysql root credentials in mysql.cnf"
    exit 1
    else
    echo "Database $db created."
  fi
  else
  echo "Database $db exists so I will drop it."
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Database $db dropped"; else echo "Could not drop database $db: exiting"; exit 1; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created database $db using user root"; else echo "Could not create database $db using user root, exiting"; exit 1; fi
fi

  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created user $dbuser"; else echo "User $dbuser already exists"; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '"$dbuser"'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Granted user $dbuser permissions on $db"; else echo "Could not grant user $dbuser permissions on $db"; fi

echo -e "\e[34mrestore $db database using $folderpath/sitebackups/$bk/$Name\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" $db < "$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Backup database $Name imported into database $db using root"; else echo "Could not import $Name into database $db using root, exiting"; exit 1; fi

}

test_site () {
echo $sn, $db, $dbuser, $dbpass
}

db_defaults () {
# Database defaults
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
if [ -z ${db+x} ]
then
    db="$sn$folder"
fi
if [ -z ${dbuser+x} ]
then
    dbuser=$db
fi
if [ -z ${dbpass+x} ]
then
    dbpass=$dbuser
fi
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
}

site_info () {
echo "Project  = $project"
echo "Project folder = $folder"
echo "Site folder = $sn"
echo "webroot = $webroot"
echo "Profile  = $profile"
echo "uri      = $uri"
echo "Dev      = $dev"
echo "Private folder = $private"
echo "Database = $db"
echo "Database user = $dbuser"
echo "Database password = $dbpass"
echo "Install method = $install_method"
echo "git_upstream = $git_upstream"
echo "theme = $theme"
echo "admin theme = $theme_admin"
echo "install_modules = $install_modules"
}

copy_site_files () {
from=$1
sn=$2
echo "From $from to $sn"

if [ -d $folderpath/$sn ]
then
chown $user:www-data $folderpath/$sn -R
chmod +w $folderpath/$sn -R
rm -rf $folderpath/$sn
fi

cp -rf "$folderpath/$from" "$folderpath/$sn"

}