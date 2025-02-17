#!/bin/bash

SECONDS=0

# Update the prod site.
# $1 is the prod site. docroot location
# $2 modules to be reinstalled. Put the modules in quotation marks.

# This presumes the production site has been copied to test.

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

if [ -z "$2" ] ; then
echo "No modules will be reinstalled."
else
reinstall_modules=$2
fi

echo "Update Production"
if [[ "$1" = "" ]]; then
  echo "docroot variable is empty. Aborting."
  exit 1
fi
user=$USER
prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"

echo "Variables are:"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test uri: $test_uri"
echo "user: $user"
echo "Reinstall Modules: $reinstall_modules"

#update test
echo "Run the updates on test"
cd
./updatetest.sh $test_docroot $reinstall_modules

# swap the sites
echo "Swap test and prod sites."
cd /var/www
echo "Move prod to old"
sudo mv $uri "old.$uri"
echo "Move test to prod."
sudo mv $test_uri $uri
echo "Move old to test."
sudo mv "old.$uri" $test_uri
echo "Move settings from teststore to back/settings"
sudo mv /home/$user/$test_uri/settings.php /home/$user/settings.php
echo "Move settings from prodstore to teststore."
sudo mv /home/$user/$uri/settings.php /home/$user/$test_uri/settings.php
echo "Move back/settings to prodstore."
sudo mv /home/$user/settings.php /home/$user/$uri/settings.php

# put the old prod out of read only mode or maintenance mode
echo "Put old prod {test.opencat.org} out of readonly mode or maintenance mode."
cd
./mainoff.sh $test_docroot

echo "Production update completed." 

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
