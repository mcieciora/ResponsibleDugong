#!/bin/bash

NUMBER_OF_IMAGES=$(docker images | wc -l)
NUMBER_OF_VOLUMES=$(docker volume ls | wc -l)
LIST_OF_CONTAINERS=$(docker container ls -a)

echo "Number of images $NUMBER_OF_IMAGES"
echo "Number of volumes: $NUMBER_OF_VOLUMES"
echo "List of containers: $LIST_OF_CONTAINERS"

echo "Pruning all..."

docker system prune -af --volumes

NUMBER_OF_IMAGES=$(docker images | wc -l)
NUMBER_OF_VOLUMES=$(docker volume ls | wc -l)
LIST_OF_CONTAINERS=$(docker container ls -a)

echo "Number of images $NUMBER_OF_IMAGES"
echo "Number of volumes: $NUMBER_OF_VOLUMES"
echo "List of containers: $LIST_OF_CONTAINERS"
