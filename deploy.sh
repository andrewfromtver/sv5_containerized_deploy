#!/bin/sh

# simple errors handler mode on
set -e

# clear shell
clear

# check docker & docker-compose versions
echo "-----------------------------------------------"
echo "---------- Checking requirements ... ----------"
echo "-----------------------------------------------"
if [ -x "$(command -v docker)" ]; then
    docker -v
    docker compose version
else
    echo ""
    echo "Please install docker & docker-compose."
    exit 0
fi
echo "-----------------------------------------------"

# ask params (external ports)
echo ""
echo "-----------------------------------------------"
echo "--------------- Params request ----------------"
echo "-----------------------------------------------"
echo "Please set db_external_port [5432]"
read db_external_port
echo "Please set client_external_port [8443]"
read client_external_port

# ask params (PostgreSQL connection)
echo "Please set db_name [SecurityVision]"
read db_name
echo "Please set db_user [postgres]"
read db_user
echo "Please set db_password [sv5platform]"
read db_password

# ask params (RabbitMQ connection)
echo "Please set rabbit_user [sv5_user]"
read rabbit_user
echo "Please set rabbit_pwd [sv5platform]"
read rabbit_pwd

# check config
echo ""
echo "Please check configs ..."
echo ""
echo "External ports: PostgreSQL - "${db_external_port:-5432}\
    "Web UI -" ${client_external_port:-8443}
echo "Database config: db_name="${db_name:-SecurityVision}\
    " db_user="${db_user:-postgres}\
    " db_password="${db_password:-sv5platform}
echo "RabbitMQ config: user="${rabbit_user:-sv5_user}\
    " password="${rabbit_pwd:-sv5platform}
echo ""
echo "Is configs correct? (if all params are correct input \"yes\") [no]"

# verify config
read verify
if [ "${verify:-no}" != "yes" ]; then
    exit 0
fi
echo "-----------------------------------------------"

# load images
echo ""
echo "-----------------------------------------------"
echo "---------- Loading docker images ... ----------"
echo "-----------------------------------------------"
docker load -i ./sv5_images.tar.gz
echo "-----------------------------------------------"

# get IP & hostname
echo ""
echo "-----------------------------------------------"
echo "----------- Platform IP & hostname ------------"
echo "-----------------------------------------------"
echo "Current IP (IPs) - "$(hostname -I)
echo "Current hostname - "$(hostname)
echo "-----------------------------------------------"

# create .env file, write valid params & check params
touch ./.env
cat <<EOT > .env
tag=$(docker images -a | grep sv5_connectors | awk '{print $2}')
db_external_port=${db_external_port:-5432}
client_external_port=${client_external_port:-8443}
hostname=$(hostname)
db_server=sv5_database
db_name=${db_name:-SecurityVision}
db_user=${db_user:-postgres}
db_password=${db_password:-sv5platform}
db_port=5432
elastic_server=sv5_elastic
elastic_port=9200
rabbit_server=sv5_rabbit
rabbit_user=${rabbit_user:-sv5_user}
rabbit_pwd=${rabbit_pwd:-sv5platform}
rabbit_port=5672
EOT
echo ""
echo "-----------------------------------------------"
echo "--------------- env file params ---------------"
echo "-----------------------------------------------"
cat ./.env
echo "-----------------------------------------------"

# prepare docker-compose file
cp ./docker-compose_prod_params.yml ./docker-compose.yml

# start project
echo ""
docker compose -p demolab up -d --wait sv5_client

# show web-ui url
echo ""
echo "-----------------------------------------------"
echo "--------------- Web UI http url ---------------"
echo "-----------------------------------------------"
echo "ip -" $(hostname -I | cut -d " " -f 1)
echo "port -" ${client_external_port:-8443}
echo "-----------------------------------------------"

# check project nodes status
echo ""
docker compose -p demolab ps

# docker exec -it -u 0 $(docker ps | grep sv5_connectors | cut -d ' ' -f 1) apt install -y dnsutils kinit

# simple errors handler mode off
set +e
