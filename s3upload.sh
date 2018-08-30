#!/bin/sh

help_display() {
    echo ""
    echo "===================================================================================="
    echo " The script syncronizes specified directory contents to S3 bucket."
    echo " Note that it will not delete already uploaded to S3 files, only add new and update modified ones."
    echo " Example usage:"
    echo "  ./s3upload.sh DIRECTORY BUCKET"
    echo "      DIRECTORY   - absolute path to the directory"
    echo "      BUCKET      - name of the bucket to upload files"
    echo "===================================================================================="
    exit 1
}

if [ -z $1 ] || [ -z $2 ]; then
    help_display
fi

SOURCEDIR=$1
BUCKET=$2

if [ ! -d $SOURCEDIR ]; then
    echo " $SOURCEDIR does not exists!"
    exit 1
fi

if ! type s3cmd > /dev/null 2>&1; then
    echo " s3cmd is required to run the script, please install it first: https://s3tools.org"
    exit 1
fi

echo " Starting sync.."
s3cmd sync --verbose --acl-private --no-delete-removed $SOURCEDIR s3://$BUCKET
if [ $? -ne 0 ]; then
    echo "Upload has failed!"
    exit 1
fi
