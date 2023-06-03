#!/bin/sh

# simple errors handler mode on
set -e

# set vars
DB_NAME=$(cat .env | grep db_name | cut -d "=" -f 2)
DB_USER=$(cat .env | grep db_user | cut -d "=" -f 2)

# stop project
docker compose -p sv5platform stop

# start db node only
docker compose -p sv5platform start sv5_database

# clear database
echo "DROP DATABASE IF EXISTS \"$DB_NAME\"; CREATE DATABASE \"$DB_NAME\";" | docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    psql -U $DB_USER

# copy dump to container
docker cp $1 $(docker ps | grep sv5_databas[e] | cut -d " " -f 1):/var/lib/postgresql/data/bakup.dump

# restore database from backup
docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    pg_restore -U $DB_USER -d $DB_NAME -v -Fc /var/lib/postgresql/data/bakup.dump
    
# up project
docker compose -p sv5platform up -d --wait sv5_client

# simple errors handler mode off
set +e
