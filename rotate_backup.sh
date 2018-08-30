#!/bin/bash

help_display() {
    echo " The script rotates backups by deleting sub-folders of the specified folder."
    echo " It uses output of ls command so it implies that sub-folders are named in yyyy-mm-dd format or similar."
    echo " Example usage:"
    echo "  ./rotate_backup.sh  BACKUP_FOLDER  KEEP_NUMBER"
    echo "      BACKUP_FOLDER   - path to backups folder (like daily backups root or weekly backups root, etc)"
    echo "      KEEP_NUMBER     - number of recent backups to keep"
    echo ""
    exit 1
}

if [ -z $1 ] || [ -z $2 ]; then
    help_display
fi

BACKUP_FOLDER=$1
KEEP_NUMBER=$2

if [ ! -d $BACKUP_FOLDER ]; then
    echo " Unable to find specified backups directory!"
    exit 1
fi

echo " Looking for backups, keeping only last $KEEP_NUMBER.."
count=$(ls $BACKUP_FOLDER | wc -l )
echo " Found $count backup entries.."
remove=$(( $count - $KEEP_NUMBER ))

if [ $remove -lt 0 ]; then
    echo " Nothing to do yet!"
    exit 1
fi

echo " $remove backups to be deleted.."
cur=1
for f in $(ls $BACKUP_FOLDER); do
    if [ $cur -gt $remove ]; then
        echo "skipping $f"
    else
        echo "deleting $f"
        rm -rf $BACKUP_FOLDER/$f
    fi
    cur=$((cur + 1))
done
