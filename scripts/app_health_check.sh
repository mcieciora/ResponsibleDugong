#!/bin/bash

CHECK_TIME=$1
EXPECTED_VALUE=$2

docker compose up -d registry portainer prometheus grafana mariadb vikunja
echo "Sleeping for $CHECK_TIME"
sleep "$CHECK_TIME"

VALUE=$(docker ps --format "{{.Names}}" | grep -c "rd_*")

docker logs rd_mariadb

if [ "$VALUE" -eq "$EXPECTED_VALUE" ]; then
  exit 0
else
  echo "Found $VALUE running containers. Expected is $EXPECTED_VALUE."
  exit 1
fi
