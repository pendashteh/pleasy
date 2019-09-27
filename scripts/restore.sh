#!/bin/bash
#restore site and database
# $1 is the backup
# $2 if present is the site to restore into
# $sn is the site to import into
# $bk is the backed up site.

#start timer
SECONDS=0
if [ $1 == "restore" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi
if [ -z "$2" ]
  then
    sn=$1
    bk=$1
    echo -e "\e[34mrestore $1 \e[39m"
   else
    bk=$1
    sn=$2
    echo -e "\e[34mrestoring $1 to $2 \e[39m"
fi

. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to restore a particular site's files and database.
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

folder=$(basename $(dirname $script_root))
folderpath=$(dirname $script_root)
webroot="docroot"
parse_oc_yml
import_site_config $sn

# Prompt to choose which database to backup, 1 will be the latest.
prompt="Please select a backup:"
cd
cd "$folder/sitebackups/$bk"

options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )

PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $REPLY which is file ${opt:2}"
        Name=${opt:2}
        break

    else
        echo "Invalid option. Try another one."
    fi
done


#restore files
cd
cd "$folder"
if [ -d "$sn" ]; then
    read -p "$sn exists. If you proceed, $sn will first be deleted. Do you want to proceed?(y/n/c)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    rm -rf $sn
fi

echo -e "\e[34mrestoring files\e[39m"
# Will need to first move the source folder if it exists, etc.
if [ -d "$bk" ]; then
    mv "$bk" "$bk.tmp"
    echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz"
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz"
    mv "$bk" "$sn"
    mv "$bk.tmp" "$bk"
    else
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz"
fi

set_site_permissions

#restore db
db_defaults
restore_db






