#!/bin/sh

help_display() {
    echo ""
    echo "===================================================================================="
    echo " MWBACKUP is a bash script that helps you to create and rotate backups of Mediawiki site."
    echo "          It will create backup of files and database and place it into specified directory"
    echo "          under a folder named after as a timestamp in yyyy-mm-dd format."
    echo " Example usage:"
    echo "  ./mwbackup.sh WIKI_ROOT BACKUP_DORECTORY [PATH_TO_LOCALSETTINGS]"
    echo "      WIKI_ROOT               - absolute path to wiki root directory"
    echo "      BACKUP_DORECTORY        - absolute path to folder where backups will be stored"
    echo "      PATH_TO_LOCALSETTINGS   - (optional) path to directory with LocalSettings.php file"
    echo "                                if stored in different from default location"
    echo "===================================================================================="
    exit 1
}

if [ -z $1 ] || [ -z $2 ]; then
    help_display
fi

STAMP=$(date -u +%Y-%m-%d)

WIKI_ROOT=$1
BACKUP_DORECTORY=$2
LS_FILE=$WIKI_ROOT

if [ ! -z $3 ]; then
    LS_FILE=$3
fi

if [ ! -d $WIKI_ROOT ]; then
    echo " Wiki directory does not exits, check parameters supplied to the script!"
    exit 1
fi

if [ ! -d $LS_FILE ]; then
    echo " LocalSettings.php directory does not exits, check parameters supplied to the script!"
    exit 1
fi

if [ ! -d $BACKUP_DORECTORY ]; then
    echo " Backups directory does not exits, check parameters supplied to the script!"
    exit 1
fi

TARGET_DIRECTORY=$BACKUP_DORECTORY/$STAMP

echo " Creating backup direcotory.."
install -d $TARGET_DIRECTORY
if [ ! -d $TARGET_DIRECTORY ]; then
    echo "Unable to create backup directory, check permissions!"
    exit 1
fi

echo " Backing up wiki files into $TARGET_DIRECTORY.."
tar czf $TARGET_DIRECTORY/wiki-files.tar.gz -C $WIKI_ROOT .

# tar may fail due permissions error on some files, uncomment if you'd like
# to fail whole task when this happens
#if [ $? -ne 0 ]; then
#    echo "Backup has failed!"
#    exit 1
#fi

echo " Files backup completed. $(du -m $TARGET_DIRECTORY/wiki-files.tar.gz | cut -f1)MB."

echo " Looking for farm database credentials..."
DBPASS=$(cat $LS_FILE/LocalSettings.php | grep '^$wgDBpassword' | sed -e 's/$.*"\(.*\)".*/\1/')
DBUSER=$(cat $LS_FILE/LocalSettings.php | grep '^$wgDBuser' | sed -e 's/$.*"\(.*\)".*/\1/')
DBNAME=$(cat $LS_FILE/LocalSettings.php | grep '^$wgDBname' | sed -e 's/$.*"\(.*\)".*/\1/')
DBHOST=$(cat $LS_FILE/LocalSettings.php | grep '^$wgDBserver' | sed -e 's/$.*"\(.*\)".*/\1/')

if [ -z $DBPASS ] || [ -z $DBUSER ] || [ -z $DBNAME ] || [ -z $DBHOST ]; then
    echo "Unable to find database credentials in $LS_FILE/LocalSettings.php!"
    exit 1
fi

echo " Backing up database into $TARGET_DIRECTORY/$DBNAME-mysql.gz"
mysqldump -u $DBUSER -p"$DBPASS" $DBNAME | gzip -c > $TARGET_DIRECTORY/$DBNAME-mysql.gz
if [ $? -ne 0 ]; then
    echo "  Database backup has failed!"
    exit 1
fi

echo " MySQL backup completed. $(du -m $TARGET_DIRECTORY/$DBNAME-mysql.gz | cut -f1)MB."
echo " Backup procedure has been finished!"
