#!/bin/sh

# simple errors handler mode on
set -e

# set vars
DB_USER=$(cat .env | grep db_user | cut -d "=" -f 2)

# down project
docker compose -p demolab down
# up db node only
docker compose -p demolab up -d sv5_database
# restore from backup
cat $1 | docker exec -i \
    $(docker ps | grep sv5_databas[e] | cut -d " " -f 1) \
    psql -U $DB_USER

# up project
docker compose -p demolab up -d

# simple errors handler mode off
set +e
