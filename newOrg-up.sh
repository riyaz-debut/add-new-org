COMPOSE_FILE_CA_OSQONEWORG=./docker-compose-ca/osqoNewOrg/compose/docker-compose-ca.yaml

docker-compose -f $COMPOSE_FILE_CA_OSQONEWORG up -d


docker-compose -f ./docker-compose-network/docker-compose.yaml up -d 2>&1