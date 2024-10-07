#!/bin/bash

CHECK_TIME=$1
EXPECTED_VALUE=$2

sh "sed -i 's~5432:5432~8001:5432~g' docker-compose.yml"

docker compose up -d registry portainer app api db pgadmin
echo "Sleeping for $CHECK_TIME"
sleep "$CHECK_TIME"

VALUE=$(docker ps --format "{{.Names}}" | grep -c "rd_*")

if [ "$VALUE" -eq "$EXPECTED_VALUE" ]; then
  exit 0
else
  echo "Found $VALUE running containers. Expected is $EXPECTED_VALUE."
  exit 1
fi
