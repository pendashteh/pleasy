#!/bin/bash

SECONDS=0

# Update the prod site.
# It is presumed the site files have been uploaded.
# $1 is the site address including docroot.
# $2 is the user



if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
else
  prod_docroot=$1
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi

if [ -z "$3" ] ; then
echo "No profile."
exit 0
else
profile=$3
fi


webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Creating Sites"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Test uri: $test_uri"
echo "User: $user"
echo "Profile: $profile"

# prod files at prod.tar.gz
# prod db at ~/proddb/prod.sql
#  Presumes the files are transfered.
#sudo rm $prod -rf
#sudo mkdir $prod
#sudo rm $test -rf
#sudo mkdir $test
#
#sudo tar -zxf /home/$user/$uri/prod.tar.gz -C $prod --strip-components 1
#sudo tar -zxf /home/$user/$uri/prod.tar.gz -C $test --strip-components 1

cd
#sudo ./dfp.sh --drupal_user=$user --drupal_path=$prod_docroot
#sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot
# Create the settings file.

./createsite.sh $prod_docroot $profile $user
./createsite.sh $test_docroot $profile $user

#dbname=$(sudo grep "'database' =>" $1/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)



echo "Sites created."

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
