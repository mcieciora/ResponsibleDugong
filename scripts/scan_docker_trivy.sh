#!/bin/bash

echo "Running docker trivy on jenkins_test_image image"
docker run --rm -u root -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:"$TRIVY_VERSION" image jenkins_test_image > scan_trivy_jenkins.txt
grep "HIGH: 0" scan_trivy_jenkins.txt
HIGH_VULNERABILITIES=$?
grep "CRITICAL: 0" scan_trivy_jenkins.txt
CRITICAL_VULNERABILITIES=$?
if [ "$HIGH_VULNERABILITIES" -ne 0 ] || [ "$CRITICAL_VULNERABILITIES" -ne 0 ]; then
  echo "Script failed, because vulnerabilities were found. Please fix them according to given recommendations."
fi
