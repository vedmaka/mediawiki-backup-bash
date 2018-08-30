# mediawiki-backup-bash

This is a set of bash scripts for regular backups of Mediawiki installations.

* `mediawiki_regular_install_backup.sh` - creates files and database dumps of regular Mediawiki installation.
* `create_backup.sh` - creates files and database dumps of Mediawiki farm installation powered by MinimalistFarm extension.
* `rotate_backup.sh` - rotates backups folder keeping only recent ones.
* `s3upload.sh` - synchronises specified directory to remote bucket on S3.

Each script is bundled with help messages so give it a try to get more information about parameters.
