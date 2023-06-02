#!/bin/sh

# simple errors handler mode on
set -e

# set vars
DB_NAME=$(cat .env | grep db_name | cut -d "=" -f 2)
DB_USER=$(cat .env | grep db_user | cut -d "=" -f 2)

# down project
docker compose -p demolab down
# up db node only
docker compose -p demolab up -d sv5_database
# restore from backup
echo 'DROP DATABASE IF EXISTS "$DB_NAME"; CREATE DATABASE "$DB_NAME";' | docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    psql -U $DB_USER
docker cp $1 $(docker ps | grep sv5_databas[e] | cut -d " " -f 1):/var/lib/postgresql/data/bakup.dump
docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    pg_restore -U $DB_USER -d $DB_NAME -v -Fc /var/lib/postgresql/data/bakup.dump
# up project
docker compose -p demolab up -d

# simple errors handler mode off
set +e
