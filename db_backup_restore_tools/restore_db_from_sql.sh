#!/bin/sh

# simple errors handler mode on
set -e

# set vars
DB_USER=$(cat .env | grep db_user | cut -d "=" -f 2)
DB_NAME=$(cat .env | grep db_name | cut -d "=" -f 2)

# stop project
docker compose -p sv5platform stop

# start db node only
docker compose -p sv5platform start sv5_database

# create dir for log file (if not exists)
mkdir -p sv5db_backups

# clear database
echo "DROP DATABASE IF EXISTS \"$DB_NAME\"; CREATE DATABASE \"$DB_NAME\";" | docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    psql -U $DB_USER

# restore database from backup
cat $1 | docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    psql -U $DB_USER -d $DB_NAME 2>&1 | tee sv5db_backups/db_restore_`date +%d-%m-%Y"_"%H_%M_%S`.log

# up project
docker compose -p sv5platform up -d --wait sv5_client

# simple errors handler mode off
set +e
