#!/bin/bash

RETURN_VALUE=0
TESTED_IMAGE="test_jenkins_image:latest"

echo "Running docker scout on $TESTED_IMAGE"
docker run --rm -e DOCKER_SCOUT_HUB_USER="$USERNAME" -e DOCKER_SCOUT_HUB_PASSWORD="$PASSWORD" -v /var/run/docker.sock:/var/run/docker.sock docker/scout-cli:1.10.0 cves "$TESTED_IMAGE" --exit-code --only-severity critical,high
SCAN_RESULT=$?
if [ "$SCAN_RESULT" -ne 0 ]; then
  echo "Vulnerabilities found. Running recommendations"
  docker run --rm -e DOCKER_SCOUT_HUB_USER="$USERNAME" -e DOCKER_SCOUT_HUB_PASSWORD="$PASSWORD" -v /var/run/docker.sock:/var/run/docker.sock docker/scout-cli:1.10.0 recommendations "$TESTED_IMAGE" > scan_jenkins.txt
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
