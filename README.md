# Pre-requirement

*Third-party software*
* Docker
* Docker compose (V2)

*SecurityVision installer (containerized)*
* sv5_images.tar.gz (put in root folder of this project)

# Deployment

* Start deployment with `./deploy.sh` command

# Backup & restore

* backup database with `./db_backup_restore_tools/backup_db_to_sql.sh` command, it will create backup in `./sv5db_backups` folder
* restore database from SQL backup with `./db_backup_restore_tools/restore_db_from_sql.sh ./sv5db_backups/backup_name.sql` command, where `backup_name.sql` is a name of backup created with previous command
