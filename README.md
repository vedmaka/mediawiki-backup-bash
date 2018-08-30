# mediawiki-backup-bash

This is a set of bash scripts for regular backups of Mediawiki installations.

* `mediawiki_regular_install_backup.sh` - creates files and database dumps of regular Mediawiki installation.
* `create_backup.sh` - creates files and database dumps of Mediawiki farm installation powered by MinimalistFarm extension.
* `rotate_backup.sh` - rotates backups folder keeping only recent ones.
* `s3upload.sh` - synchronises specified directory to remote bucket on S3.

Each script is bundled with help messages so give it a try to get more information about parameters.

# Requirements

* Linux with bash
* Mediawiki installation to backup
* [s3cmd](https://s3tools.org/s3cmd) (optionally, only for `s3upload.sh`)

# Examples

```
$ ./mediawiki_regular_install_backup.sh

====================================================================================
 MWBACKUP is a bash script that helps you to create and rotate backups of Mediawiki site.
          It will create backup of files and database and place it into specified directory
          under a folder named after as a timestamp in yyyy-mm-dd format.
 Example usage:
  ./mwbackup.sh WIKI_ROOT BACKUP_DORECTORY [PATH_TO_LOCALSETTINGS]
      WIKI_ROOT               - absolute path to wiki root directory
      BACKUP_DORECTORY        - absolute path to folder where backups will be stored
      PATH_TO_LOCALSETTINGS   - (optional) path to directory with LocalSettings.php file
                                if stored in different from default location
====================================================================================
```

```
$ ./rotate_backup.sh

 The script rotates backups by deleting sub-folders of the specified folder.
 It uses output of ls command so it implies that sub-folders are named in yyyy-mm-dd format or similar.
 Example usage:
  ./rotate_backup.sh  BACKUP_FOLDER  KEEP_NUMBER
      BACKUP_FOLDER   - path to backups folder (like daily backups root or weekly backups root, etc)
      KEEP_NUMBER     - number of recent backups to keep
```

```
$ ./s3upload.sh 

====================================================================================
 The script syncronizes specified directory contents to S3 bucket.
 Note that it will not delete already uploaded to S3 files, only add new and update modified ones.
 Example usage:
  ./s3upload.sh DIRECTORY BUCKET
      DIRECTORY   - absolute path to the directory
      BUCKET      - name of the bucket to upload files
====================================================================================
```

```
$ ./create_backup.sh 

 The script backups wiki files and database. It is intended to work with MinimalistFarm enabled wikis only.
 Example usage:
  ./create_backup.sh  FARM_ROOT  EXT_PATH  BACKUP_FOLDER  TIME_TAG
      FARM_ROOT       - absolute path to farm wiki directory
      EXT_PATH        - relative (to farm root) path to directory of MinimalistFarm extension
      BACKUP_FOLDER   - path to store backups
      TIME_TAG        - mandatory frequency tag for a backup [daily|weekly|monthly]
```

# Crontab examples

Scripts could be combined together to build a backup cycle, for example the following crontab list will create daily backups into `~/backups/` folder, rotate it keeping only last 7 days backups and synchronize it to S3:

```cron
# Daily backups
0 0 * * * sh ~/mediawiki_regular_install_backup.sh /var/www/mediawiki ~/backups > ~/backup.log
0 3 * * * sh ~/rotate_backup.sh ~/backups 7 > ~/backup_rotate.log
0 4 * * * sh ~/s3upload.sh ~/backups mybucket
```
