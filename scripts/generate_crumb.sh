#!/bin/bash

set -e

function generate_crumb_and_token() {
  OUTPUT_FILE="token_data.json"
  echo "Sending crumb request..."
  CRUMB=$(curl "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" --cookie-jar cookies.txt --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASS")
  echo "Using crumb to get API token..."
  TOKEN_DATA=$(curl "$JENKINS_URL/user/$JENKINS_ADMIN_USER/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASS" --data "newTokenName=jenkins-token" --cookie cookies.txt -H "$CRUMB")
  echo "Saving acquired API token..."
  echo "$TOKEN_DATA" > "$OUTPUT_FILE"
  TOKEN=$(jq -r ".data.tokenValue" "$OUTPUT_FILE")
  echo "$TOKEN" > "token.sec"
}

generate_crumb_and_token
