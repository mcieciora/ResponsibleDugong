#!/bin/bash

RETURN_VALUE=0

echo "Running docker scout on $DOCKERHUB_REPO"
docker run --rm -e DOCKER_SCOUT_HUB_USER="$USERNAME" -e DOCKER_SCOUT_HUB_PASSWORD="$PASSWORD" -u root -v /var/run/docker.sock:/var/run/docker.sock docker/scout-cli:"$SCOUT_VERSION" cves "$DOCKERHUB_REPO" --exit-code --only-severity critical,high
SCAN_RESULT=$?
if [ "$SCAN_RESULT" -ne 0 ]; then
  echo "Vulnerabilities found. Running recommendations"
  docker run --rm -e DOCKER_SCOUT_HUB_USER="$USERNAME" -e DOCKER_SCOUT_HUB_PASSWORD="$PASSWORD" -u root -v /var/run/docker.sock:/var/run/docker.sock docker/scout-cli:"$SCOUT_VERSION" recommendations "$DOCKERHUB_REPO" > scan_jenkins.txt
  grep "This image version is up to date" scan_jenkins.txt
  IMAGE_UP_TO_DATE=$?
  grep "There are no tag recommendations at this time" scan_jenkins.txt
  RECOMMENDATIONS_AVAILABLE=$?
  if [ "$IMAGE_UP_TO_DATE" -eq 0 ] && [ "$RECOMMENDATIONS_AVAILABLE" -eq 0 ] && [ "$RETURN_VALUE" -ne 1 ]; then
    RETURN_VALUE=0
  else
    RETURN_VALUE=1
    echo "Script failed, because vulnerabilities were found. Please fix them according to given recommendations."
  fi
else
  echo "No vulnerabilities detected"
fi
