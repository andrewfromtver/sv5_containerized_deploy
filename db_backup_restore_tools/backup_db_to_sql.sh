#!/bin/sh

# simple errors handler mode on
set -e

# set vars
DB_USER=$(cat .env | grep db_user | cut -d "=" -f 2)

# create backup
docker exec -t \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    pg_dumpall -c -U $DB_USER > \
    sv5_dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql

# simple errors handler mode off
set +e
