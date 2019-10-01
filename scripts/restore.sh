#!/bin/bash
# This task must be run by pl "task name" arguments
if [ -z $folder ]
then
echo "This task must be run by putting pl before it and no .sh, eg pl restore dev"
exit 1
fi

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

parse_oc_yml
import_site_config $sn

# Prompt to choose which database to backup, 1 will be the latest.
# Could be a better way to go: https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt
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


# Check to see if folder already exits.
if [ -d "$folderpath/$sn" ]; then
    read -p "$sn exists. If you proceed, $sn will first be deleted. Do you want to proceed?(Y/n)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    rm -rf $sn
fi

echo -e "\e[34mrestoring files\e[39m"
# Will need to first move the source folder ($bk) if it exists, so we can create the new folder $sn
if [ -d "$folderpath/$bk" ]; then
    if [ -d "$folderpath/$bk.tmp" ]; then
      echo "$folderpath/$bk.tmp exits. There might have been a problem previously. I suggest you move $folderpath/$bk.tmp to $folderpath/$bk and try again."
      exit 1
    fi
    mv "$folderpath/$bk" "$folderpath/$bk.tmp"
    echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz"
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C $folderpath
    mv "$folderpath/$bk" "$folderpath/$sn"
    mv "$folderpath/$bk.tmp" "$folderpath/$bk"
    else
    echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz  fp  $folderpath"
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C $folderpath
fi

# Move settings.php and settings.local.php out the way before they are overwritten just in case you might need them.
setpath="$folderpath/$sn/$webroot/sites/default"
if [ -f "$setpath/settings.php" ] ; then mv "$setpath/settings.php" "$setpath/settings.php.old" ; fi
if [ -f "$setpath//settings.local.php" ] ; then mv "$setpath//settings.local.php" "$setpath/settings.local.php.old" ; fi
if [ -f "$setpath//default.settings.php" ] ; then mv "$setpath//default.settings.php" "$setpath//settings.php" ; fi

### do I need to deal with services.yml?

. $folderpath/scripts/fixss.sh $sn



set_site_permissions $sn

#restore db
db_defaults

restore_db





