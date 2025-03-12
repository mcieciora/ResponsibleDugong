#!/bin/bash

echo "Running docker dive on jenkins_test_image"
docker run --rm -u root -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:"$DIVE_VERSION" --ci jenkins_test_image > scan_dive_jenkins.txt
grep "Failed:0" scan_dive_jenkins.txt
FAILED_VULNERABILITIES=$?
if [ "$FAILED_VULNERABILITIES" -ne 0 ]; then
  echo "Script failed, because vulnerabilities were found. Please fix them according to given recommendations."
fi
