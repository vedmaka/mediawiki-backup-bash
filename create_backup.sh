#!/bin/sh

help_display() {
    echo " The script backups wiki files and database. It is intended to work with MinimalistFarm enabled wikis only."
    echo " Example usage:"
    echo "  ./create_backup.sh  FARM_ROOT  EXT_PATH  BACKUP_FOLDER  TIME_TAG"
    echo "      FARM_ROOT       - absolute path to farm wiki directory"
    echo "      EXT_PATH        - relative (to farm root) path to directory of MinimalistFarm extension"
    echo "      BACKUP_FOLDER   - path to store backups"
    echo "      TIME_TAG        - mandatory frequency tag for a backup [daily|weekly|monthly]"
    echo ""
    exit 1
}

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ]; then
    help_display
fi

STAMP=$(date -u +%Y-%m-%d)

FARM_ROOT=$1
EXT_PATH=$2
BACKUP_FOLDER=$3
TIME_TAG=$4

TARGET_BACKUP_FOLDER=$BACKUP_FOLDER/$TIME_TAG/$STAMP

if [ -d $TARGET_BACKUP_FOLDER ]; then
    echo " Target directory already exists, aborting!"
    exit 1
fi

if [ ! -d $FARM_ROOT ]; then
    echo " Farm root does not exitsts, aborting!"
    exit 1
fi

if [ ! -d $FARM_ROOT/$EXT_PATH ]; then
    echo " Farm extension root does not exitsts, aborting!"
    exit 1
fi

echo " Creating backup folder $TARGET_BACKUP_FOLDER.."
install -d $TARGET_BACKUP_FOLDER
if [ ! -d $TARGET_BACKUP_FOLDER ]; then
    echo " Failed to create backup directory!"
    exit 1
fi

echo " Backing up farm root into $TARGET_BACKUP_FOLDER/wiki_files.tar.gz ..."
tar czf $TARGET_BACKUP_FOLDER/wiki-files.tar.gz -C $FARM_ROOT .

# commented out due some unreadable files
#if [ $? -ne 0 ]; then
#    echo "Backup has failed!"
#    exit 1
#fi

echo " Files backup completed. $(du -m $TARGET_BACKUP_FOLDER/wiki-files.tar.gz | cut -f1)MB."

echo " Looking for farm database credentials..."
DBPASS=$(cat $FARM_ROOT/LocalSettings.php | grep '^$wgDBpassword' | sed -e 's/$.*"\(.*\)".*/\1/')
DBUSER=$(cat $FARM_ROOT/$EXT_PATH/LocalSettings.php | grep '^$wgDBuser' | sed -e 's/$.*"\(.*\)".*/\1/')

if [ -z $DBPASS ]; then
    echo "Unable to find password in $FARM_ROOT/LocalSettings.php!"
    exit 1
fi

if [ -z $DBUSER ]; then
    echo "Unable to find username in $FARM_ROOT/$EXT_PATH/LocalSettings.php!"
    exit 1
fi

echo " Looking for farm wikis databases.."
for entry in "$FARM_ROOT/$EXT_PATH/sites/"/*
do
  WIKI_FILE=${entry##*/}
  WIKI_NAME=${WIKI_FILE%.*}
  WIKI_DB=$(cat $entry | grep '^$wgDBname' | sed -e 's/$.*"\(.*\)".*/\1/')
  echo " Backing up $WIKI_NAME ( $WIKI_DB ) into $TARGET_BACKUP_FOLDER/$WIKI_NAME-mysql.gz ..."
  mysqldump -u $DBUSER -p"$DBPASS" $WIKI_DB | gzip -c > $TARGET_BACKUP_FOLDER/$WIKI_NAME-mysql.gz
  if [ $? -ne 0 ]; then
    echo "  Database backup has failed!"
    continue
  fi
  echo " MySQL backup completed. $(du -m $TARGET_BACKUP_FOLDER/$WIKI_NAME-mysql.gz | cut -f1)MB."
done
